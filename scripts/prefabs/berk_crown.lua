-- most of this is copied from 366720084

local assets = {
	Asset("ANIM", "anim/hat_flower.zip"),
	Asset("ATLAS", "images/inventoryimages/berk_crown.xml"),
	Asset("IMAGE", "images/inventoryimages/berk_crown.tex"),
}

local prefabs = {
}

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

	--inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory) -- from chester_eyebone.lua

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
