--[[===============================================================================================
File: generic_boss_abilities.lua
Handles abilities that belong to multiple bosses rather than datadriving them
===================================================================================================
Boring disclaimer stuff:
Code in this file is copyright (c) Luke "ashashinand" Herbert 2015
Code falls under MIT Licence. To view in detail, view the licence file (LICENCE.md) on the 
github repo (https://github.com/ashashinand/relic-defense)
Some sections of code may be copyright of Valve Software and as such may be reproducible under a 
different license.
===============================================================================================]]--

--[[===============================================================================================
Passive: Boss Truesight, free pathing, etc.
===============================================================================================]]--
relic_boss_passive_common = class({});
LinkLuaModifier("relic_boss_modifier_common", "modifier_scripts/boss/generic_boss_modifiers", LUA_MODIFIER_MOTION_NONE);

function relic_boss_passive_common:GetIntrinsicModifierName()
	return "relic_boss_modifier_common";
end

function relic_boss_passive_common:GetCastRange()
	return self:GetSpecialValueFor("true_sight_radius");
end

function relic_boss_passive_common:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE;
end