Framework = Config.Framework == "qb" and exports['qb-core']:GetCoreObject() or exports['es_extended']:getSharedObject()

function registerServerCallback(...)
	if Config.Framework == "qb" then
		Framework.Functions.CreateCallback(...)
	else
		Framework.RegisterServerCallback(...)
	end
end

registerServerCallback("aty_pausemenu:getPlayerData", function(src, cb)
    local xPlayer = Config.Framework == "esx" and Framework.GetPlayerFromId(src) or Framework.Functions.GetPlayer(src)
    playerId = src
    players = GetPlayers()
    playerCount = #players
    maxPlayers = GetConvarInt("sv_maxclients", 48)

    if Config.Framework == "esx" then
        cash = xPlayer.getAccount("money").money
        bank = xPlayer.getAccount("bank").money
        name = xPlayer.getName()
        job = xPlayer.getJob().label
        grade = xPlayer.getJob().grade_label
        if xPlayer.variables.sex == 1 then gender = "Female" else gender = "Male" end
    else
        cash = xPlayer.PlayerData.money.cash
        bank = xPlayer.PlayerData.money.bank
        job = xPlayer.PlayerData.job.label
        name = xPlayer.PlayerData.firstname.." "..xPlayer.PlayerData.lastname
        grade = xPlayer.PlayerData.job.grade.name
        gender = xPlayer.PlayerData.gender
    end

    cb({id = playerId, players = playerCount, maxPlayers = maxPlayers, bank = bank, wallet = cash, name = name, gender = gender, job = job, grade = grade})
end)