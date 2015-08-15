--[[===============================================================================================
Split: When the unit dies, the unit turns into multiple smaller versions of itself
This is the actual modifier which does most of the work, the ability itself is mainly for tooltip
===============================================================================================]]--

modifier_creature_passive_split = class({})

--registration
function modifier_creature_passive_split:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

--Hidden if we're not gonna do anything
function modifier_creature_passive_split:IsHidden()
	if self:GetStackCount() == 0 then
		return true
	else
		return false
	end
end

--On creation to actually set stack size
function modifier_creature_passive_split:OnCreated( kv )
	local hAbility = self:GetAbility()
	self.nSplitTimes = hAbility:GetSpecialValueFor("split_num_times")
	self.nUnitsToCreate = hAbility:GetSpecialValueFor("num_units_make")

	if IsServer() then
		self:SetStackCount(self.nSplitTimes);
	end
end

function modifier_creature_passive_split:OnDeath( params )


	--[[
	print("============================")
	for key, value in pairs(params) do
		print(key .. " \t = \t " .. tostring(value) .. " (" .. type(value) .. ")")
	end
	print("============================")
	]]--
	if IsServer() then

		--DO THEY INTO EXIST?
		if not self:GetCaster() then
			return 0
		end

		--DO THEY INTO NOT BREAK?
		if self:GetCaster():PassivesDisabled() then
			return 0
		end

		--DO THEY INTO NEED THIS?
		if self:GetStackCount() == 0 then
			return 0
		end

		--DO THEY INTO ACTUALLY CORRECT UNIT?
		if self:GetCaster() ~= self:GetParent() then
			return 0
		end

		--DO THEY ACTUALLY ARE CORRECT UNIT?
		if self:GetCaster() ~= params.unit then
			return 0
		end

		local hOwner = self:GetCaster();
		local sClassname = hOwner:GetUnitName();

		local nStacksToGive = self:GetStackCount() - 1;
		--local nFactor = (self.nUnitsToCreate ^ (self.nSplitTimes - self:GetStackCount()));
		local nFactor = math.min(self.nUnitsToCreate / self:GetStackCount(), 10);
		print(nFactor);

		for i=1, self.nUnitsToCreate do
			local hEnt = CreateUnitByName(sClassname, hOwner:GetOrigin(), true, nil, nil, hOwner:GetTeamNumber());
			if hEnt then
				if not hEnt:HasAbility("rd_creature_passive_split") then
					hEnt:AddAbility("rd_creature_passive_split");
				end

				hEnt:SetModifierStackCount("modifier_creature_passive_split", hEnt, nStacksToGive);
				hEnt:SetBaseMaxHealth(math.floor(hEnt:GetBaseMaxHealth() / nFactor));
				hEnt:SetBaseDamageMin(math.floor(hEnt:GetBaseDamageMin() / nFactor));
				hEnt:SetBaseDamageMax(math.floor(hEnt:GetBaseDamageMax() / nFactor));
				hEnt:SetBaseAttackTime(hEnt:GetBaseAttackTime() / nFactor);
				hEnt:SetBaseMoveSpeed(hEnt:GetBaseMoveSpeed() + (hEnt:GetBaseMoveSpeed() / 4 * nFactor))
				hEnt:SetModelScale(hEnt:GetModelScale() / nFactor);
				hEnt:SetInitialGoalEntity(hOwner:GetInitialGoalEntity());
			end
		end
	end

	return 0
end