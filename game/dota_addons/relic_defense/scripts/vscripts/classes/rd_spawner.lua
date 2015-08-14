
if cRDSpawner == nil then
	cRDSpawner = class({})
end

function cRDSpawner:Create(spawnEnt)
	self._created = true;
	self._active = false;
	self._spawnEntity = spawnEnt;
	self._paths = {};
	self._queue = {};
	self._activeUnits = {};
	self._cooldown = 15;
	self._cooldownCurrent = -1;
	self._deltaLives = 0;
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "RD_Spawner_" .. self._spawnEntity:GetName() .. "_Think", 1 );
end

function cRDSpawner:OnThink()
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDManager:OnThink)");
		return 1;
	end

	if self._active then
		if self._cooldownCurrent > 0 then
			self._cooldownCurrent = self._cooldownCurrent - 1
		else
			if #self._queue > 0 then
				self:_PopPacket()
				self._cooldownCurrent = self._cooldown;
			end
		end
	end

	--[[
	--look try it this way first
	for index, unit in ipairs(self._activeUnits) do
		if IsValidEntity(unit) then
			if not unit:IsAlive() then
				table.remove(self._activeUnits, index);
			end 
		else
			table.remove(self._activeUnits, index);
		end
	end
	]]--
	return 1;
end

function cRDSpawner:AddPath(pathEnt)
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDManager:AddPath)");
		return;
	end

	table.insert(self._paths, pathEnt);
end

function cRDSpawner:SetCooldown(intNum)
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDManager:AddPath)");
		return;
	elseif not (type(intNum) == "number") then
		print("ERROR: Trying to set cooldown that isnt a number! (cRDManager:AddPath)");
		return;
	end

	self._cooldown = intNum;
end

function cRDSpawner:Queue(mobPacket)
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDSpawner:PushMobs)");
		return;
	end

	table.insert(self._queue, mobPacket);
end

function cRDSpawner:Activate()
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDSpawner:Activate)");
		return;
	end

	if self._active then
		print("WARNING: Spawner is already active! (cRDSpawner:Activate)");
		return;
	end

	self._active = true;
end

function cRDSpawner:GetActiveState()
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDSpawner:Deactivate)");
		return;
	end

	return self._active;
end

function cRDSpawner:Deactivate()
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDSpawner:Deactivate)");
		return;
	end

	if not self._active then
		print("ERROR: Spawner is already not active! (cRDSpawner:Deactivate)");
		return;
	end

	self._active = false;
end

function cRDSpawner:IsDone()
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDSpawner:IsDone)");
		return;
	end

	if #self._activeUnits > 0 then
		return false
	end

	if #self._queue > 0 then
		return false
	end

	return true
end

function cRDSpawner:Remove(ent)
	for index, unit in ipairs(self._activeUnits) do
		if IsValidEntity(unit) then
			if unit == ent then
				table.remove(self._activeUnits, index);
				return true;
			end 
		else
			table.remove(self._activeUnits, index);
		end
	end
	return false;
end

function cRDSpawner:DeltaDead()
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDSpawner:DeltaDead)");
		return;
	end

	local difference = self._deltaLives - #self._activeUnits;
	self._deltaLives = #self._activeUnits;

	if difference < 0 then
		return 0;
	end

	return difference;
end

function cRDSpawner:Purge()
	if not self._created then
		print("ERROR: Calling Spawner functions before creating it! (cRDSpawner:Purge)");
		return;
	end

	for _, ent in pairs(self._activeUnits) do
		--where were you when ent is kill
		ent:Kill(nil, nil)
	end
	self._queue = {};
	self._activeUnits = {};
	self._cooldownCurrent = 0;
end

function cRDSpawner:Debug()
	print("====================================")
	print("Spawn Entity: " .. self._spawnEntity:GetName());
	for _, ent in ipairs(self._paths) do
		print("Path Entity: " .. ent:GetName());
	end
	for index, packet in ipairs(self._queue) do
		print("Packet #" .. index .. ":");
		DeepPrintTable(packet);
	end
	print("Number of active units: " .. #self._activeUnits);
	print("Number of queued packets: " .. #self._queue);
	print("Done?: " .. tostring(self:IsDone()));
	print("====================================")
end

function cRDSpawner:_GetPath()
	return self._paths[RandomInt(1, #self._paths)];
end

function cRDSpawner:_PopPacket()
	local packet = table.remove(self._queue);

	if packet then
		if type(packet[2]) == "number" then
			--23/07/15 you're an idiot
			for _=1, packet[2] do
				self:_CreateUnit(packet[1], nil);
			end
		else
			for _, subPacket in pairs(packet) do
				for _=1, subPacket[2] do
					self:_CreateUnit(subPacket[1], nil);
				end
			end
		end
	end
end

function cRDSpawner:_GetSpawnVec(boolRandom)
	local vec = Vector(0, 0, 0);
	if self._spawnEntity then
		if boolRandom then
			vec = self._spawnEntity:GetAbsOrigin() + RandomVector(RandomFloat(0, 200));
		else
			vec = self._spawnEntity:GetAbsOrigin(); 
		end
	end

	return vec;
end

function cRDSpawner:_CreateUnit(unitName, unitClass)
	local ent = self:_SpawnNPC(unitName);

	if not ent then
		print("No spawned unit! Cant apply modifiers!")
		return
	end

	if unitClass == "hero" then
		--do stuff
	elseif unitClass == "champ" then
		--do stuff again?
	end

	table.insert(self._activeUnits, ent);
end


function cRDSpawner:_SpawnNPC(unitName)
	if self._spawnEntity == nil then
		print("ERROR: Spawner trying to spawn without a reference spawner! HELP");
		return nil;
	end

	local ent = CreateUnitByName(unitName, self:_GetSpawnVec(), true, nil, nil, DOTA_TEAM_BADGUYS);
	if ent then
		--keep doing stuff? help im so lost
		local path = self:_GetPath();
		if path then
			ent:SetInitialGoalEntity(path);
		end

		ent.isAggroUnit = true;
		return ent;
	else
		print("ERROR: Trying to spawn non-valid unit (" .. unitName .. ") at " .. tostring(self:_GetSpawnVec()))
	end

	return nil;
end