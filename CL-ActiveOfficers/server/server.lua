local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback("CL-ActiveOfficers:GetOfficers", function(source, cb)
    local ActiveOfficers = {}
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == "police" then
            table.insert(ActiveOfficers, {
                name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
                badgeNumber = v.PlayerData.metadata["callsign"],
                rank = v.PlayerData.job.grade.name,
                onDuty = v.PlayerData.job.onduty,
            })
        end
    end
    cb(ActiveOfficers)
end)

RegisterNetEvent("CL-ActiveOfficers:SetCallsign", function(callsign)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("callsign", callsign)
end)