if Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
end
---------- Variaveis ---------
local endCoolDown=os.time()

local jewelsCooldown = {}
for _, v in pairs(JewelryShowcase) do
	jewelsCooldown[v.id] = os.time()
end

RegisterServerEvent('dgl_jewelry:syncPainting')
AddEventHandler('dgl_jewelry:syncPainting', function(x)
    TriggerClientEvent('dgl_jewelry:client:syncPainting', -1, x)
end)

RegisterServerEvent('dgl_jewelry:rewardItem')
AddEventHandler('dgl_jewelry:rewardItem', function(scene)
	local src = source
	local playerName =''
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addInventoryItem(Config.ItemPaint, Config.PaintingAmount)--use give item players inventory full ?
		playerName = xPlayer.getName()
    elseif Config.Framework == 'qb' then
        -------------
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddItem(Config.ItemPaint, Config.PaintingAmount)
        TriggerClientEvent("inventory:client:ItemBox", Player.PlayerData.source, QBCore.Shared.Items[Config.ItemPaint], "add")

		-- Registro de log no Discord
		local Player = QBCore.Functions.GetPlayer(src)
		playerName = Player.PlayerData.name
	end
	local title = "> Painting Robbed"
	local description = "**Item name:** " .. "`" .. Config.ItemPaint .. "`" .."\n**Amount:** " .. Config.PaintingAmount
			
		
	DiscordLog(src, title, description, playerName)
	TriggerClientEvent("dgl_jewelry:notif", src, _L("give_reward") .. Config.PaintingAmount .. "x " .._L('PaintingName'), "success")
end)

----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKJEWELRY
-----------------------------------------------------------------------------------------------------------------------------------------
lib.callback.register('dgl_jewelry:checkJewelry', function(source)
    local src = source
    local coords = GetEntityCoords(GetPlayerPed(src))
	local count = 0
    if Config.Framework == 'esx' then
		local xPlayers = ESX.GetExtendedPlayers('job', 'police')
		count = #xPlayers
	elseif Config.Framework == 'qb' then
        local players = QBCore.Functions.GetPlayers()
		for _, playerId in pairs(players) do
			local Player = QBCore.Functions.GetPlayer(playerId)
			if Player.PlayerData.job.name == "police" then
				count = count + 1
			end
		end
	end
	if count < Config.MinimumPoliceToRob then
		local nbrPoliceNeeded = Config.MinimumPoliceToRob - count
		TriggerClientEvent("dgl_jewelry:notif", src, _L("need_police") .. _L("need_count") .. nbrPoliceNeeded, "error")
		return false

	elseif os.time() < endCoolDown then
		TriggerClientEvent("dgl_jewelry:notif", src, _L("cooldown"), "error")
		return false
	else
		local title = "> Robbery Started"
		local description = "**Location:** " .. "`" .. coords .. "`"
		
		DiscordLog(src, title, description, "")	
		return true
	end
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLPOLICE
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETMODEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("jewelrysetmodel")
AddEventHandler("jewelrysetmodel",function(x,y,z,prop1,prop2)
	TriggerClientEvent("jewelrysetmodel",-1,x,y,z,prop1,prop2)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKJEWELS
-----------------------------------------------------------------------------------------------------------------------------------------

lib.callback.register('dgl_jewelry:checkJewels', function(source, id)
    local src = source
	local savejewelCooldowne = jewelsCooldown[id]
	if os.time() < jewelsCooldown[id] then
		return 'cooldown' 
	end
	jewelsCooldown[id] = os.time() + Config.Cooldown -- set this asap to avoid concurrency 
	local GiveItemStatus = Give_item(src)
	if GiveItemStatus ~= true then --reset to previous cooldown because item cound'nt be given 
		jewelsCooldown[id] = savejewelCooldowne
		return GiveItemStatus
	end
	TriggerClientEvent('jewel:client:syncBoxs', -1, id)
	return true
		
end)


---- POLICE ALERT
RegisterServerEvent('dgl_jewelry:PoliceAlertStandalone')
AddEventHandler('dgl_jewelry:PoliceAlertStandalone', function()
    local src = source

    if Config.Framework == 'esx' then
		local xPlayers = ESX.GetExtendedPlayers('job', 'police')
		local chance = math.random(1, 100) -- Enter a random number between 1 and 100

        for i=1, #xPlayers, 1 do
            
            if chance <= Config.Dispatch.ChanceToAlertPolice then
				TriggerClientEvent('dgl_jewelry:setBlip', xPlayers[i].source)
				--TriggerClientEvent('esx:showNotification', xPlayers[i], _L("notif_police"))
				--TriggerClientEvent('stoned-atmrob:callPolice')
            end
        end
    elseif Config.Framework == 'qb' then

        local players = QBCore.Functions.GetPlayers()
        local coords = GetEntityCoords(GetPlayerPed(src))

        for _, playerId in ipairs(players) do
            local Player = QBCore.Functions.GetPlayer(playerId)
            local chance = math.random(1, 100) -- Gera um número aleatório entre 1 e 100
            if chance <= Config.Dispatch.ChanceToAlertPolice then
                if Player and Player.PlayerData.job.name then
                    TriggerClientEvent('QBCore:Notify', playerId, _L("notif_police"))
                    TriggerClientEvent('dgl_jewelry:setBlip', playerId, coords)
                    --TriggerClientEvent('stoned-atmrob:callPolice')
                end
            end
        end
    end
end)

GlobalState.doors = Config.doors	
GlobalState.lasers = {status = false, visibility = false}

RegisterServerEvent("dgl_jewelry:openDoorsActivateLasers")
AddEventHandler("dgl_jewelry:openDoorsActivateLasers", function()
	local doors = GlobalState.doors
	doors.jewelry1_l.locked = 0
	doors.jewelry1_r.locked = 0
	GlobalState.doors = doors
	GlobalState.lasers = {status = true, visibility = false}
	SetTimeout(Config.Cooldown*1000, function () --reset
		doors.jewelry1_l.locked = 1
		doors.jewelry1_r.locked = 1
		GlobalState.doors = doors
		GlobalState.lasers = {status = false, visibility = false}
	end)
end)

RegisterServerEvent("dgl_jewelry:setLasersVisibility")
AddEventHandler("dgl_jewelry:setLasersVisibility", function(visible)
	GlobalState.lasers = {status = GlobalState.lasers.status, visibility = visible}-- GlobalState.lasers.status
end)

lib.callback.register("dgl_jewelry:deactivateLasers", function(source)
	if GlobalState.lasers.status then
		GlobalState.lasers = {status = false, visibility = false}
		return true
	else
		return false
	end
	
end)

Give_item = function(source)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        --local randomItem = math.random(#Config.Rewards)
        -- item = Config.Rewards[randomItem].item
        local quantity = math.random(Config.Rewards.amount[1], Config.Rewards.amount[2])
        local joie = Config.Rewards[math.random(5)]
		if not xPlayer.canCarryItem(joie.item, quantity) then
			return 'inv full'
		end
		xPlayer.addInventoryItem(joie.item, quantity)
		TriggerClientEvent("dgl_jewelry:notif", source, _L("give_reward") ..quantity.."x " ..joie.name, "success")
			-- Registro de log no Discord
		local playerName = xPlayer.getName()
		local steamName = GetPlayerName(source)
		local identifier = tostring(source)
		local discord = "No Discord Info"
		local identifiers = GetPlayerIdentifiers(source)
		local ident = "No Identifier"
		local steamProfileLink = "https://steamcommunity.com/profiles/"
		local steamHex = "No Steam Hex Info"
		local timestamp = os.date("%A, %B %d, %Y at %I:%M %p")
		for _, id in ipairs(identifiers) do
			if string.find(id, "discord:") then
				discord = id:gsub("discord:", "<@")
			elseif string.find(id, "steam:") then
				steamHex = id:gsub("steam:", "")
				steamProfileLink = steamProfileLink .. tonumber(steamHex, 16)
			elseif string.find(id, "license:") then
				ident = id:gsub("license:", "")
			end
		end
	
		local information = {
			{
				color = "16776960",
				author = {
					name = Logs.ServerName .. " - Jewelry Robbery",
					icon_url = Logs.IconURL,
				},
				title = "> Jewels Robbed",
				description = "**Item name:** " .. "`" .. joie.item .. "`" ..  "\n**Amount:** " .. quantity.. "\n\n> **Player Information:**\n\n **Character Name**: " .. playerName .. " | **Name Steam:** " .. steamName .. "\n**ID IN-GAME:** " .. identifier .. "\n**Discord:** " .. discord .. "> " .. "\n**Identifier:** " .. ident .. "\n**Steam Profile:** [Click here](" .. steamProfileLink .. ")",
				footer = {
					text = 'Stoned Scripts' .. " | " .. timestamp,
					icon_url = "https://cdn.discordapp.com/attachments/1110843596753612901/1111289432348315718/aa586f1d0a95730f4fbc88ba884d7b9fe1afd5dd.png"
				}
			}
		}
	
		PerformHttpRequest(Logs.Webhook, function(err, text, headers) end, "POST", json.encode({ username = Logs.BotName, embeds = information }), { ["Content-Type"] = "application/json" })
		return true
    elseif Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        local joie = Config.Rewards[math.random(5)]
        Player.Functions.AddItem(joie.item, 1, false, {
            quantity = math.random(Config.Rewards.amount[1], Config.Rewards.amount[2])
        })
        TriggerClientEvent("inventory:client:ItemBox", Player.PlayerData.source, QBCore.Shared.Items[Config.RewardItem], "add")
        --------
                -- Registro de log no Discord
                local playerName = Player.getName()
                local steamName = GetPlayerName(source)
                local identifier = tostring(source)
                local discord = "No Discord Info"
                local identifiers = GetPlayerIdentifiers(source)
                local ident = "No Identifier"
        
                local steamHex = "No Steam Hex Info"
                for _, id in ipairs(GetPlayerIdentifiers(source)) do
                    if string.find(id, "discord:") then
                        discord = id:gsub("discord:", "<@")
                    elseif string.find(id, "steam:") then
                        steamHex = id:gsub("steam:", "")
                    end
                end
        
                for _, id in ipairs(identifiers) do
                    if string.find(id, "license:") then
                        ident = id:gsub("license:", "")
                        break
                    end
                end
        
                local timestamp = os.date("%A, %B %d, %Y at %I:%M %p")
                local footer = {
                    text = 'Stoned Scripts' .. " | " .. timestamp,
                    icon_url = "https://cdn.discordapp.com/attachments/1110843596753612901/1111289432348315718/aa586f1d0a95730f4fbc88ba884d7b9fe1afd5dd.png"
                }

                
                local steamProfileLink = "https://steamcommunity.com/profiles/"
                if steamHex ~= "No Steam Hex Info" then
                    steamProfileLink = steamProfileLink .. tonumber(steamHex, 16)
                end

        
                local information = {
                    {
                        color = "16776960",
                        author = {
                            name = Logs.ServerName .. " - Jewelry Robbery",
                            icon_url = Logs.IconURL,
                        },
                        title = "> Jewels Robbed",
                        description = "**Item name:** " .. "`" .. joie.item .. "`" .. "\n**Amount:** " .. quantity .. "\n\n> **Player Information:**\n\n **Character Name**: " .. playerName .. " | **Name Steam:** " .. steamName .. "\n**ID IN-GAME:** " .. identifier .. "\n**Discord:** " .. discord .. "> " .. "\n**Identifier:** " .. ident .. "\n**Steam Profile:** [Click here](" .. steamProfileLink .. ")",
                        footer = footer
                    }
                }
        
                PerformHttpRequest(Logs.Webhook, function(err, text, headers) end, "POST", json.encode({ username = Logs.BotName, embeds = information }), { ["Content-Type"] = "application/json" })
                
    end      
end
if Config.Framework == 'esx' then
	ESX.RegisterUsableItem("spray", function(source)
		TriggerClientEvent('dgl_jewelry:startSpray', source)
	end)
	lib.callback.register('dgl_jewelry:checkItem', function(source, itemname)
		
		local xPlayer = ESX.GetPlayerFromId(source)
		local item = xPlayer.hasItem(itemname)
		if item then
			xPlayer.removeInventoryItem(itemname, 1)
			return true
		else
			local title = "> cheater jewelry "
			local description = "To be banned :=) @admin"--tag admin here
			
			DiscordLog(source, title, description, xPlayer.getName())
			xPlayer.kick("you are a cheater")
			return false
		end
	end)
elseif Config.Framework == 'qb' then
	QBCore.Functions.CreateUseableItem('spray', function(source, item)
		local Player = QBCore.Functions.GetPlayer(source)
		if not Player.Functions.GetItemByName(item.name) then return end
		TriggerClientEvent('dgl_jewelry:startSpray', source)
	end)
	lib.callback.register('dgl_jewelry:checkItem', function(source, itemname)
		local Player = QBCore.Functions.GetPlayer(source)
		if not Player.Functions.GetItemByName(itemname) then return end
		QBCore.Functions.UseItem(source, itemname)
		return true
	end)
end