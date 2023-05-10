local QBCore = exports['qb-core']:GetCoreObject()

local showUi = false

local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerData = QBCore.Functions.GetPlayerData()
    end
end)

RegisterNUICallback("HideUserInterface", function()
    if showUi then
        SetNuiFocus(false, false)
        showUi = false
    end
end)

RegisterNUICallback('setCallsign', function(data, cb)
    TriggerServerEvent("CL-ActiveOfficers:SetCallsign", data.callsign)
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        QBCore.Functions.TriggerCallback('CL-ActiveOfficers:GetOfficers', function(result)
            SendNUIMessage({
                action = 'RefreshList',
                activeOfficers = result,
            })
        end)
        Citizen.Wait(1000)
    end
end)

RegisterKeyMapping(GetCurrentResourceName(), 'Active Officers', 'keyboard', '8')

RegisterCommand(GetCurrentResourceName(), function()
    if PlayerData.job.type == "leo" then
        showUi = not showUi
        if showUi then
            QBCore.Functions.TriggerCallback('CL-ActiveOfficers:GetOfficers', function(result)
                local playerName = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname
                SendNUIMessage({
                    action = 'ShowUserInterface',
                    playerName = playerName,
                    playerRank = PlayerData.job.grade.name,
                    playerCallsign = PlayerData.metadata.callsign,
                    activeOfficers = result,
                })
                SetNuiFocus(true, true)
            end)
        end
    else
        QBCore.Functions.Notify('You dont have the required job', 'error')
    end
end)