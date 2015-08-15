--[[===============================================================================================
Split: When the unit dies, the unit turns into multiple smaller versions of itself
This is the actual modifier which does most of the work, the ability itself is mainly for tooltip
===============================================================================================]]--

modifier_creature_passive_split = class({})

function modifier_creature_passive_split:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function modifier_creature_passive_split:OnDeath( params )
	for key, value in pairs(params) do
		
	end
	if IsServer() then
		local hOwner = self:GetParent();
		local sClassname = hOwner:GetClassname();
		local hAbility = self:GetAbility()
		local nSplitTimes = hAbility:GetSpecialValueFor("split_num_times")
		local nUnitsToCreate = hAbility:GetSpecialValueFor("num_units_make")
		local nStacksToGive = self:GetStackCount() - 1;

		local hEnt = CreateUnitByName(sClassname, hOwner, true, nil, nil, hOwner:GetTeamNumber());
		if hEnt then
			if nStacksToGive > 0 then
				hEnt:AddAbility("rd_creature_passive_split");
				hEnt:SetModifierStackCount("modifier_creature_passive_split", self:GetCaster(), nStacksToGive);
			end
		else
		end
	end
end