"use strict";

//IIFE
(function () {
	var context = $.GetContextPanel(); //get calling root XML 
	var newChildPanel = $.CreatePanel( "Panel", context, "top_bar_heroes");
	newChildPanel.BLoadLayout( "file://{resources}/layout/custom_game/relic_defense/top_bar_heroes.xml", false, false );
})();