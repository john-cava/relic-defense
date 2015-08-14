"use strict";

/* scoreboard.js : File responsible for populating the scoreboard

*/

function generateRowForPlayer(playerID)
{
	var newCurrentPanel = $.CreatePanel( "Panel", $("#scoreboardCurrentRoundContainer"), "scoreboardRow_Current_" + playerID);
	newCurrentPanel.BLoadLayout( "file://{resources}/layout/custom_game/relic_defense/scoreboard_row.xml", false, false );
	var newOverallPanel = $.CreatePanel( "Panel", $("#scoreboardOverallRoundContainer"), "scoreboardRow_Overall_" + playerID);
	newOverallPanel.BLoadLayout( "file://{resources}/layout/custom_game/relic_defense/scoreboard_row.xml", false, false );
}

//i stole this from valve
//sorry :(
function SetFlyoutScoreboardVisible( bVisible )
{
	$.GetContextPanel().SetHasClass( "flyout_scoreboard_visible", bVisible );
	if ( bVisible )
	{
		//ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true );
	}
	else
	{
		//ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, false );
	}
}

//IIFE
(function () {
	for(var playerID of Game.GetAllPlayerIDs())
	{
		generateRowForPlayer(playerID);
	}

	SetFlyoutScoreboardVisible( false );
	
	$.RegisterEventHandler( "DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetFlyoutScoreboardVisible );
})();

