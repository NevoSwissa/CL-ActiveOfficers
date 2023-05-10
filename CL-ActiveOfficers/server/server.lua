local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback("CL-ActiveOfficers:GetOfficers", function(source, cb)
    local ActiveOfficers = {}
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == "police" then
            local source = v.PlayerData.source,
            table.insert(ActiveOfficers, {
                name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
                badgeNumber = v.PlayerData.metadata["callsign"],
                rank = v.PlayerData.job.grade.name,
                gradeLevel = v.PlayerData.job.grade,
                onDuty = v.PlayerData.job.onduty,
                radioChannel = GetRadioChannel(source),
            })
        end
    end
    table.sort(ActiveOfficers, function(a, b)
        return a.gradeLevel > b.gradeLevel
    end)
    cb(ActiveOfficers)
end)

RegisterNetEvent("CL-ActiveOfficers:SetCallsign", function(callsign)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("callsign", callsign)
end)

function GetRadioChannel(source)
    return Player(source).state['radioChannel']
end