local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

vSERVER = Tunnel.getInterface(GetCurrentResourceName())

local cfg = module(GetCurrentResourceName(), "config")
local tableWeapons = {}

-- Função para anexar uma arma ao jogador
function AttachWeaponToBack(key, value, bone, x, y, z, xR, yR, zR)
  local ped = PlayerPedId()

  if vSERVER.getWeaponAmount(value) then
    if not HasPedGotWeapon(ped, GetHashKey(value), false) then
      if not tableWeapons[key] and GetSelectedPedWeapon(ped) ~= GetHashKey(value) then
        AttachWeapon(key, value, bone, x, y, z, xR, yR, zR, isMeleeWeapon(key))
      end
    end
  end
end

Citizen.CreateThread(function()
  while true do
    local ped = PlayerPedId()

    local slotFull1 = false
    local slotFull2 = false

    for key, value in pairs(cfg['weaponHash']) do
      -- Anexar arma 1 as costas
      if slotFull1 == false then
        AttachWeaponToBack(key, value, cfg['back_bone'], cfg['x'], cfg['y'], cfg['z'], cfg['x_rotation'],
          cfg['y_rotation'], cfg['z_rotation'])

        slotFull1 = true

        -- Anexar arma 2 as costas
      elseif slotFull2 == false then
        AttachWeaponToBack(key, value, cfg['back_bone_second'], cfg['x_second'], cfg['y_second'], cfg['z_second'],
          cfg['x_rotation_second'], cfg['y_rotation_second'], cfg['z_rotation_second'])

        slotFull2 = true
      end
    end
    for key, value in pairs(tableWeapons) do
      if GetSelectedPedWeapon(ped) == GetHashKey(value['hash']) or not vSERVER.getWeaponAmount(value['hash']) then
        DeleteObject(value['handle'])
        if slotFull1 then
          slotFull1 = false
        elseif slotFull2 then
          slotFull2 = false
        end
        tableWeapons[key] = nil
      end
    end
    if auth then
      ClearAreaOfObjects(GetEntityCoords(ped, false), 3.0, 0)
    end
    Wait(100)
  end
end)

function AttachWeapon(attachModel, modelHash, boneNumber, x, y, z, xR, yR, zR, isMelee)
  local ped = PlayerPedId()

  local bone = GetPedBoneIndex(ped, boneNumber)
  RequestModel(attachModel)
  while not HasModelLoaded(attachModel) do
    Wait(100)
  end

  tableWeapons[attachModel] = {
    hash = modelHash,
    handle = CreateObject(GetHashKey(attachModel), 1.0, 1.0, 1.0, true, true, false)
  }

  if isMelee then
    x = 0.11
    y = -0.14
    z = 0.0
    xR = -75.0
    yR = 185.0
    zR = 92.0
  end
  if attachModel == "prop_ld_jerrycan_01" then x = x + 0.3 end

  SetEntityCollision(tableWeapons[attachModel]['handle'], false, false)
  AttachEntityToEntity(tableWeapons[attachModel]['handle'], ped, bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
end

function isMeleeWeapon(object)
  if object == "prop_golf_iron_01" then
    return true
    --elseif object == "w_me_bat" then
    -- return true
  elseif object == "prop_ld_jerrycan_01" then
    return true
  end
  return false
end

RegisterNetEvent('player:otherPlayerEquipWeapon')
AddEventHandler('player:otherPlayerEquipWeapon', function(playerId, weaponHash)
  if playerId ~= PlayerId() then
    local ped = GetPlayerPed(playerId)
    if not HasPedGotWeapon(ped, GetHashKey(weaponHash), false) then
      if not tableWeapons[key] and GetSelectedPedWeapon(ped) ~= GetHashKey(weaponHash) then
        AttachWeapon(weaponHash, cfg['back_bone'], cfg['x'], cfg['y'], cfg['z'], cfg['x_rotation'], cfg['y_rotation'],
          cfg['z_rotation'])
        TriggerServerEvent('player:equipWeapon', weaponHash)
      end
    end
  end
end)
