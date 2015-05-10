GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' )

PrefabFiles = {
		"berk",
		"berk_crown",
}


-- aren't globals fun?
TUNING.KINGCATCOON_LOYALTY_PER_ITEM = TUNING.TOTAL_DAY_TIME * .5
TUNING.KINGCATCOON_LOYALTY_MAXTIME = TUNING.TOTAL_DAY_TIME * 5
TUNING.KINGCATCOON_SPEED = 4

local STRINGS = GLOBAL.STRINGS
STRINGS.NAMES.BERK = "Berk, King of the Catcoons"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BERK = "Cute!"

STRINGS.NAMES.BERK_CROWN = "Berk's Crown"
STRINGS.RECIPE_DESC.BERK_CROWN = "Berk's Crown"
-- 
-- STRINGS.CHARACTERS.GENERIC.DESCRIBE.BERK_CROWN = 
-- 
-- STRINGS.CHARACTERS.WILLOW.DESCRIBE.BERK_CROWN = 
-- 
-- STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.BERK_CROWN = 
-- 
-- STRINGS.CHARACTERS.WENDY.DESCRIBE.BERK_CROWN = 
-- 
-- STRINGS.CHARACTERS.WX78.DESCRIBE.BERK_CROWN = 
-- 
-- STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.BERK_CROWN = 
-- 
-- STRINGS.CHARACTERS.WOODIE.DESCRIBE.BERK_CROWN = 
-- 
-- STRINGS.CHARACTERS.WAXWELL.DESCRIBE.BERK_CROWN = 
-- 
-- if IsDLCEnabled(REIGN_OF_GIANTS) then 
-- 
-- 	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.BERK_CROWN = 
-- 
-- 	STRINGS.CHARACTERS.WEBBER.DESCRIBE.BERK_CROWN = 


--
-- The following should mirror the changes in berk.lua's RetargetFn function
-- 

-- Set catcoons non-hostile to each-other
local function NewCatcoonRetarget(inst)
    return FindEntity(inst, TUNING.CATCOON_TARGET_DIST,
        function(guy)
        	if guy:HasTag("catcoon") then
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

-- This replaces the catcoon targeting function with one that makes them ignore each other (see above).
local function ReplaceRetargetFunction(prefab)
	if prefab:HasTag("catcoon") and prefab.components.combat.targetfn and prefab.components.SetRetargetFunction then
		prefab.components.combat:SetRetargetFunction(2, NewCatcoonRetarget)
	end
end
AddPrefabPostInit("catcoon", ReplaceRetargetFunction)


-- Spawn the starting catcoon!
function GiveBerk(player)
	local x, y, z = player.Transform:GetWorldPosition()
	local creature = GLOBAL.SpawnPrefab("forest/animals/berk")
	creature.Transform:SetPosition( x, y, z )
end
--AddSimPostInit(GiveBerk)

-- Give the crown!
function GiveBerkCrown(player)
	local x, y, z = player.Transform:GetWorldPosition()
	local hat = GLOBAL.SpawnPrefab("berk_crown")
	hat.Transform:SetPosition( x, y, z )
end
AddSimPostInit(GiveBerkCrown)
