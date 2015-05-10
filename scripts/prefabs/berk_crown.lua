-- most of this is copied from 366720084 and chester_eyebone.lua

local assets = {
  Asset("ANIM", "anim/hat_flower.zip"),
  Asset("ATLAS", "images/inventoryimages/berk_crown.xml"),
  Asset("IMAGE", "images/inventoryimages/berk_crown.tex"),
}

local prefabs = {
}

local SPAWN_DIST = 30

local trace = function() end

local function RebuildTile(inst)
  if inst.components.inventoryitem:IsHeld() then
	local owner = inst.components.inventoryitem.owner
	inst.components.inventoryitem:RemoveFromOwner(true)
	if owner.components.container then
	  owner.components.container:GiveItem(inst)
	elseif owner.components.inventory then
	  owner.components.inventory:GiveItem(inst)
	end
  end
end

local function GetSpawnPoint(pt)
  local theta = math.random() * 2 * PI
  local radius = SPAWN_DIST

  local offset = FindWalkableOffset(pt, theta, radius, 12, true)
  if offset then
	return pt+offset
  end
end

local function SpawnBerk(inst)
  trace("berk_crown - SpawnBerk")

  local pt = Vector3(inst.Transform:GetWorldPosition())
  trace("    near", pt)

  local spawn_pt = GetSpawnPoint(pt)
  if spawn_pt then
	trace("    at", spawn_pt)
	local berk = SpawnPrefab("forest/animals/berk")
	if berk then
	  berk.Physics:Teleport(spawn_pt:Get())
	  berk:FacePoint(pt.x, pt.y, pt.z)

	  return berk
	end

  else
	-- this is not fatal, they can try again in a new location by picking up the bone again
	trace("berk_crown - SpawnBerk: Couldn't find a suitable spawn point for berk")
  end
end

local function StopRespawn(inst)
  trace("berk_crown - StopRespawn")
  if inst.respawntask then
	inst.respawntask:Cancel()
	inst.respawntask = nil
	inst.respawntime = nil
  end
end

local function RebindBerk(inst, berk)
  berk = berk or TheSim:FindFirstEntityWithTag("berk")
  if berk then

	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.components.inventoryitem:ChangeImageName(inst.openEye)
	inst:ListenForEvent("death", function() inst:OnBerk() end, berk)

	if berk.components.follower.leader ~= inst then
	  berk.components.follower:SetLeader(inst)
	end
	return true
  end
end

local function RespawnBerk(inst)
  trace("berk_crown - RespawnBerk")

  StopRespawn(inst)

  local berk = TheSim:FindFirstEntityWithTag("berk")
  if not berk then
	berk = SpawnBerk(inst)
  end
  RebindBerk(inst, berk)
end

local function StartRespawn(inst, time)
  StopRespawn(inst)

  local respawntime = time or 0
  if respawntime then
	inst.respawntask = inst:DoTaskInTime(respawntime, function() RespawnBerk(inst) end)
	inst.respawntime = GetTime() + respawntime
	inst.AnimState:PlayAnimation("dead", true)
	inst.components.inventoryitem:ChangeImageName(inst.closedEye)
  end
end

local function OnBerkDeath(inst)
  StartRespawn(inst, TUNING.TOTAL_DAY_TIME)
end

local function FixBerk(inst)
  inst.fixtask = nil
  --take an existing berk if there is one
  if not RebindBerk(inst) then
	inst.AnimState:PlayAnimation("dead", true)
	inst.components.inventoryitem:ChangeImageName(inst.closedEye)

	if inst.components.inventoryitem.owner then
	  local time_remaining = 0
	  local time = GetTime()
	  if inst.respawntime and inst.respawntime > time then
		time_remaining = inst.respawntime - time		
	  end
	  StartRespawn(inst, time_remaining)
	end
  end
end

local function OnPutInInventory(inst)
  if not inst.fixtask then
	inst.fixtask = inst:DoTaskInTime(1, function() FixBerk(inst) end)	
  end
end

local function OnSave(inst, data)
  trace("berk_crown - OnSave")
  local time = GetTime()
  if inst.respawntime and inst.respawntime > time then
	data.respawntimeremaining = inst.respawntime - time
  end
end


local function OnLoad(inst, data)

  if data and data.respawntimeremaining then
	inst.respawntime = data.respawntimeremaining + GetTime()
  end
end

local function GetStatus(inst)
  trace("berk_crown - GetStatus")
  if inst.respawntask then
	return "WAITING"
  end
end


local function onequip(inst, owner)
  print("Putting on hat")
  owner.AnimState:OverrideSymbol("swap_hat", "hat_flower", "swap_hat")
  owner.AnimState:Show("HAT")
  owner.AnimState:Hide("HAT_HAIR")
  owner.AnimState:Show("HAIR_NOHAT")
  owner.AnimState:Show("HAIR")

  owner.AnimState:Show("HEAD")
  owner.AnimState:Hide("HEAD_HAIR")
end

local function onunequip(inst, owner)
  owner.AnimState:Hide("HAT")
  owner.AnimState:Hide("HAT_HAIR")
  owner.AnimState:Show("HAIR_NOHAT")
  owner.AnimState:Show("HAIR")

  if owner:HasTag("player") then
	owner.AnimState:Show("HEAD")
	owner.AnimState:Hide("HEAD_HAIR")
  end
end


local function fn(Sim)
  local inst = CreateEntity()
  local trans = inst.entity:AddTransform()
  local anim = inst.entity:AddAnimState()
  MakeInventoryPhysics(inst)
  print("building berk's crown now!")

  anim:SetBank("flowerhat")
  anim:SetBuild("hat_flower")
  anim:PlayAnimation("anim")

  inst:AddTag("hat")
  inst:AddTag("berk_crown")

  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")
  inst.components.inventoryitem.imagename = "berk_crown"
  inst.components.inventoryitem.atlasname = "images/inventoryimages/berk_crown.xml"

  inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory) -- from chester_eyebone.lua

  inst:AddComponent("equippable")
  inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
  inst.components.equippable:SetOnEquip( onequip )
  inst.components.equippable:SetOnUnequip( onunequip )

  inst:AddComponent("dapperness")
  inst.components.dapperness.dapperness = TUNING.DAPPERNESS_TINY


  print("Finished building")
  return inst
end

return Prefab("common/inventory/berk_crown", fn, assets, prefabs)
