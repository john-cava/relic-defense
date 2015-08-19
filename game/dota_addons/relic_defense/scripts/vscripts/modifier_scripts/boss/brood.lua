--[[===============================================================================================
File: brood.lua
Handles modifiers that belong to the broodmother boss.
===================================================================================================
Boring disclaimer stuff:
Code in this file is copyright (c) Luke "ashashinand" Herbert 2015
Code falls under MIT Licence. To view in detail, view the licence file (LICENCE.md) on the 
github repo (https://github.com/ashashinand/relic-defense)
Some sections of code may be copyright of Valve Software and as such may be reproducible under a 
different license.
===============================================================================================]]--

--[[===============================================================================================
Modifier: Web Regen Buff Giver
While in web radius, friendly units gain bonus hp % regen.
===============================================================================================]]--

relic_boss_modifier_brood_webbing_regen = class({});

--PARAMETER BLOCK--------------------------------

function relic_boss_modifier_common:IsHidden()
	return true;
end

function relic_boss_modifier_common:IsAura()
	return true;
end

function relic_boss_modifier_common:GetModifierAura()
	return "relic_boss_modifier_brood_webbing_regen_effect";
end

function relic_boss_modifier_common:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY;
end

function relic_boss_modifier_common:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL;
end

function relic_boss_modifier_common:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE;
end

function relic_boss_modifier_common:GetAuraRadius()
	return self.aura_radius;
end

--EVENT BLOCK------------------------------------

function relic_boss_modifier_brood_webbing_regen:OnCreated(kv)
	self.aura_radius = kv.radius;
end


--[[===============================================================================================
Modifier: Web Regen Effect
Units under effect gain hp % regen
===============================================================================================]]--

relic_boss_modifier_brood_webbing_regen_effect = class({});

--PARAMETER BLOCK--------------------------------
function relic_boss_modifier_brood_webbing_regen_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}

	return funcs;
end

function relic_boss_modifier_brood_webbing_regen_effect:IsHidden()
	return false;
end

function relic_boss_modifier_brood_webbing_regen_effect:IsBuff()
	return true;
end

function relic_boss_modifier_brood_webbing_regen_effect:GetModifierHealthRegenPercentage()
	--I dont like this but i dont see any way of making the aura giver actually pass the value on
	return self:GetAbility():GetSpecialValueFor("web_regen");
end