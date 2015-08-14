--[[===============================================================================================
Split: When the unit dies, the unit turns into multiple smaller versions of itself
This is the actual modifier which does most of the work, the ability itself is mainly for tooltip
===============================================================================================]]--

rd_creature_passive_split_modifier = class({})

function rd_creature_passive_split_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}
 
	return funcs
end

function rd_creature_passive_split_modifier:OnDeath( params )
	DeepPrintTable(params);
	if IsServer() then
		local hOwner = self:GetParent();
		local sClassname = hOwner:GetClassname();
		local nSplitTimes = self:GetSpecialValueFor("split_num_times")
		local nUnitsToCreate = self:GetSpecialValueFor("num_units_make")
		local nStacksToGive = self:GetStackCount() - 1;

		local hEnt = CreateUnitByName(sClassname, hOwner, true, nil, nil, hOwner:GetTeamNumber());
		if hEnt then
			if nStacksToGive > 0 then
				hEnt:AddAbility("rd_modifier_creature_passive_split")
				hEnt:SetModifierStackCount("rd_creature_passive_split_modifier", self:GetCaster(), nStacksToGive)
			end
		else
		end
	end
end