local QBCore = exports['qb-core']:GetCoreObject()
local miningZone = false
local isMining = false

RegisterNetEvent('tr-mining:getMiningstage', function(stage, state, k)
  Config.MiningLocation[k][stage] = state
end)

local function loadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
      RequestAnimDict(dict)
      Wait(3)
  end
end

local function pickaxeprop()
  local ped = PlayerPedId()
  local pedWeapon = GetSelectedPedWeapon(ped)
  for k, v in pairs(Config.trpickaxeprop) do
      if pedWeapon == k then
          return true
      end
  end
  QBCore.Functions.Notify(Config.Text["error_pickaxe"], 'error')
end

local function StartMining(mining)
  local animDict = "melee@hatchet@streamed_core"
  local animName = "plyr_rear_takedown_b"
  local trClassic = PlayerPedId()
  local miningtimer = MiningJob.MiningTimer
  isMining = true
  FreezeEntityPosition(trClassic, true)
  TriggerEvent('tr-mining:miningwithaxe')  
  QBCore.Functions.Progressbar("Mining....", Config.Text['Mining_ProgressBar'], miningtimer, false, true, {
      disableMovement = true,
      disableCarMovement = true,
      disableMouse = false,
      disableCombat = true,
  }, {}, {}, {}, function()
      TriggerServerEvent('tr-mining:setMiningStage', "isMined", true, k)
      TriggerServerEvent('tr-mining:setMiningStage', "isOccupied", false, k)
      TriggerServerEvent('tr-mining:receivedStone')
      TriggerServerEvent('tr-mining:setMiningTimer')
      isMining = false
      TaskPlayAnim(trClassic, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
      FreezeEntityPosition(trClassic, false)
  end, function()
      ClearPedTasks(trClassic)
      TriggerServerEvent('tr-mining:setMiningStage', "isOccupied", false, k)
      isMining = false
      TaskPlayAnim(trClassic, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
      FreezeEntityPosition(trClassic, false)
  end)
  TriggerServerEvent('tr-mining:setMiningStage', "isOccupied", true, mining)
  CreateThread(function()
      while isMining do
          loadAnimDict(animDict)
          TaskPlayAnim(trClassic, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
          Wait(3000)
      end
  end)
end

RegisterNetEvent('tr-mining:miningwithaxe')
AddEventHandler('tr-mining:miningwithaxe', function()
  local PlayerJob = QBCore.Functions.GetPlayerData().job
  if PlayerJob.name == "miner" then
    
        local ped = PlayerPedId()
        trpickaxeprop = CreateObject(GetHashKey("weapon_stone_hatchet"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(trpickaxeprop, ped, GetPedBoneIndex(ped, 57005), 0.17, -0.04, -0.04, 180, 100.00, 120.0, true, true, false, true, 1, true)
        Wait(MiningJob.MiningTimer)
        DetachEntity(trpickaxeprop, 1, true)
        DeleteEntity(trpickaxeprop)
        DeleteObject(trpickaxeprop)
        if not "miner" then 
          QBCore.Functions.Notify("Trabalhas nos mineiros?", "error", 4000)
    end
  end
  end)

RegisterNetEvent('tr-mining:getpickaxe', function()
  TriggerServerEvent('tr-mining:BuyPickaxe')
end)

RegisterNetEvent('tr-mining:getPan', function()
  TriggerServerEvent('tr-mining:BuyWash')
end)

RegisterNetEvent('tr-mining:minermenu', function()
local minermenu = {
  {
    header = Config.Text["MenuHeading"],
    isMenuHeader = true,
  },
    {
      header = Config.Text["MenuPickAxe"],
      txt = Config.Text["PickAxeText"],
      params = {
          event = 'tr-mining:getpickaxe',
        }
    },
    {
      header = Config.Text["goback"],
    },
  }
  exports['qb-menu']:openMenu(minermenu)
end)

RegisterNetEvent('tr-mining:panmenu', function()
local panmenu = {
  {
    header = Config.Text["WashHeading"],
    isMenuHeader = true,
  },
    {
      header = Config.Text["MenuWashPan"],
      txt = Config.Text["PanText"],
      params = {
          event = 'tr-mining:getPan',
        }
    },
    {
      header = Config.Text["goback"],
    },
  }
  exports['qb-menu']:openMenu(panmenu)
end)

RegisterNetEvent('tr-mining:smeltmenu', function()
  local smeltMenu = {
    {
      header = Config.Text["SmethHeading"],
      isMenuHeader = true,
    },
      {
        header = Config.Text["Semlt_Iron"],
        txt = Config.Text["smelt_IText"],
        params = {
            event = 'tr-mining:SmeltIron',
          }
      },
      {
        header = Config.Text["Semlt_Copper"],
        txt = Config.Text["smelt_CText"],
        params = {
            event = 'tr-mining:SmeltCopper',
          }
      },
      {
        header = Config.Text["Smelt_Gold"],
        txt = Config.Text["smelt_GText"],
        params = {
            event = 'tr-mining:SmeltGold',
          }
      },
      {
        header = Config.Text["goback"],
      },
    }
    exports['qb-menu']:openMenu(smeltMenu)
  end)

local listen = false
local function MiningKeyBind(mining)
  listen = true
  CreateThread(function()
    while listen do
      if IsControlJustPressed(0, 38) then
        listen = false
        if not Config.MiningLocation[mining]["isMined"] and not Config.MiningLocation[mining]["isOccupied"] then
          exports['qb-core']:KeyPressed()
          QBCore.Functions.TriggerCallback('tr-mining:pickaxe', function(PickAxe)
            if PickAxe then
              StartMining(mining)
            elseif not PickAxe then
              QBCore.Functions.Notify(Config.Text['error_mining'], 'error')
            end
          end)
        else
          exports['qb-core']:DrawText(Config.Text['error_alreadymined'], 'left')
        end
      end
      Wait(0)
    end
  end)
end

RegisterNetEvent('tr-mining:washingrocks', function()
  QBCore.Functions.TriggerCallback('tr-mining:washpan', function(washingpancheck)
    if washingpancheck then
      QBCore.Functions.TriggerCallback('tr-mining:stonesbruf', function(stonesbruf)
        if stonesbruf then
          local playerPed = PlayerPedId()
          local coords = GetEntityCoords(playerPed)
          local rockwash = MiningJob.WashingTimer
          TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_BUM_WASH', 0, false)
            QBCore.Functions.Progressbar('Washing Stones', Config.Text['Washing_Rocks'], rockwash, false, true, { -- Name | Label | Time | useWhileDead | canCancel
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
          }, {
          }, {}, {}, function() 
              ClearPedTasks(PlayerPedId())
              TriggerServerEvent("tr-mining:receivedReward")
          end, function() 
            QBCore.Functions.Notify(Config.Text['cancel'], "error")
          end)
        elseif not stonesbruf then
          QBCore.Functions.Notify(Config.Text['error_minerstone'], "error")
        end
      end)
    elseif not washingpancheck then
      Wait(500)
      QBCore.Functions.Notify(Config.Text['error_washpan'], "error", 3000)
    end
  end)
end)

RegisterNetEvent('tr-mining:SmeltIron', function()
  QBCore.Functions.TriggerCallback('tr-mining:IronCheck', function(IronCheck)
    if IronCheck then
      local iron = MiningJob.IronTimer
      TriggerEvent('animations:client:EmoteCommandStart', {"Warmth"})
      QBCore.Functions.Progressbar("smeltIron", Config.Text['smelt_iron'], iron, false, true, {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
          disableInventory = true,
      }, {}, {}, {}, function()
          TriggerEvent('animations:client:EmoteCommandStart', {"c"})
          TriggerServerEvent('tr-mining:IronBar')
      end, function() 
          ClearPedTasks(PlayerPedId())
          QBCore.Functions.Notify(Config.Text['cancel'], "error")
      end)
    elseif not IronCheck then
      QBCore.Functions.Notify(Config.Text['error_ironCheck'], "error", 3000)
    end
  end)
end)

RegisterNetEvent('tr-mining:SmeltCopper', function()
  QBCore.Functions.TriggerCallback('tr-mining:CopperCheck', function(CopperCheck)
    if CopperCheck then
      local copper = MiningJob.CopperTimer
      TriggerEvent('animations:client:EmoteCommandStart', {"Warmth"})
      QBCore.Functions.Progressbar("SmeltCopper", Config.Text['smelt_copper'], copper, false, true, {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
          disableInventory = true,
      }, {}, {}, {}, function()
          TriggerEvent('animations:client:EmoteCommandStart', {"c"})
          TriggerServerEvent('tr-mining:CopperBar')
      end, function() 
          ClearPedTasks(PlayerPedId())
          QBCore.Functions.Notify(Config.Text['cancel'], "error")
      end)
    elseif not CopperCheck then
      QBCore.Functions.Notify(Config.Text['error_goldCheck'], "error", 3000)
    end
  end)
end)

RegisterNetEvent('tr-mining:SmeltGold', function()
  QBCore.Functions.TriggerCallback('tr-mining:GoldCheck', function(GoldCheck)
    if GoldCheck then
      local gold = MiningJob.GoldTimer
      TriggerEvent('animations:client:EmoteCommandStart', {"Warmth"})
      QBCore.Functions.Progressbar("smeltGold", Config.Text['smelt_gold'], gold, false, true, {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
          disableInventory = true,
      }, {}, {}, {}, function()
          TriggerEvent('animations:client:EmoteCommandStart', {"c"})
          TriggerServerEvent('tr-mining:GoldBar')
      end, function() 
          ClearPedTasks(PlayerPedId())
          QBCore.Functions.Notify(Config.Text['cancel'], "error")
      end)
    elseif not GoldCheck then
      QBCore.Functions.Notify(Config.Text['error_goldCheck'], "error", 3000)
    end
  end)
end)

RegisterNetEvent('tr-mining:vehicle', function()
  local vehicle = MinerDepo.Vehicle
  local coords = MinerDepo.VehicleCoords
  local TR = PlayerPedId()
  RequestModel(vehicle)
  while not HasModelLoaded(vehicle) do
      Wait(0)
  end
  if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
      local JobVehicle = CreateVehicle(vehicle, coords, 45.0, true, false)
      SetVehicleHasBeenOwnedByPlayer(JobVehicle,  true)
      SetEntityAsMissionEntity(JobVehicle,  true,  true)
      exports['ps-fuel']:SetFuel(JobVehicle, 100.0)
      local id = NetworkGetNetworkIdFromEntity(JobVehicle)
      DoScreenFadeOut(1500)
      Wait(1500)
      SetNetworkIdCanMigrate(id, true)
      TaskWarpPedIntoVehicle(TR, JobVehicle, -1)
      TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(JobVehicle))
      DoScreenFadeIn(1500)
      Wait(2000)
      TriggerServerEvent('qb-phone:server:sendNewMail', {
          sender = Config.Text["phone_sender"],
          subject = Config.Text["phone_subject"],
          message = Config.Text["phone_message"],
          })
  else
      QBCore.Functions.Notify(Config.Text["depo_blocked"], "error")
  end
end)

RegisterNetEvent('tr-mining:removevehicle', function()
  local TR92 = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(TR92,true)
  DeleteVehicle(vehicle)
  QBCore.Functions.Notify(Config.Text["depo_stored"])
end)

RegisterNetEvent('tr-mining:bossmenu', function()
  local vehicle = {
    {
      header = Config.Text["vehicle_header"],
      isMenuHeader = true,
    },
    {
        header = Config.Text["vehicle_get"],
        txt = Config.Text["vehicle_text"],
        params = {
            event = 'tr-mining:vehicle',
          }
    },
    {
        header = Config.Text["vehicle_remove"],
        txt = Config.Text["remove_text"],
        params = {
            event = 'tr-mining:removevehicle',
          }
    },
    {
      header = Config.Text["goback"],
    },
  }
exports['qb-menu']:openMenu(vehicle)
end)

CreateThread(function()
  for k, v in pairs(Config.MiningLocation) do
    exports["qb-target"]:AddBoxZone("shaftZones" .. k, v.coords, 3.5, 3, {
      name = "mineshaft"..k,
      heading = 15,
      minZ = v.coords["z"] - 1,
      maxZ = v.coords["z"] + 1,
      debugPoly = false
    }, {
      options = {
      {
        action = function()
          if pickaxeprop() then
            StartMining(k)
          end
        end,
        type = "client",
        event = "tr-mining:StartMining",
        icon = "Fas Fa-hands",
        label = Config.Text['StartMining'],
        job = "miner",
        canInteract = function()
          if v["isMined"] or v["isOccupied"] then
              return false
          end
          return true
        end,
      }
      },
      distance = 1.5
    })
    -- shaftZones:onPlayerInOut(function(isPointInside)
    --   if PlayerData.job == miner then
    --   if isPointInside then
    --     exports['qb-core']:DrawText(Config.Text['MiningAlert'], 'left')
    --     Wait(1500)
    --     exports['qb-core']:HideText()
    --     Wait(1000)
    --     exports['qb-core']:DrawText(Config.Text['StartMining'],'left')
    --     MiningKeyBind(k)
    --   else
    --     listen = false
    --     exports['qb-core']:HideText()
    --   end
     end
    -- end)
  -- end

  exports['qb-target']:AddBoxZone("MinerDepo", MinerDepo.targetZone, 1, 1, {
    name = "MinerDepo",
    heading = MinerDepo.targetHeading,
    debugPoly = false,
    minZ = MinerDepo.minZ,
    maxZ = MinerDepo.maxZ,
}, {
    options = {
    {
      type = "client",
      event = "tr-mining:bossmenu",
      icon = "Fas Fa-hands",
      label = Config.Text["depo_label"],
      job = "miner",
    },
    },
    distance = 1.0
})

  exports['qb-target']:AddBoxZone("MinerBoss", MiningLocation.targetZone, 1, 1, {
    name = "MinerBoss",
    heading = MiningLocation.targetHeading,
    debugPoly = false,
    minZ = MiningLocation.minZ,
    maxZ = MiningLocation.maxZ,
  }, {
    options = {
      {
        type = "client",
        event = "tr-mining:minermenu",
        icon = "Fas Fa-hands",
        label = Config.Text['MenuTarget'],
        job = "miner",
      },
    },
    distance = 1.5
  })

  exports['qb-target']:AddBoxZone("PanWasher", WashLocation.targetZone, 1, 1, {
    name = "PanWasher",
    heading = WashLocation.targetHeading,
    debugPoly = false,
    minZ = WashLocation.minZ,
    maxZ = WashLocation.maxZ,
  }, {
    options = {
      {
        type = "client",
        event = "tr-mining:panmenu",
        icon = "Fas Fa-hands",
        label = Config.Text['Menu_pTarget'],
        job = "miner",
      },
    },
    distance = 1.5
  })

  exports['qb-target']:AddBoxZone("Water", vector3(54.77, 3160.31, 25.62), 38.2, 8, {
    name = "Water",
    heading = 155,
    debugPoly = false,
    minZ=22.82,
    maxZ=26.62
  }, {
    options = {
      {
        type = "client",
        event = "tr-mining:washingrocks",
        icon = "Fas Fa-hands",
        label = Config.Text['Washing_Target'],
        job = "miner",
      },
    },
    distance = 3.0
  })

  exports['qb-target']:AddBoxZone("smelt", vector3(1086.38, -2003.69, 31.42), 3.8, 3, {
    name = "smelt",
    heading = 319,
    debugPoly = false,
    minZ = 31.42,
    maxZ = 32.22
  }, {
    options = {
      {
        type = "client",
        event = "tr-mining:smeltmenu",
        icon = "Fas Fa-hands",
        label = Config.Text['Smeth_Rocks'],
        job = "miner",
      },
    },
    distance = 2.5
  })

  exports['qb-target']:AddBoxZone("Seller", SellLocation.targetZone, 1, 1, {
    name = "Seller",
    heading = SellLocation.targetHeading,
    debugPoly = false,
    minZ = SellLocation.minZ,
    maxZ = SellLocation.maxZ,
  }, {
    options = {
      {
        type = "server",
        event = "tr-mining:Seller",
        icon = "Fas Fa-hands",
        label = Config.Text['Seller'],
        job = "miner",
      },
    },
    distance = 2.5
  })

end)
