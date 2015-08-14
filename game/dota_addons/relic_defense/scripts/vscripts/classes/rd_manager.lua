
if cRDManager == nil then
	cRDManager = class({})
end

function cRDManager:Create()
	self._created = true;
	self._roundCount = 0;
	self._roundLimit = 0;
	self._roundObject = nil;
	self._roundContainer = {};
	self._spawnPathPairs = {};
	self._playerStats = {};
	self:FindSpawners();
	self:_LoadRoundConfig();
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "RD_Manager_OnThink", 1);
end

function cRDManager:OnThink()
	if not self._created then
		return 1;
	end

	if not self._roundObject then
		if not GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			print("ERROR: No round object! (cRDManager:OnThink)")
		end
		return 1
	end

	local status = self._roundObject:Status()
	if status == "na" then
	elseif status == "pre" then
	elseif status == "active" then
	elseif status == "post" then
	elseif status == "final" then
		self:_NextRound();
	else
		print("WARNING: Unknown status encounted! (cRDManager:OnThink)")
	end

	return 1;
end

function cRDManager:FindSpawners()
	if not self._created then
		print("ERROR: Calling Manager functions before creating it! (cRDManager:FindSpawners)");
		return;
	end

	local pathEnts = Entities:FindAllByClassname("path_corner");
	local spawnEnts = Entities:FindAllByClassname("npc_dota_scripted_spawner");
	self._spawnPathPairs = {};
	
	for _, spawnEnt in pairs(spawnEnts) do
		local spawner = cRDSpawner();
		spawner:Create(spawnEnt);

		for _, pathEnt in pairs(pathEnts) do
			if (spawnEnt:GetOrigin() - pathEnt:GetOrigin()):Length2D() < 1000 then

				print("Adding path " .. pathEnt:GetName() .. " to spawner " .. spawnEnt:GetName());
				spawner:AddPath(pathEnt);
			end
		end

		table.insert(self._spawnPathPairs, spawner);
	end
end

function cRDManager:GetCurrentRound()
	if not self._created then
		print("ERROR: Calling Manager functions before creating it! (cRDManager:GetCurrentRound)");
		return nil;
	end

	return self._roundObject;
end

function cRDManager:GetNextRound()
	if not self._created then
		print("ERROR: Calling Manager functions before creating it! (cRDManager:GetNextRound)");
		return nil;
	end

	if self._roundCount + 1 > #self._roundContainer then
		print("WARNING: Trying to move to next round but we're out of rounds! (cRDManager:GetNextRound)");
		return nil;
	end

	return self._roundContainer[self._roundCount + 1];
end

function cRDManager:NextRound()
	self:_NextRound(false);
end

function cRDManager:_NextRound(boolWait)
	if not self._created then
		print("ERROR: Calling Manager functions before creating it! (cRDManager:_NextRound)");
		return nil;
	end

	if self._roundObject then
		self._roundObject:End();
		self:_UpdatePlayerStats();
	end

	self._roundObject = self:GetNextRound();
	self._roundCount = self._roundCount + 1;
	
	if self._roundObject then
		self._roundObject:Activate();
		if not boolWait then
			self._roundObject:Start();
		end
	else
		GameRules:MakeTeamLose( DOTA_TEAM_BADGUYS )
	end
end

function cRDManager:_LoadRoundConfig()
	if not self._created then
		print("ERROR: Calling Manager functions before creating it! (cRDManager:_LoadRoundConfig)");
		return;
	end

	local kv = LoadKeyValues( "scripts/maps/" .. GetMapName() .. "/rounds.txt" );
	
	if not kv then
		print("ERROR: Cant load config 'scripts/maps/" .. GetMapName() .. "/rounds.txt'!");
		return;
	end

	self._isEndless = kv.Endless == 1 or false;
	self._roundLimit = kv.RoundCount;

	for roundNum, roundInfo in pairs(kv.Rounds) do
		local round = cRDRound();

		roundInfo.PreRoundTime = roundInfo.PreRoundTime or kv.PreRoundTimeDefault;
		roundInfo.RoundTime = roundInfo.RoundTime or kv.RoundTimeDefault;
		roundInfo.PostRoundTime = roundInfo.PostRoundTime or kv.PostRoundTimeDefault;

		round:Create(roundInfo);
		round:SetSpawnerInfo(self._spawnPathPairs);
		--round:PrepSpawners();

		self._roundContainer[tonumber(roundNum)] = round;
	end
end

function cRDManager:_UpdatePlayerStats()
	if not self._created then
		print("ERROR: Calling Manager functions before creating it! (cRDManager:_UpdatePlayerStats)");
		return;
	end

	local newStats = self._roundObject:GetPlayerStats();

	for playerID, stats in pairs(newStats) do
		if not self._playerStats[playerID] then
			local stats = {}
			print("Creating stats for playerID " .. playerID);
			stats["CreepsKilled"] = 0;
			stats["ChampsKilled"] = 0;
			stats["BossesKilled"] = 0;
			stats["Revives"]		= 0;

			self._playerStats[playerID] = stats
		end

		for stat, value in pairs(stats) do
			self._playerStats[playerID][stat] = self._playerStats[playerID][stat] + value;
		end
	end
	CustomNetTables:SetTableValue("player_stats", "overall", self._playerStats);
end

function cRDManager:DebugSpawners()
	for _, spawner in pairs(self._spawnPathPairs) do
		spawner:Debug();
	end
end