--[[===============================================================================================
File: generic_boss_modifiers.lua
Handles modifiers that belong to multiple bosses rather than datadriving them
===================================================================================================
Boring disclaimer stuff:
Code in this file is copyright (c) Luke "ashashinand" Herbert 2015
Code falls under MIT License. To view in detail, view the license file (LICENSE.md) on the 
github repo (https://github.com/ashashinand/relic-defense)
Some sections of code may be copyright of Valve Software and as such may be reproducible under a 
different license.
===============================================================================================]]--

--[[===============================================================================================
Modifier: Provides true sight, provides free pathing, destroys illusions if attacking them or
attacked by one.
===============================================================================================]]--
relic_boss_modifier_common = class({});
LinkLuaModifier("relic_modifier_truesight", "modifier_scripts/common", LUA_MODIFIER_MOTION_NONE)

--PARAMETER BLOCK--------------------------------
function relic_boss_modifier_common:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_ATTACK_START
	};

	return funcs;
end

function relic_boss_modifier_common:IsHidden()
	return true;
end

function relic_boss_modifier_common:IsAura()
	return true;
end

function relic_boss_modifier_common:GetModifierAura()
	return "relic_modifier_truesight";
end

function relic_boss_modifier_common:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY;
end

function relic_boss_modifier_common:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO;
end

function relic_boss_modifier_common:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED;
end

function relic_boss_modifier_common:GetAuraRadius()
	return self.aura_radius;
end

--EVENT BLOCK------------------------------------
function relic_boss_modifier_common:OnCreated(kv)
	self.aura_radius = self:GetAbility():GetSpecialValueFor("true_sight_radius");
end



function relic_boss_modifier_common:OnAttacked(params)
	self:KillEntIfIllu(params);

	return 0
end
--^ v THEY'RE LIKE THE DIFFERENT FUNCTIONS WITH DIFFERENT TRIGGERS WHY ARE THE PARAMS THE SAME WHAT IS THIS
function relic_boss_modifier_common:OnAttackStart(params)
	self:KillEntIfIllu(params);

	return 0
end

function relic_boss_modifier_common:CheckState()
	local state = {
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true, --unit phasing
	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, --free pathing
	}
 
	return state
end

--RELATED FUNCTIONS BLOCK------------------------

--Kill the entity if its an illusion, simple stuff.
function relic_boss_modifier_common:KillEntIfIllu(params)
	local hAttacker = params.attacker or nil;
	local hTarget = params.target or nil;
	local hEntity = nil;

	if hAttacker == self:GetCaster() then
		hEntity = hTarget;
	else
		hEntity = hAttacker;
	end

	print(hEntity:GetUnitName());

	if not hEntity or not IsValidEntity(hEntity) then 
		return false;
	end

	if hEntity:IsIllusion() then
		hEntity:ForceKill(false);
		return true;
	end

	return false
end