"use strict";

var context = $.GetContextPanel(); //get calling root XML 
var players = Game.GetAllPlayerIDs();

function factorize(number)
{
	if (number < 5000)
	{
		return number;
	}
	else if (number < 5000000)
	{
		return "" + Math.floor(number / 1000) + "K";
	}
	else if (number < 5000000000)
	{
		return "" + Math.floor(number / 1000000) + "M"; 
	}
	else if (number < 5000000000000)
	{
		return "" + Math.floor(number / 1000000000) + "G"; 
	}
	else
	{
		return "u broke it grats";
	}
}

function updateHeroStatImage(node, playerInfo)
{
	if ( playerInfo.player_selected_hero !== "" )
	{
		node.SetImage( "file://{images}/heroes/" + playerInfo.player_selected_hero + ".png" );
	}
	else
	{
		node.SetImage( "file://{images}/custom_game/unassigned.png" );
	}
}

function updateHeroStatGold(node, playerID)
{
	var gold = Players.GetTotalEarnedGold(playerID);
	if (gold !== undefined)
	{
		node.text = factorize(gold);
	}
	else
	{
		node.text = -1;
	}
}

function updateHeroStatCS(node, playerID)
{
	var CS = Players.GetLastHits(playerID)
	if (CS !== undefined)
	{
		node.text = factorize(CS);
	}
	else
	{
		node.text = -1;
	}
}

function updateHeroStatDamage(node, playerID)
{
	var dmg;
	if (dmg !== undefined)
	{
		node.text = factorize(CS);
	}
	else
	{
		node.text = -1;
	}
}
function updateHeroStatRes(node, playerID)
{
	var res;
	if (res !== undefined)
	{
		node.text = factorize(CS);
	}
	else
	{
		node.text = -1;
	}
}

function createNewHeroNode(playerID)
{
	$.Msg("Creating node for player ID " + playerID + "...");
	var newChildPanel = $.CreatePanel( "Panel", context, "top_bar_player_" + playerID );
	newChildPanel.BLoadLayout( "file://{resources}/layout/custom_game/relic_defense/top_bar_hero.xml", false, false );
	$.Msg( "done!");
}

function updateHeroStat(playerID)
{
	//Is it a real player?
	var playerInfo = Game.GetPlayerInfo( playerID );
	if (playerInfo)
	{
		//get XML node of relevant player stats
		var baseNode = context.FindChild("top_bar_player_" + playerID);

		if (baseNode)
		{			
			//Lets update the hero icon!
			var heroIcon = baseNode.FindChild("heroIcon");
			if (heroIcon)
			{
				updateHeroStatImage(heroIcon, playerInfo);
			}
			else
			{
				$.Msg("Failed to grab child node : heroIcon : top_bar_player_" + playerID);
			}

			var goldText = baseNode.FindChildTraverse("goldScoreText")
			if (goldText)
			{
				updateHeroStatGold(goldText, playerID);
			}
			else
			{
				$.Msg("Failed to grab child node : goldScoreText : top_bar_player_" + playerID);
			}

			var csText = baseNode.FindChildTraverse("creepScoreText")
			if (goldText)
			{
				updateHeroStatCS(csText, playerID);
			}
			else
			{
				$.Msg("Failed to grab child node : creepScoreText : top_bar_player_" + playerID);
			}

			var dmgText = baseNode.FindChildTraverse("damageScoreText")
			if (goldText)
			{
				updateHeroStatRes(dmgText, playerID);
			}
			else
			{
				$.Msg("Failed to grab child node : damageScoreText : top_bar_player_" + playerID);
			}

			var resurrText = baseNode.FindChildTraverse("resurrScoreText")
			if (goldText)
			{
				updateHeroStatRes(resurrText, playerID);
			}
			else
			{
				$.Msg("Failed to grab child node : resurrScoreText : top_bar_player_" + playerID);
			}
		}
		else
		{
			$.Msg("Failed to grab node: top_bar_player_" + playerID);
		}
	}
	else
	{
		$.Msg("LOOKING UP INVALID PLAYER ID: " + playerID);
	}
}

function updateHeroStats()
{
	for( var playerID of players ) {
		updateHeroStat(playerID);
	}

	$.Schedule( 0.25, updateHeroStats );
}


(function (){
context = $.GetContextPanel(); //get calling root XML element
players = Game.GetAllPlayerIDs();

for( var playerID of players ) {
	createNewHeroNode(playerID);
}
updateHeroStats();
})();
