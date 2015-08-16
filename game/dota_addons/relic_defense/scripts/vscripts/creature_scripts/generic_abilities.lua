--[[===============================================================================================
Mana Burn: You know. Burns mana. Does damage based on the mana burnt. Ez stuff.
===============================================================================================]]--

creature_ability_manaburn = class({})

--To stop manaburn on targets with no mana (i.e useless)
function creature_ability_manaburn:OnAbilityPhaseStart()
	local hTarget = self:GetCursorTarget()
	if hTarget:GetMaxMana() == 0 or hTarget:GetMana() == 0 then
		return false
	end

	return true;
end

--Actual meat of spell
function creature_ability_manaburn:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	if IsServer() then

		--Sanity checking
		if not hCaster or not hTarget or hTarget:TriggerSpellAbsorb(this) then
			return
		end

		local nNumerator = self:GetSpecialValueFor("mana_burnt_pc")
		local nManaToBurn = hTarget:GetMaxMana() * (nNumerator / 100.0)

		--Cant burn more mana than the target has
		--Well you can, but that's cheating.
		if nManaToBurn > hTarget:GetMana() then
			nManaToBurn = hTarget:GetMana()
		end

		hTarget:ReduceMana(nManaToBurn);

		local nDamageToDeal = math.floor(nManaToBurn * (self:GetSpecialValueFor("mana_burn_damage") / 100.0))

		local damage = {
			victim = hTarget,
			attacker = hCaster,
			damage = nDamageToDeal,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = self
		}

		ApplyDamage(damage);
	end

	--Not in server block: All clients need to do this!
	local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_WORLDORIGIN, hCaster )
	ParticleManager:SetParticleControl( nFXIndex, 0, hTarget:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOnLocationWithCaster(hTarget:GetOrigin(), "n_creep_SatyrSoulstealer.ManaBurn", hCaster )
end

--[[===============================================================================================
Split: When the unit dies, the unit turns into multiple smaller versions of itself
Most of the work is actually done by the modifier (modifier_creature_passive_split.lua)
===============================================================================================]]--

creature_passive_split = class({})
LinkLuaModifier( "modifier_creature_passive_split", "creature_scripts/modifier_creature_passive_split", LUA_MODIFIER_MOTION_NONE )

function creature_passive_split:GetIntrinsicModifierName()
	return "modifier_creature_passive_split"
end
