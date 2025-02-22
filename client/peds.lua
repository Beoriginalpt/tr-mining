local QBCore = exports['qb-core']:GetCoreObject()
local ClassicBossPed = MiningJob.Boss
local ClassicBoss = MinerDepo.coords
local ClassicBHash = MiningJob.BossHash
local ClassicMiner = MiningLocation.coords
local ClassicPed = MiningJob.Miner
local ClassicMHash = MiningJob.MinerHash
local ClasWashericPed = MiningJob.Washer
local notClasHashsic = MiningJob.WasherHash
local TRonTop = WashLocation.coords
local ClassicSeller = SellLocation.coords

CreateThread(function()
    RequestModel( GetHashKey( ClassicPed ) )
    while ( not HasModelLoaded( GetHashKey( ClassicPed ) ) ) do
        Wait(1)
    end
    RequestModel( GetHashKey( ClasWashericPed ) )
    while ( not HasModelLoaded( GetHashKey( ClasWashericPed ) ) ) do
        Wait(1)
    end
    RequestModel( GetHashKey( ClassicBossPed ) )
    while ( not HasModelLoaded( GetHashKey( ClassicPed ) ) ) do
        Wait(1)
    end
    Miner1 = CreatePed(1, ClassicMHash, ClassicMiner, false, true)
    Miner2 = CreatePed(1, notClasHashsic, TRonTop, false, true)
    Miner3 = CreatePed(1, ClassicMHash, ClassicSeller, false, true)
    Miner4 = CreatePed(1, ClassicBHash, ClassicBoss, false, true)
    SetEntityInvincible(Miner1, true)
    SetBlockingOfNonTemporaryEvents(Miner1, true)
    FreezeEntityPosition(Miner1, true)
    SetEntityInvincible(Miner2, true)
    SetBlockingOfNonTemporaryEvents(Miner2, true)
    FreezeEntityPosition(Miner2, true)
    SetEntityInvincible(Miner3, true)
    SetBlockingOfNonTemporaryEvents(Miner3, true)
    FreezeEntityPosition(Miner3, true)
    SetEntityInvincible(Miner4, true)
    SetBlockingOfNonTemporaryEvents(Miner4, true)
    FreezeEntityPosition(Miner4, true)
end)