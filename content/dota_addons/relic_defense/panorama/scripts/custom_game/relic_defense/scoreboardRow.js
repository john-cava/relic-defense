"use strict";

var roundSpecific = false;
var playerID = -1;
var keyName = "overall";
var steamID = "";

function updateCreepScores()
{
	var jsonData = CustomNetTables.GetTableValue( "player_stats", keyName )
	if (jsonData === undefined)
	{
		$("#scoreBoardRowCreepKillsLabel").text = 0;
		$("#scoreBoardRowChampionKillsLabel").text = 0;
		$("#scoreBoardRowBossKillsLabel").text = 0;
		//$("#scoreBoardRowRevivesLabel").text = 0;
	}
	else
	{
		var playerData = jsonData[playerID];
		$("#scoreBoardRowCreepKillsLabel").text = playerData["CreepsKilled"];
		$("#scoreBoardRowChampionKillsLabel").text = playerData["ChampsKilled"];
		$("#scoreBoardRowBossKillsLabel").text = playerData["BossesKilled"];
	}
}

function tryAvatarUpdate()
{
	if (steamID === "")
	{
		var playerInfo = Game.GetPlayerInfo(playerID)
		steamID = playerInfo["player_steamid"];
		$("#scoreBoardRowImage").steamid = steamID;
	}

}

function generateHeroText()
{
	var heroEnt = Players.GetPlayerHeroEntityIndex(playerID);
	var heroName = Players.GetPlayerSelectedHero(playerID);
	var heroLevel = Entities.GetLevel(heroEnt);
	var heroUpgraded = Entities.HasScepter(heroEnt);

	var string = "Lv ";
	string += heroLevel;
	if (heroUpgraded)
	{
		string += "+";
	}
	string += " ";
	string += $.Localize( "#"+heroName );

	return string
}

function onRowThink()
{
	$("#scoreBoardRowDeathsLabel").text = Players.GetDeaths(playerID);
	$("#scoreBoardRowHeroLabel").text = generateHeroText();
	$("#scoreBoardRowNameLabel").text = Players.GetPlayerName(playerID);
	tryAvatarUpdate();
	updateCreepScores();	
	$.Schedule( 0.25, onRowThink );
}

//IIFE
(function () {
	var context = $.GetContextPanel();
	var split = $.GetContextPanel().id.split("_");
	roundSpecific = split[1] === "Current";
	playerID = parseInt(split[2]);

	keyName = "overall"
	if (roundSpecific)
	{
		keyName = "current_round"
	}	

	onRowThink();
})();
