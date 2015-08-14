--[[===============================================================================================
Mana Burn: You know. Burns mana. Does damage based on the mana burnt. Ez stuff.
===============================================================================================]]--

rd_creature_manaburn = class({})

--To stop manaburn on targets with no mana (i.e useless)
function rd_creature_manaburn:OnAbilityPhaseStart()
	local hTarget = self:GetCursorTarget()
	if hTarget:GetMaxMana() == 0 then
		return false
	end

	return true;
end

--Actual meat of spell
function rd_creature_manaburn:OnSpellStart()
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

	--TODO: figure out how to get into vsndevts files to find the satyr burn sound instead
	EmitSoundOnLocationWithCaster(hTarget:GetOrigin(), "Hero_NyxAssassin.ManaBurn.Target", hCaster )
end

--[[===============================================================================================

===============================================================================================]]--