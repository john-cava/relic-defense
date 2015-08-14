
if cRDRound == nil then
	cRDRound = class({})
end

function cRDRound:Create(roundInfo)
	self._created = true;
	self._active = false;
	self._roundTimes = {
		-1,
		roundInfo.PreRoundTime,
		roundInfo.RoundTime,
		roundInfo.PostRoundTime,
		-1
	}
	self._roundNumber = roundInfo.RoundNumber;
	self._roundTitle = roundInfo.RoundTitle;
	self._roundPattern = roundInfo.RoundPattern;
	self._roundStatus = 1;
	self._roundTime = -1;
	self._roundCountdown = -1;
	self._unitsKilled = 0;
	self._unitsToKill = 0;
	self._playerStats = {};
	self._availableSpawners = {};
	self._unitPackets = {};
	self._humanReadableStatus = {"na", "pre", "active", "post", "final"};

	self._roundBreakdown = {}
	self._listenHandles = {};

	--todo: isn't this _rd = ri.rb?
	for index, unitData in pairs(roundInfo.RoundBreakdown) do
		self._roundBreakdown[index] = unitData;
	end

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "RD_Round_" .. self._roundNumber .. "_Think", 1 );
end

function cRDRound:Activate()
	self:_GenerateUnitPackets();
	self:_PushPacketsToSpawners();
	--I should dynamic wrap this (TODO)
	table.insert(self._listenHandles, ListenToGameEvent( "entity_killed", cRDRound.OnEntityKilled, self ))

	for playerID=-1, PlayerResource:GetPlayerCount() - 1 do
		local stats = {}
		stats["CreepsKilled"] = 0;
		stats["ChampsKilled"] = 0;
		stats["BossesKilled"] = 0;
		stats["Revives"]		= 0;

		self._playerStats[playerID] = stats
		
	end
	self._active = true;
end

function cRDRound:Start(boolNow)
	if not self._created then
		print("ERROR: Trying to run round functions without creating the round first! CRDRound:Start")
		return
	end

	if not self._active then
		print("ERROR: Trying to run round functions without activating the round first! CRDRound:Start")
		return
	end

	--Don't start twice, if we've started once, just return instantly
	if self._roundStatus == 1 then
		if boolNow then
			print("Starting round " .. self._roundNumber .. " now!")
			self:_IncrementRound(2);
		else
			print("Starting round " .. self._roundNumber .. " with pretime...")
			self:_IncrementRound();
		end
	end

	CustomNetTables:SetTableValue("round_status", "round_info", {	roundTitle = self._roundTitle, 
																	roundNumber = self._roundNumber,
																	roundMaxUnitCount = self:_GetNumUnitsToKill()});
	CustomNetTables:SetTableValue("round_status", "unit_stats", {	unitsKilled = self._unitsKilled });
end

function cRDRound:End()
	for _, handle in pairs(self._listenHandles) do
		StopListeningToGameEvent(handle);
	end
	for _, spawner in pairs(self._availableSpawners) do
		spawner:Purge();
	end
	self._deleted = true;
end

function cRDRound:OnEntityKilled(eventInfo)
	if not self._created then
		print("ERROR: Trying to run round functions without creating the round first! CRDRound:OnEntityKilled");
		return
	end

	if not self._active then
		print("ERROR: Trying to run round functions without activating the round first! CRDRound:OnEntityKilled");
		return
	end

	local killedUnit = EntIndexToHScript( eventInfo.entindex_killed );
	if not killedUnit then
		print("ERROR: Killed unit apparantly doesn't exist! CRDRound:OnEntityKilled");
		return
	end

	local help = true;
	for _, spawner in pairs(self._availableSpawners) do
		if spawner:Remove(killedUnit) then
			self._unitsKilled = self._unitsKilled + 1;
			help = false;
			break;
		end
	end

	if help then 
		print("ERROR: Unit killed that doesn't belong to a spawner! (" .. killedUnit:GetClassname() .. ") Huh? CRDRound:OnEntityKilled");
	end

	local attackerUnit = EntIndexToHScript( eventInfo.entindex_attacker or -1 );
	if attackerUnit then
		local playerID = attackerUnit:GetPlayerOwnerID();
		local playerStats = self._playerStats[playerID];
		if not playerStats then
			self._playerStats[playerID] = {};
			playerStats = self._playerStats[playerID]
		end

		playerStats.CreepsKilled = (playerStats.CreepsKilled or 0) + 1;
	end

end

function cRDRound:OnThink()
	if not self._created then
		print("ERROR: Trying to think without being created! RD_Round_" .. self._roundNumber .. "_Think");
		return 1;
	end

	if not self._active then
		return 1;
	end

	if self._roundStatus == 3 then
		--Nighttime
		GameRules:SetTimeOfDay(0.95);
		self._roundTime = self._roundTime + 0.20;
		local done = true;
		for _, spawner in ipairs(self._availableSpawners) do
			--self._unitsKilled = self._unitsKilled + (spawner:DeltaDead() or 0);
			if not spawner:IsDone() then
				done = false;
			end
		end

		if done then
			self:_IncrementRound();
		end
	else
		--Daytime
		GameRules:SetTimeOfDay(0.45)
		self._roundCountdown = self._roundCountdown - 0.20;
		if self._roundCountdown <= 0 then
			self: _IncrementRound();
		end
	end




	CustomNetTables:SetTableValue("round_status", "round_time", { 	countdown = math.ceil(self._roundCountdown), 
																	time = math.floor(self._roundTime) });
	CustomNetTables:SetTableValue("round_status", "unit_stats", {	unitsKilled = self._unitsKilled });

	CustomNetTables:SetTableValue("player_stats", "current_round", self._playerStats)

	if not self._deleted then
		return 0.20;
	end
end

function cRDRound:SetSpawnerInfo(spawnInfo)
	if not self._created then
		print("ERROR: Trying to run round functions without creating the round first! cRDRound:SetSpawnerInfo")
		return
	end

	self._availableSpawners = spawnInfo;
end

function cRDRound:Status()
	if not self._created then
		print("ERROR: Trying to run round functions without creating the round first! cRDRound:Status")
		return
	end

	return self._humanReadableStatus[self._roundStatus];
end

function cRDRound:GetPlayerStats()
	if not self._created then
		print("ERROR: Trying to run round functions without creating the round first! cRDRound:GetPlayerScores")
		return
	end

	return self._playerStats
end


function cRDRound:Debug()
	print("====================================");
	print("#: " .. self._roundNumber);
	print("Title: " .. self._roundTitle);
	print("Status: " .. self:Status());
	print("Countdown: " .. self._roundCountdown);
	print("Time Limit: " .. self._roundTimes[self._roundStatus]);
	print("Round Time: " .. self._roundTime);
	DeepPrintTable(self._roundBreakdown);
	print("====================================");
end


function cRDRound:_GenerateUnitPackets()	
	local numSpawners = #self._availableSpawners;


	for _, unitData in pairs(self._roundBreakdown) do
		-- I HAVE NO IDEA WHY THIS CALLBACK FUNCTION EXISTS LOL
		PrecacheUnitByNameAsync(unitData.UnitType, function ( blowme ) end);
		--TODO: Last unit waves rounded up, rest rounded down
		self:_GeneratePacketsForSpawner(unitData, true);
		--self:_GeneratePacketsForUnit(unitData, numWaves);
	end

end

function cRDRound:_GeneratePacketsForSpawner(unitData, boolRoundUp)

	local numWavesMin, numWavesMax;
	if self._roundPattern == "wave" then
		numWavesMin = 4;
		numWavesMax = 7;
	elseif self._roundPattern == "mob" then
		numWavesMin = 10;
		numWavesMax = 15;
	elseif self._roundPattern == "boss" then
		numWavesMin = math.huge;
		numWavesMax = math.huge;
 	end
	numWavesMin = numWavesMin + math.floor(self:_GetNumUnitsToKill() / 100);
	numWavesMax = numWavesMax + math.floor(self:_GetNumUnitsToKill() / 60);

	
	local numTypes = self:_GetNumUnitsTypes();

	for spawnNum=1, #self._availableSpawners or 0 do
		local numWaves = RandomInt(numWavesMin, numWavesMax);
		

	 	if boolRoundUp then
	 		numWaves = math.ceil(numWaves / numTypes);
	 	else
	 		numWaves = math.floor(numWaves / numTypes);
	 	end

	 	--Oh yes the classic "i cant be stuffed defining a variable for this table" parse
	 	for _, packet in ipairs(self:_GeneratePacketsForUnit(unitData, numWaves)) do
	 		table.insert(packet, 1, spawnNum);
	 		table.insert(self._unitPackets, packet);
	 	end
	end
end

function cRDRound:_GeneratePacketsForUnit(unitData, numWaves)
	local packets = {};

	local runningTotal = unitData.UnitCount;
	for j=1, numWaves do 
		local numUnits = math.floor(unitData.UnitCount / numWaves);
		runningTotal = runningTotal - numUnits;

		if not unitData.UnitMinionType then
			table.insert(packets, {unitData.UnitType, numUnits});
		else
			table.insert(packets, {{unitData.UnitType, numUnits}, {unitData.UnitMinionType, unitData.UnitMinionCount * numUnits}})
		end

	end

	if runningTotal > 0 then 
		if not unitData.UnitMinionType then
			table.insert(packets, 1, {unitData.UnitType, runningTotal});
		else
			table.insert(packets, 2, {{unitData.UnitType, runningTotal}, {unitData.UnitMinionType, unitData.UnitMinionCount * runningTotal}})
		end
	end

	return packets;
end

function cRDRound:_GetNumUnitsToKill()
	if self._unitsToKill == 0 then 
		local numSpawners = #self._availableSpawners;
		for _, unitData in pairs(self._roundBreakdown) do
			self._unitsToKill = self._unitsToKill + ((unitData.UnitCount or 0) * numSpawners);
			self._unitsToKill = self._unitsToKill + ((unitData.UnitMinionCount or 0) * (unitData.UnitCount or 0) * numSpawners);
		end
	end

	return self._unitsToKill;
end

function cRDRound:_GetNumUnitsTypes()
	if not self._unitsNumType then
		self._unitsNumType = 0;
		for index, _ in pairs (self._roundBreakdown) do
			if tonumber(index) > self._unitsNumType then
				self._unitsNumType = tonumber(index);
			end
		end
	end

	return self._unitsNumType;
end

--[[function cRDRound:_GenerateUnitPackets()
	local numSpawners = #self._availableSpawners;
	local totalUnits = 0;
	local pairedUnits = false;
	local pairedUnitsCombos = {};
	for _, unitData in pairs(self._roundBreakdown) do
		totalUnits = totalUnits + (unitData.UnitCount or 0);
		totalUnits = totalUnits + (unitData.UnitMinionCount or 0);
		if unitData.UnitMinions then
			pairedUnits = true;
		end
	end
	local unitCounts = {};
	local averageMobs = totalUnits / numSpawners;


	if not pairedUnits then

		for i=1, numSpawners do
			unitCounts[i] = averageMobs;
		end

		if totalUnits % numSpawners > 0 then
			--todo: cant i do this in the if? luas weird xd
			local rem = totalUnits % numSpawners;
			while rem > 0 do
				local index = RandomInt(1, numSpawners)
				unitCounts[index] = unitCounts[index] + 1
				rem = rem - 1 
			end
		end

		for _, unitData in pairs(self._roundBreakdown) do
			if self._roundPattern == "wave" or self._roundPattern == "mob" then
				--waves act as discrete chunks of units instead of a continuous stream, best represented as large packets
				--mobs act like a constant stream of units so are best suited by small waves
				local waves = 0;
				if self._roundPattern == "wave" then
					waves = RandomInt(4, 6);
				else
					waves = RandomInt(10, 12);
				end

				for i=1, #unitCounts do
					local runningTotal = unitCounts[i];
					for j=1, waves do
						--is it gonna split nicely?
						runningTotal = runningTotal - math.floor(unitCounts[i] / waves);
						table.insert(self._unitPackets, {i, unitData.UnitType, math.floor(unitCounts[i] / waves)});
					end
					if runningTotal > 0 then
						table.insert(self._unitPackets, {i, unitData.UnitType, runningTotal});
					end
				end
			elseif self._roundPattern == "boss" then
				--boss rounds act weird :(

			else
			end
		end
	else
	end
end
]]--

function cRDRound:_PushPacketsToSpawners()
	while #self._unitPackets > 0 do
		local packet = table.remove(self._unitPackets);
		local index = table.remove(packet, 1);

		self._availableSpawners[index]:Queue(packet);
	end
end

function cRDRound:_IncrementRound(roundTo)
	local string = "Round " .. self._roundNumber .. " advancing (" .. self._roundStatus
	self._roundStatus = roundTo or self._roundStatus + 1;

	print(string .. "->" .. self._roundStatus .. ")");
	self._roundCountdown = self._roundTimes[self._roundStatus];

	CustomNetTables:SetTableValue("round_status", "round_status", { status = self:Status() });

	if self._roundStatus == 3 then
		for _, spawner in ipairs(self._availableSpawners) do
			spawner:Activate();
		end
	else
		for _, spawner in ipairs(self._availableSpawners) do
			spawner:Deactivate();
		end
	end
end