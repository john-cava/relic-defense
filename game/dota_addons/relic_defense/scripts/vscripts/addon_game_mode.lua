-- Generated from template

require('classes/rd_spawner');
require('classes/rd_round');
require('classes/rd_manager');

if cRDGM == nil then
	cRDGM = class({})
end

function Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nyx_assassin.vsndevts", context)
	--[[
		PrecacheItemByNameSync( "item_tombstone", context )
		PrecacheItemByNameSync( "item_bag_of_gold", context )
		PrecacheItemByNameSync( "item_slippers_of_halcyon", context )
		PrecacheItemByNameSync( "item_greater_clarity", context )
	]]--
end

-- Create the game mode when we activate
function Activate()
	math.randomseed(Time());
	
	GameRules.RelicDefense = cRDGM();
	GameRules.RelicDefense:InitGameMode();

	cRoundManager = cRDManager();
	cRoundManager:Create();
end

function cRDGM:InitGameMode()
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 );
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 );
	GameRules:SetHeroRespawnEnabled( false );
	GameRules:SetUseUniversalShopMode( true );
	GameRules:SetHeroSelectionTime( 120.0 );
	GameRules:SetPreGameTime(0.0);
	GameRules:SetGoldTickTime( 6 );
	GameRules:SetGoldPerTick( 5 );
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true );
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true );
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false );

	Convars:RegisterCommand( "rd_debug_reload_spawners", function(...) return self:_ccReloadSpawnpoints( ... ) end, "Tell the round manager to refind it's spawn points.", FCVAR_CHEAT );
	Convars:RegisterCommand( "rd_debug_skip_round", function(...) return self:_ccSkipToNextRound( ... ) end, "Skip the current round", FCVAR_CHEAT );
	Convars:RegisterCommand( "rd_debug_skip_to_round", function(...) return self:_ccSkipToRoundNum( ... ) end, "Skip to the specified round number", FCVAR_CHEAT );
	Convars:RegisterCommand( "rd_debug_print_spawner", function(...) return self:_ccDebugSpawners( ... ) end, "Debug Print every spawner", FCVAR_CHEAT );
	Convars:RegisterCommand( "rd_debug_print_round", function(...) return self:_ccDebugRound( ... ) end, "Debug Print the current round", FCVAR_CHEAT );
	

	for _, tower in pairs( Entities:FindAllByName( "npc_dota_holdout_tower_spawn_protection" ) ) do
		tower:AddNewModifier( tower, nil, "modifier_invulnerable", {} )
	end

	for _, altar in pairs( Entities:FindAllByName( "npc_dota_building_altar" ) ) do
		for i=1, #PlayerResource:GetPlayerCount() do
			altar:SetControllableByPlayer(i, true);
		end
	end
	--[[
	Convars:RegisterCommand( "rd_debug_current_round", function(...) return self:_cvDebugCurrentRound( ... ) end, "Preform a deep print of the current round", FCVAR_CHEAT );
	Convars:RegisterCommand( "rd_debug_finish_round", function(...) return self:_cvForceEndCurrentRound( ... ) end, "Force the in-progress round to end and start post round", FCVAR_CHEAT );
	Convars:RegisterCommand( "rd_debug_pop_random_spawner", function(...) return self:_cvPopRandomSpawner( ... ) end, "Force a random spawner to pop one of its packets", FCVAR_CHEAT );
	Convars:RegisterCommand( "rd_debug_get_active_unit_table", function(...) return self:_cvGetActiveUnitTable( ... ) end, "Force a deep print of the active units table for all spawners", FCVAR_CHEAT );
	]]--
	--ListenToGameEvent("entity_hurt", cRDGM._gvDamagedTaken, self)

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

-- Evaluate the state of the game
function cRDGM:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if not cRoundManager:GetCurrentRound() then
			cRoundManager:NextRound();
		end
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil;
	end


	return 1;
end

function cRDGM:_ccSkipToNextRound( cmdName )
	cRoundManager:NextRound();
end

function cRDGM:_ccSkipToRoundNum( cmdName, ... )
	local args = {...}
	cRoundManager:GotoRound(args[1])
end

function cRDGM:_ccReloadSpawnpoints( cmdName )
	cRoundManager:FindSpawners();
end

function cRDGM:_ccDebugSpawners( cmdName )
	cRoundManager:DebugSpawners();
end

function cRDGM:_ccDebugRound( cmdName )
	cRoundManager:GetCurrentRound():Debug();
end



--[[
function cRDGM:_cvDebugCurrentRound( cmdName )
	cRoundManager:CurrentRound():Debug();
end

function cRDGM:_cvForceEndCurrentRound( cmdName )
	cRoundManager:CurrentRound():ForceEnd();
end

function cRDGM:_cvPopRandomSpawner( cmdName )
	cRoundManager:CurrentRound():PopRandomSpawner();
end

function cRDGM:_cvGetActiveUnitTable( cmdName )
	cRoundManager:CurrentRound():cvDumpSpawners();
end
]]--