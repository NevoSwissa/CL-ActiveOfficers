local QBCore = exports['qb-core']:GetCoreObject()

local isMainInterfaceActive = false

local isPlayerListActive = false

local activeOfficers = {}

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
    if isMainInterfaceActive then
        SetNuiFocus(false, false)
        isMainInterfaceActive = false
    end
end)

RegisterNUICallback('listActive', function(data, cb)
    if data.active == true then
        isPlayerListActive = true
        StartRefreshLoop()
    elseif data.active == false then
        isPlayerListActive = false
    end
end)

RegisterNUICallback('setCallsign', function(data, cb)
    TriggerServerEvent("CL-ActiveOfficers:SetCallsign", data.callsign)
end)

function UpdateActiveOfficersList()
    QBCore.Functions.TriggerCallback('CL-ActiveOfficers:GetOfficers', function(result)
        local hasChanges = #result ~= #activeOfficers or not IsSameOfficersList(result, activeOfficers)
        if not hasChanges then
            for i = 1, #result do
                local officer = result[i]
                local currentOfficer = activeOfficers[i]
                if officer.vehicleInfo and currentOfficer.vehicleInfo then
                    if officer.vehicleInfo.vehicleClass ~= currentOfficer.vehicleInfo.vehicleClass or officer.vehicleInfo.inVehicle ~= currentOfficer.vehicleInfo.inVehicle then
                        hasChanges = true
                        break
                    end
                elseif (officer.vehicleInfo and not currentOfficer.vehicleInfo) or (not officer.vehicleInfo and currentOfficer.vehicleInfo) then
                    hasChanges = true
                    break
                end
            end
        end

        if hasChanges then
            activeOfficers = result
            local updatedOfficers = {}
            for i = 1, #activeOfficers do
                local officer = activeOfficers[i]
                officer.vehicleInfo = GetPlayerVehicleInfo(officer.source)
                table.insert(updatedOfficers, officer)
            end
            SendNUIMessage({
                action = 'RefreshList',
                activeOfficers = updatedOfficers,
                colors = Config.Colors or {},
                useColors = Config.UseColors,
            })
        end
    end)
end

function IsSameOfficersList(list1, list2)
    if #list1 ~= #list2 then
        return false
    end
    for i = 1, #list1 do
        if not IsSameOfficer(list1[i], list2[i]) then
            return false
        end
    end
    return true
end

function IsSameOfficer(officer1, officer2)
    return officer1.name == officer2.name and officer1.badgeNumber == officer2.badgeNumber and officer1.rank == officer2.rank and officer1.gradeLevel == officer2.gradeLevel and officer1.onDuty == officer2.onDuty and officer1.radioChannel == officer2.radioChannel
end

function GetPlayerVehicleInfo(source)
    local playerPed = GetPlayerPed(GetPlayerFromServerId(source))
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle ~= 0 then
        local vehicleClass = GetVehicleClass(vehicle)
        local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        return {
            inVehicle = true,
            vehicleClass = vehicleClass,
            vehicleName = vehicleName
        }
    else
        return {
            inVehicle = false,
            vehicleClass = nil,
            vehicleName = nil
        }
    end
end

function StartRefreshLoop()
    Citizen.CreateThread(function()
        while isPlayerListActive do
            if PlayerData.job.name == "police" then
                UpdateActiveOfficersList()
            else
                SendNUIMessage({
                    action = 'CloseList',
                })
                isPlayerListActive = false
            end
            Citizen.Wait(1000)
        end
    end)
end

RegisterKeyMapping(GetCurrentResourceName(), 'Active Officers', 'keyboard', '8')

RegisterCommand(GetCurrentResourceName(), function()
    if PlayerData.job.name == "police" then
        isMainInterfaceActive = not isMainInterfaceActive
        if isMainInterfaceActive then
            UpdateActiveOfficersList()
            local playerName = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname
            SendNUIMessage({
                action = 'ShowUserInterface',
                playerName = playerName,
                playerRank = PlayerData.job.grade.name,
                playerCallsign = PlayerData.metadata.callsign,
                activeOfficers = activeOfficers,
                colors = Config.Colors or {},
                useColors = Config.UseColors,
            })
            SetNuiFocus(true, true)
        else
            SetNuiFocus(false, false)
        end
    end
end)