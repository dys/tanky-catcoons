--[NEW] This function spawns a 'Beefalo' at the player's position.  The player parameter is a reference to the player in game.
function SpawnCreature(player)
	
	--[NEW] Get the player's current position.
	local x, y, z = player.Transform:GetWorldPosition()

	--[NEW] Spawn a 'Beefalo' prefab at the world origin.  Prefabs are basically a fancy game development term for objects.  Every 
	--		creature, item and character in 'Don't Starve' is a prefab.
	local creature = GLOBAL.SpawnPrefab("forest/animals/beefalo")

	--[NEW] Move the creature to the player's position.
	creature.Transform:SetPosition( x, y, z )	
end


--[NEW] Tell the engine to run the function "SpawnCreature" as soon as the player spawns in the world.
AddSimPostInit(SpawnCreature)