--[[===============================================================================================
Brood Minion AI
Goes for buildings, but then rabidly targets players on recieving a buff
I stole some of this from Valve (holdout_example/holdout_ai_attack_ancient.lua)
im sorry :(
===============================================================================================]]--

order = {}
hTarget = {}

function Spawn( entityKeyValues )
	hAncient = Entities:FindByName( nil, "dota_goodguys_fort" );
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 );
	order.UnitIndex = thisEntity:entindex();
	ChooseTarget();
	order.OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET;
end

function ChooseTarget()
	--Fallback unit, cant attack anything? ATTACK THE ANCIENT.
	--Good advice for spiders or players of dota.
	hTarget = hAncient;
	local tPossibilities = {};
	--Are they under the broodbuff?
	if thisEntity:FindModifierByName("creature_buff_brood_call") then
		tPossibilities = FindHeroes();
	end

	if not tPossibilities then
		tPossibilities = FindBuildings();
	end

	if tPossibilities then
		hTarget = tPossibilities[RandomInt(1, #tPossibilities)];
	end

	order.TargetIndex = hTarget:entindex();
end

function FindHeroes()
	local tHeroes = FindUnitsInRadius( DOTA_TEAM_GOODGUYS, thisEntity:GetOrigin(), nil, 2000, 
			DOTA_UNITY_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, false);
	if #tHeroes > 0 then
		return tHeroes;
	end
	
	return nil;
end

function FindBuildings()
	local tBuildings = FindUnitsInRadius( DOTA_TEAM_GOODGUYS, hAncient:GetOrigin(), nil, 1000, 
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, 0, FIND_ANY_ORDER, false );
	if #tBuildings > 0 then
		return tBuildings;
	end

	return nil;
end

function AIThink()
	if hTarget:IsNull() or not hTarget:IsAlive() then
		ChooseTarget();
	end

	-- Got to keep issuing it in case the order drops
	ExecuteOrderFromTable(order);

	return 1.0
end