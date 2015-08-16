--[[===============================================================================================
Building destroyer AI
Ignores players, targets buildings from the ancient outward.
I stole all of this from Valve (holdout_example/holdout_ai_attack_ancient.lua)
i dont want to do this im sorry i just dunno how it all works :(
===============================================================================================]]--
order = {}
hTarget = {}

function Spawn( entityKeyValues )
	hAncient = Entities:FindByName( nil, "dota_goodguys_fort" )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	order.UnitIndex = thisEntity:entindex()
	ChooseTarget()
	order.OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
end

function ChooseTarget()
	hTarget = hAncient
	local buildings = FindUnitsInRadius( DOTA_TEAM_GOODGUYS, hAncient:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, 0, FIND_ANY_ORDER, false )
	if #buildings > 0 then
		hTarget = buildings[RandomInt(1, #buildings)]
	end
	order.TargetIndex = hTarget:entindex()
end

function AIThink()
	if hTarget:IsNull() or not hTarget:IsAlive() then
		ChooseTarget()
	end

	-- Got to keep issuing it in case the order drops
	ExecuteOrderFromTable(order)

	return 2.0
end