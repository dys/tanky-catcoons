PrefabFiles = {
		"kingcatcoon",
}

-- set catcoons non-hostile to each-other - 27241699
local function NewCatcoonRetarget(inst)
    return FindEntity(inst, TUNING.CATCOON_TARGET_DIST,
        function(guy)
        	if (guy:HasTag("catcoon") or guy:HasTag("kingcatcoon")) then
        		return false	
        	else
            	return 	((guy:HasTag("monster") or guy:HasTag("smallcreature")) and 
	            		guy.components.health and 
	            		not guy.components.health:IsDead() and 
	            		inst.components.combat:CanTarget(guy) and 
	            		not (inst.components.follower and inst.components.follower.leader ~= nil and guy:HasTag("abigail"))) and
            			not (inst.components.follower and guy.components.follower and inst.components.follower.leader ~= nil and inst.components.follower.leader == guy.components.follower.leader) and
            			not (inst.components.follower and guy.components.follower and inst.components.follower.leader ~= nil and guy.components.follower.leader and guy.components.follower.leader.components.inventoryitem and guy.components.follower.leader.components.inventoryitem.owner and inst.components.follower.leader == guy.components.follower.leader.components.inventoryitem.owner)
	            	or 	(guy:HasTag("cattoyairborne") and 
	            		not (inst.components.follower and guy.components.follower and inst.components.follower.leader ~= nil and inst.components.follower.leader == guy.components.follower.leader) and 
	            		not (inst.components.follower and guy.components.follower and inst.components.follower.leader ~= nil and guy.components.follower.leader and guy.components.follower.leader.components.inventoryitem and guy.components.follower.leader.components.inventoryitem.owner and inst.components.follower.leader == guy.components.follower.leader.components.inventoryitem.owner)) 
	        end
        end)
end


-- replace the retarget function
local function ReplaceRetargetFunction(prefab)
	if prefab:HasTag("catcoon") and prefab.components.combat.targetfn and prefab.components.SetRetargetFunction then
		prefab.components.combat:SetRetargetFunction(2, NewCatcoonRetarget)
	end
end


-- spawn the starting catcoon!
function GiveKingCatcoon(player)
	local x, y, z = player.Transform:GetWorldPosition()
	local creature = GLOBAL.SpawnPrefab("forest/animals/kingcatcoon")
	creature.Transform:SetPosition( x, y, z )
end

-- AddSimPostInit(GiveKingCatcoon)
AddPrefabPostInit("catcoon", ReplaceRetargetFunction)

TUNING.KINGCATCOON_LOYALTY_PER_ITEM = TUNING.TOTAL_DAY_TIME * .5
TUNING.KINGCATCOON_LOYALTY_MAXTIME = TUNING.TOTAL_DAY_TIME * 5
TUNING.KINGCATCOON_SPEED = 4

local STRINGS = GLOBAL.STRINGS
STRINGS.NAMES.KINGCATCOON = "Berk, King of the Catcoons"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KINGCATCOON = "Cute!"

GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' )
