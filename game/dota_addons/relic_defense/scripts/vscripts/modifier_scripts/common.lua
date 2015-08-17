--[[===============================================================================================
File: common.lua
Handles modifiers that belong to a variety in types of units, rather than datadriving them.
===================================================================================================
Boring disclaimer stuff:
Code in this file is copyright (c) Luke "ashashinand" Herbert 2015
Code falls under MIT License. To view in detail, view the license file (LICENSE.md) on the 
github repo (https://github.com/ashashinand/relic-defense)
Some sections of code may be copyright of Valve Software and as such may be reproducible under a 
different license.
===============================================================================================]]--

--[[===============================================================================================
Modifier: Reveals invisible units. Sometimes its so good it slows them down (or speeds them up?)
===============================================================================================]]--
relic_modifier_truesight = class({})

--PARAMETER BLOCK--------------------------------
function relic_modifier_truesight:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function relic_modifier_truesight:GetModifierMoveSpeedBonus_Percentage()
	return self.move_speed_bonus;
end

--EVENT BLOCK------------------------------------

function relic_modifier_truesight:OnCreated(kv)
	self.move_speed_bonus = kv["move_speed_bonus"] or 0;
end

function relic_modifier_truesight:CheckState()
	local state = {
	[MODIFIER_STATE_INVISIBLE] = false,
	}
 
	return state
end