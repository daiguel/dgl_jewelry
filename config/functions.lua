
--███╗░░██╗░█████╗░████████╗██╗███████╗██╗░█████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
--████╗░██║██╔══██╗╚══██╔══╝██║██╔════╝██║██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
--██╔██╗██║██║░░██║░░░██║░░░██║█████╗░░██║██║░░╚═╝███████║░░░██║░░░██║██║░░██║██╔██╗██║
--██║╚████║██║░░██║░░░██║░░░██║██╔══╝░░██║██║░░██╗██╔══██║░░░██║░░░██║██║░░██║██║╚████║
--██║░╚███║╚█████╔╝░░░██║░░░██║██║░░░░░██║╚█████╔╝██║░░██║░░░██║░░░██║╚█████╔╝██║░╚███║
--╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝

function SendTextMessagee(msg, type)
    if type == 'inform' then
		lib.notify({description=msg, title=_L('jewelry_robbery'), duration=7000, type='info'})
        --TriggerEvent('codem-notification:Create', msg, 'info', _L('jewelry_robbery'), 7000)
		--exports['Roda_Notifications']:showNotify(msg, 'info', 5000)
		--exports['okokNotify']:Alert("Craft", msg, 5000, 'info')
		--exports['mythic_notify']:SendAlert('inform', msg)
		--QBCore.Functions.Notify(msg, 'info')
    end
    if type == 'error' then
        lib.notify({description=msg, title=_L('jewelry_robbery'), duration=7000, type='error'})
		--TriggerEvent('codem-notification:Create', msg, 'error',  _L('jewelry_robbery'), 7000)
		--exports['Roda_Notifications']:showNotify(msg, 'error', 5000)
		--exports['okokNotify']:Alert("Craft", msg, 5000, 'error')
		--exports['mythic_notify']:SendAlert('error', msg)
		--QBCore.Functions.Notify(msg, 'error')
    end
    if type == 'success' then
        lib.notify({description=msg, title=_L('jewelry_robbery'), duration=7000, type='success'})
		--TriggerEvent('codem-notification:Create', msg, 'success',  _L('jewelry_robbery'), 7000)
		--exports['Roda_Notifications']:showNotify(msg, 'success', 5000)
		--exports['okokNotify']:Alert("Craft", msg, 5000, 'success')
		--exports['mythic_notify']:SendAlert('success', msg)
		--QBCore.Functions.Notify(msg, 'success')
    end
end

--██████╗ ██╗     ██╗██████╗ ███████╗     █████╗ ███╗   ██╗██████╗      ██████╗ █████╗ ██╗     ██╗     ███████╗██╗ ██████╗ ███╗   ██╗
--██╔══██╗██║     ██║██╔══██╗██╔════╝    ██╔══██╗████╗  ██║██╔══██╗    ██╔════╝██╔══██╗██║     ██║     ██╔════╝██║██╔════╝ ████╗  ██║
--██████╔╝██║     ██║██████╔╝███████╗    ███████║██╔██╗ ██║██║  ██║    ██║     ███████║██║     ██║     ███████╗██║██║  ███╗██╔██╗ ██║
--██╔══██╗██║     ██║██╔═══╝ ╚════██║    ██╔══██║██║╚██╗██║██║  ██║    ██║     ██╔══██║██║     ██║     ╚════██║██║██║   ██║██║╚██╗██║
--██████╔╝███████╗██║██║     ███████║    ██║  ██║██║ ╚████║██████╔╝    ╚██████╗██║  ██║███████╗███████╗███████║██║╚██████╔╝██║ ╚████║
--╚═════╝ ╚══════╝╚═╝╚═╝     ╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝      ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝      

function PoliceCall()
	if Config.Dispatch.Type == 'standalone' then
		TriggerServerEvent('dgl_jewelry:PoliceAlertStandalone')
	elseif Config.Dispatch.Type == 'linden_alerts' then
		TriggerServerEvent('dgl_jewelry:server:PoliceAlertMessage') 
	elseif Config.Dispatch.Type == 'qb_defaultalert' then
    	TriggerServerEvent('police:server:policeAlert', 'Attempted Jewelry Robbery')
    elseif Config.Dispatch.Type == 'cd_dispatch' then
		local data = exports['cd_dispatch']:GetPlayerInfo()
		TriggerServerEvent('cd_dispatch:AddNotification', {
			job_table = {'police', "sheriff" }, 
			coords = data.coords,
			title = '10-15 - Jewelry Robbery',
			message = 'A '..data.sex..' Robbing Jewelry at '..data.street, 
			flash = 0,
			unique_id = data.unique_id,
			sound = 1,
			blip = {
				sprite = Config.Dispatch.BlipSprite, 
				scale = Config.Dispatch.BlipScale, 
				colour = Config.Dispatch.BlipColor,
				flashes = false, 
				text = '911 - Jewelry Robbery',
				time = 5,
				radius = 0,
			}
		})
	end
end

function DiscordLog(src, title, description, playerName)
    local steamName = GetPlayerName(src)
	local identifier = tostring(src)
	local discord = "No Discord Info"
	local identifiers = GetPlayerIdentifiers(src)
	local ident = "No Identifier"
	local steamHex = "No Steam Hex Info"
	local steamProfileLink = "https://steamcommunity.com/profiles/"
	local timestamp = os.date("%A, %B %d, %Y at %I:%M %p")

	
	for _, id in ipairs(identifiers) do --make fucntion for this discord log 
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
			title = title,
			description = description .. "\n\n> **Player Information:**\n\n **Character Name**: " .. playerName .. " | **Name Steam:** " .. steamName .. "\n**ID IN-GAME:** " .. identifier .. "\n**Discord:** " .. discord .. "> " .. "\n**Identifier:** " .. ident .. "\n**Steam Hex:** " .. steamHex .. "\n**Steam Profile:** [Click here](" .. steamProfileLink .. ")" ,
			footer = {
				text = 'Stoned Scripts' .. " | " .. timestamp,
				icon_url = "https://cdn.discordapp.com/attachments/1110843596753612901/1111289432348315718/aa586f1d0a95730f4fbc88ba884d7b9fe1afd5dd.png"
			}
		}
	}

	PerformHttpRequest(Logs.Webhook, function(err, text, headers) end, "POST", json.encode({ username = Logs.BotName, embeds = information }), { ["Content-Type"] = "application/json" })

end
