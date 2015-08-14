"use strict";
	
var context = $.GetContextPanel(); //get calling root XML
var status = "UNKNOWN"

function clamp(intNum, intMin, intMax)
{
	return Math.min(Math.max(intNum, intMin), intMax);
}

function pad(intNum)
{
	if (intNum < 10)
		return "0" + intNum;
	else
		return "" + intNum;
}

function factorizeTime(intTime)
{
	var hours = clamp(Math.floor(intTime / 3600), 0, 99);
	var minutes = clamp(Math.floor(intTime / 60), 0, 60);
	var seconds = clamp(intTime % 60, 0, 60);
	return "" + pad(hours) + ":" + pad(minutes) + ":" + pad(seconds);
}

function updateTitle()
{
	//$.Msg("Title update recieved")

	var table = CustomNetTables.GetTableValue( "round_status", "round_info" );
	var string = "[#" + table["roundNumber"] + "] " + $.Localize(table["roundTitle"]);

	$("#roundTitle").text = string
}

function updateTime()
{
	//$.Msg("Time update receieved");

	var jsonData = CustomNetTables.GetTableValue( "round_status", "round_time" );
	var time = 0;

	if (status == "active")
	{
		$("#roundStatus").text = "" ;
		time = jsonData["time"] ;
	}
	else if (status == "pre")
	{
		$("#roundStatus").text = "Pre-round" ;
		time = jsonData["countdown"] ;
	}
	else if (status == "post")
	{
		$("#roundStatus").text = "Post-round" ;
		time = jsonData["countdown"] ;
	}
	else
		$("#roundStatus").text = "UNKNOWN" ;


	$("#roundTime").text = factorizeTime(time);
}	

function updateKills()
{

	var maxUnits = CustomNetTables.GetTableValue( "round_status", "round_info" )["roundMaxUnitCount"];
	var currUnits = CustomNetTables.GetTableValue( "round_status", "unit_stats")["unitsKilled"]

	$("#roundKills").text = "" + currUnits + "/" + maxUnits;

}

function onThink()
{
	status = CustomNetTables.GetTableValue( "round_status", "round_status" )["status"]

	updateTitle();
	updateTime();
	updateKills();

	$.Schedule( 0.10, onThink );
}


//IIFE thing
(function () {
	$.Schedule( 1, onThink );
})();