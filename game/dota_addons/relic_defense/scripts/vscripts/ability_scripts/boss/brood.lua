--[[===============================================================================================
File: brood.lua
Handles abilities that belong to the broodmother boss.
===================================================================================================
Boring disclaimer stuff:
Code in this file is copyright (c) Luke "ashashinand" Herbert 2015
Code falls under MIT Licence. To view in detail, view the licence file (LICENCE.md) on the 
github repo (https://github.com/ashashinand/relic-defense)
Some sections of code may be copyright of Valve Software and as such may be reproducible under a 
different license.
===============================================================================================]]--

--[[===============================================================================================
Ability: Cast Web
While in web radius, brood gains bonus hp regen. Brood can consume the web to use as a windwalk location.
===============================================================================================]]--
relic_boss_ability_brood_webbing = class({});
LinkLuaModifier("relic_boss_modifier_brood_webbing_regen", "modifier_scripts/boss/brood", LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("relic_boss_modifier_brood_webbing_regen_effect", "modifier_scripts/boss/brood", LUA_MODIFIER_MOTION_NONE)

--PARAMETER BLOCK--------------------------------

function relic_boss_ability_brood_webbing:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
end

function relic_boss_ability_brood_webbing:GetAOERadius()
	return self:GetSpecialValueFor("web_radius");
end

--EVENT BLOCK------------------------------------
--Stop brood from casting the webs anywhere that its not pathable.
function relic_boss_ability_brood_webbing:OnAbilityPhaseStart()
	local hCaster = self:GetCaster();
	local hTarget = self:GetCursorTarget();
	if not GridNav:CanFindPath(hCaster:GetOrigin(), hTarget:GetOrigin()) then
		return false;
	end

	return true;
end

function relic_boss_ability_brood_webbing:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	if IsServer() then
		local vOrigin = local hTarget:GetOrigin();

		local hEnt = CreateUnitByName("npc_relic_bossminion_brood_web", vOrigin, true, nil, hCaster, hCaster:GetTeamNumber());
		if hEnt then
			hEnt:AddNewModifier(hCaster, self, "relic_boss_modifier_brood_webbing_regen", 
				{regen = self:GetSpecialValueFor("web_regen"), radius = self:GetSpecialValueFor("web_radius")});

			if not self:GetCaster().availableWebs then
				self:GetCaster().availableWebs = {}
			end
			table.insert(self:GetCaster().availableWebs, hEnt);
		end
	end
end

--[[===============================================================================================
Ability: Wind Walk
Technically not a windwalk as it is a blink strike + invis. Uses a web as a target.
===============================================================================================]]--

relic_boss_ability_brood_windwalk = class({})

function relic_boss_ability_brood_windwalk:OnSpellStart()
end