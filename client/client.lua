-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------

local paintingsRobbed = 0
local blipRobbery, cam = nil, nil
local drillObject, soundID = nil, nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO LOCAL DO ROUBO
-----------------------------------------------------------------------------------------------------------------------------------------
ArtHeist = {
    -- ['cuting'] = false,
    -- ['startPeds'] = {},
    -- ['sellPeds'] = {},
    -- ['cut'] = 0,
    ['objects'] = {},
    ['scenes'] = {},
    ['painting'] = {}
}

local lasers_instances = {}

if Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function createLasers()
    for index, v in ipairs(Config.lasers) do
        local laser = Laser.new(v.originPoint, v.targetPoint, v.options)
        
        laser.onPlayerHit(function(playerBeingHit, hitPos) --kill player TODO make kill npc
            if playerBeingHit then
                SetEntityHealth(cache.ped, 0)
            end
        end)
        if GlobalState.lasers then
            laser.setVisible(GlobalState.lasers.status)
            laser.setVisible(GlobalState.lasers.visibility)
        end
        lasers_instances[index] = laser 
    end
end

createLasers()

if Config.Framework == 'qb' then
	RegisterNetEvent('QBCore:Client:OnPlayerUnload')
	AddEventHandler('QBCore:Client:OnPlayerUnload', function()
		isLoggedIn = false
	end)

	RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
	AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
		isLoggedIn = true
	end)
elseif Config.Framework == 'esx' then
	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function(xPlayer)
		ESX.PlayerLoaded = true
        local doors = GlobalState.doors
        if not doors then
            return
        end
        for _, v in pairs(doors) do
            AddDoorToSystem(v.doorHash, v.model, v.coords)
            DoorSystemSetDoorState(v.doorHash, GlobalState.doors.jewelry1_l.locked)
        end
        for _, laser in ipairs(lasers_instances) do
            laser.setActive(GlobalState.lasers.status)
            laser.setVisible(GlobalState.lasers.visibility)
        end
	end)

	RegisterNetEvent('esx:onPlayerLogout')
	AddEventHandler('esx:onPlayerLogout', function()
		ESX.PlayerLoaded = false
	end)
end


RegisterNetEvent('jewel:client:syncBoxs')
AddEventHandler('jewel:client:syncBoxs', function(id)
    JewelryShowcase[id]["taken"] = true
    SetTimeout(Config.Cooldown*1000, function ()-- this will disable targetting and reduces server calls but not required
        JewelryShowcase[id]["taken"] = false
    end)
end)

RegisterNetEvent('dgl_jewelry:client:syncPainting')
AddEventHandler('dgl_jewelry:client:syncPainting', function(x)
    Config['ArtHeist']['painting'][x]['taken'] = true
    SetTimeout(Config.Cooldown*1000, function ()-- this will disable targetting and reduces server calls but not required
        Config['ArtHeist']['painting'][x]['taken'] = false
    end)
end)

--ESCREVENDO NO KEYPAD
local function startKeypad()
	local start_typing = vector3(-629.1620, -230.6844, 38.0570)
	--local interiorHash = GetInteriorFromEntity(PlayerPedId())
	while true do
		local distance = #(start_typing - GetEntityCoords(cache.ped))
		TaskGoStraightToCoord(cache.ped, start_typing, 1.0, -1, 38.7614, 0.1)
		if distance <= 0.1 then

			SetEntityHeading(cache.ped, 38.7614)
			break
		end
		Wait(200)
	end
	loadAnim('mp_heists@keypad@', 'enter')
	loadAnim('anim@heists@keypad@', 'idle_a')
	TaskPlayAnim(cache.ped, 'mp_heists@keypad@', 'enter', 4.0,-8.0, -1, 1572874, 0, 0, 0, 0)
	Wait(900)
	TaskPlayAnim(cache.ped, 'anim@heists@keypad@', 'idle_a', 8.0, -8.0, -1, 17825802, 0, 0, 0, 0)
	Wait(3000)
	TaskPlayAnim(cache.ped, 'anim@heists@keypad@', 'exit', 8.0, -8.0, -1, 17825802, 0, 0, 0, 0)
	Wait(1500)
	ClearPedTasks(cache.ped)
	--RefreshInterior(interiorHash)
	--limpando animacoes da memoria
	loadAnim('mp_heists@keypad@', 'enter', true)
	loadAnim('anim@heists@keypad@', 'idle_a', true)

end

--LOAD ANIMS
function loadAnim(animDict, animSet, boolean)
	if boolean then
		RemoveAnimDict(animDict)
		RemoveAnimSet(animSet)
		return
	end
	RequestAnimDict(animDict)
	RequestAnimSet(animSet)
	while not HasAnimDictLoaded(animDict) and not HasAnimDictLoaded(animSet) do
		Wait(50)
	end
end

local function enableCam(x, y, z, rot)
	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, rue)
    SetCamCoord(cam,x, y, z+0.5)
    SetCamRot(cam, 0.0, 0.0, rot)
    Wait(1500)
    if DoesCamExist(cam) then
        RenderScriptCams(false, true, 250, 1,0)
        DestroyCam(cam, false)
        return
	end
end

function StartHeist()
    for k, v in pairs(Config['ArtHeist']['painting']) do --spawn paintings 
        loadModel(v['object'])
        ArtHeist['painting'][k] = CreateObjectNoOffset(GetHashKey(v['object']), v['objectPos'], 1, 1, 0)
        SetEntityRotation(ArtHeist['painting'][k], 0, 0, v['objHeading'], 2, true)
    end

    while not RequestScriptAudioBank("ALARM_KLAXON_03", false, -1) do
        Wait(0)
    end
    local sound_id = GetSoundId()
    PlaySoundFromCoord(sound_id, "ALARMS_KLAXON_03_FAR", -629.3083, -230.7710, 38.6570, 0, true, 200, 0)
    if Config.TutorialRobbery then
        DrawScaleform('~w~JEWELRY ASSAULT', '~y~' .. _L('paint1'),1.5)
        enableCam(-625.0535, -228.1611, 38.0570, 86.9020)

        DrawScaleform('~w~JEWELRY ASSAULT', '~d~' .. _L('paint2'),1.5)
        enableCam(-623.2971, -227.1897, 38.0570, 342.2962)

        DrawScaleform('~w~JEWELRY ASSAULT', '~p~' .. _L('paint3'),1.5)
        enableCam(-620.7921, -233.8186, 38.0570, 165.5177)

        DrawScaleform('~w~JEWELRY ASSAULT', '~b~' .. _L('paint4'),1.5)
        enableCam(-619.2660, -233.0421, 38.0570, 266.1652)

        DrawScaleform('~r~JEWELRY ASSAULT', '~w~' .. _L('rob_jewels'),3)
        enableCam(-626.1003, -229.3944, 38.0570, 262.4148)

        Wait(7000)
        StopSound(sound_id)
    else
        Wait(7000)
        StopSound(sound_id)
    end


end

function HeistAnimation(sceneId)
    local ped = cache.ped
    local pedCo = GetEntityCoords(ped)
    local scenes = {false, false, false, false}
    local animDict = "anim_heist@hs3f@ig11_steal_painting@male@"
    local scene = Config['ArtHeist']['painting'][sceneId]
    loadAnimDict(animDict)

    for k, v in pairs(Config['ArtHeist']['objects']) do
        loadModel(v)
        ArtHeist['objects'][k] = CreateObject(GetHashKey(v), pedCo, 1, 1, 0)
    end

    ArtHeist['objects'][3] = ArtHeist['painting'][sceneId]

    for i = 1, 10 do
        ArtHeist['scenes'][i] = NetworkCreateSynchronisedScene(scene['scenePos']['x'], scene['scenePos']['y'], scene['scenePos']['z'] - 1.0, scene['sceneRot'], 2, true, false, 1065353216, 0, 1065353216)
        NetworkAddPedToSynchronisedScene(ped, ArtHeist['scenes'][i], animDict, 'ver_01_'..Config['ArtHeist']['animations'][i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddEntityToSynchronisedScene(ArtHeist['objects'][3], ArtHeist['scenes'][i], animDict, 'ver_01_'..Config['ArtHeist']['animations'][i][3], 1.0, -1.0, 1148846080)
        NetworkAddEntityToSynchronisedScene(ArtHeist['objects'][1], ArtHeist['scenes'][i], animDict, 'ver_01_'..Config['ArtHeist']['animations'][i][4], 1.0, -1.0, 1148846080)
        NetworkAddEntityToSynchronisedScene(ArtHeist['objects'][2], ArtHeist['scenes'][i], animDict, 'ver_01_'..Config['ArtHeist']['animations'][i][5], 1.0, -1.0, 1148846080)
    end

    -- ArtHeist['cuting'] = true -- this is maybe not synced /since can't cancel its ok 
    FreezeEntityPosition(ped, true)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][1])
    Wait(3000)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][2])
    lib.showTextUI(_L('cut'), {position = 'top-center', style = { marginTop = '35px' } })
    while true do
        if IsControlJustPressed(0, 38) then
            break
        end
        Wait(1)
    end

    NetworkStartSynchronisedScene(ArtHeist['scenes'][3])
    Wait(3000)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][4])
    while true do
        if IsControlJustPressed(0, 38) then
            break
        end
        Wait(1)
    end
    NetworkStartSynchronisedScene(ArtHeist['scenes'][5])
    Wait(3000)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][6])
    while true do
        if IsControlJustPressed(0, 38) then
            break
        end
        Wait(1)
    end
    NetworkStartSynchronisedScene(ArtHeist['scenes'][7])
    Wait(3000)
    while true do
        if IsControlJustPressed(0, 38) then
            break
        end
        Wait(1)
    end
    lib.hideTextUI()
    NetworkStartSynchronisedScene(ArtHeist['scenes'][9])
    Wait(1500)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][10])
    Wait(7500)
    TriggerServerEvent('dgl_jewelry:rewardItem', scene)
    ClearPedTasks(ped)
	FreezeEntityPosition(ped, false)
    RemoveAnimDict(animDict)
    for k, v in pairs(ArtHeist['objects']) do
        DeleteObject(v)
    end
    DeleteObject(ArtHeist['painting'][sceneId])
    ArtHeist['objects'] = {}
    ArtHeist['scenes'] = {}
    -- ArtHeist['cuting'] = false
    -- ArtHeist['cut'] = ArtHeist['cut'] + 1
    -- if ArtHeist['cut'] == #Config['ArtHeist']['painting'] then--this is bad
    --     TriggerServerEvent('dgl_jewelry:syncAllPainting')
    --     ArtHeist['cut'] = 0
    -- end
    paintingsRobbed = paintingsRobbed + 1
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end

function loadModel(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Citizen.Wait(50)
    end
end

function addBlip(coords, sprite, colour, text)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

AddEventHandler('onResourceStop', function (resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, v in pairs(ArtHeist['painting']) do
            DeleteObject(v)
        end
        for _, v in pairs(ArtHeist['objects']) do
            DeleteObject(v)
        end
        
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        local doors = GlobalState.doors
        if not doors then
            return
        end
        for _, v in pairs(doors) do
            AddDoorToSystem(v.doorHash, v.model, v.coords)
            DoorSystemSetDoorState(v.doorHash, GlobalState.doors.jewelry1_l.locked)
        end
    end
  end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUBANDO AS JOIAS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent('dgl_jewelry:setBlip')
AddEventHandler('dgl_jewelry:setBlip', function()
	blipRobbery = AddBlipForCoord(Locations['vangrob_start'].x, Locations['vangrob_start'].y, Locations['vangrob_start'].z)

	SetBlipSprite(blipRobbery, Config.Dispatch.BlipSprite)
	SetBlipScale(blipRobbery, Config.Dispatch.BlipScale)
	SetBlipColour(blipRobbery, Config.Dispatch.BlipColor)

	PulseBlip(blipRobbery)
    SetTimeout(180000, function ()--remove alert blip after 3 mnts 
        RemoveBlip(blipRobbery)
    end)

end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INICIANDO O ROUBO
-----------------------------------------------------------------------------------------------------------------------------------------
function Jewelrytheft(x, y, z, prop1, prop2, id)
    lib.requestNamedPtfxAsset('scr_jewelheist', 2000)
    Wait(300)
    ClearPedTasks(cache.ped)
    SetPtfxAssetNextCall("scr_jewelheist")
    StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", x, y, z, 0.0, 0.0, 0.0, 1.0, false, false, false, fals)
    loadAnimDict("missheist_jewel")
    if id <=10 then
        local random = math.random(1,2)
        if random == 1 then
            TaskPlayAnim(cache.ped, "missheist_jewel", "smash_case_tray_b", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
            PlaySoundFromCoord(-1, "Glass_Smash", x, y, z, "", 0, 0, 0)
            SetTimeout(1700, function()
                PlaySound(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                StopAnimTask(cache.ped, "missheist_jewel", "smash_case_tray_b", 1.0)
            end)
        else
            TaskPlayAnim(cache.ped, "missheist_jewel", "smash_case_necklace_skull", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
            -- TriggerEvent("progress",2000,"roubando")
            PlaySoundFromCoord(-1, "Glass_Smash", x, y, z, "", 0, 0, 0)
            SetTimeout(2000,function()
                PlaySound(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                StopAnimTask(cache.ped, "missheist_jewel", "smash_case_necklace_skull", 1.0)
                -- TriggerEvent('cancelando',false)
            end)
        end
        Wait(350)
        TriggerServerEvent("jewelrysetmodel", x, y, z, prop1, prop2)
    else
        local random = math.random(1,2)
        if random == 1 then
            TaskPlayAnim(cache.ped, "missheist_jewel", "smash_case_b", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
            -- TriggerEvent("progress",3800,"roubando")
            SetTimeout(3800,function()
                StopAnimTask(cache.ped, "missheist_jewel", "smash_case_b", 1.0 )
                TriggerEvent('cancelando',false)
            end)
            PlaySoundFromCoord(-1, "Glass_Smash", x, y, z, "", 0, 0, 0)
            SetTimeout(3200,function()
                PlaySound(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
            end)
        else
            TaskPlayAnim(cache.ped, "missheist_jewel", "smash_case_f", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
            -- TriggerEvent("progress", 2700, "roubando")
            SetTimeout(2700,function()
                StopAnimTask(cache.ped, "missheist_jewel", "smash_case_f", 1.0)
                TriggerEvent('cancelando',false)
            end)
            PlaySoundFromCoord(-1, "Glass_Smash", x, y, z, "", 0, 0, 0)
            SetTimeout(1800,function()
                PlaySound(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
            end)
        end
        Wait(350)
        TriggerServerEvent( "jewelrysetmodel", x, y, z, prop1, prop2)
    end
    RemoveAnimDict("missheist_jewel")
    RemoveNamedPtfxAsset("scr_jewelheist")
    -- FinishHeist()
end

RegisterNetEvent("jewelrysetmodel")
AddEventHandler("jewelrysetmodel",function(x, y, z, prop1, prop2)
	CreateModelSwap(x, y, z, 0.2, GetHashKey(prop1), GetHashKey(prop2), false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------

function DrawScaleform(bigMsg,smallMsg,time)
    CreateThread(function(...)
        local scaleform = RequestScaleformMovie("mp_big_message_freemode")
        while not HasScaleformMovieLoaded(scaleform) do
            Wait(0)
        end

        BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
        PushScaleformMovieMethodParameterString(bigMsg)
        PushScaleformMovieMethodParameterString(smallMsg)
        PushScaleformMovieMethodParameterInt(5)
        EndScaleformMovieMethod()

        local timer = GetGameTimer()
        while GetGameTimer() - timer < time * 1000 do
            Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255,255, 0, 0)
        end
    end)
end


RegisterNetEvent("dgl_jewelry:notif")
AddEventHandler("dgl_jewelry:notif", function(msg, type)
    SendTextMessagee(msg, type)
end)

function isNight()
	local hour = GetClockHours()
	if hour >= 0 and hour <= 6 then
	return true
	end
end

function RenableAllTargettingAndReset()
    FreezeEntityPosition(cache.ped, false)-- in case still cutting
    for _, sceneId in pairs(ArtHeist['painting'])do
        DeleteObject(sceneId)--remove paintings to avoid duplicate 
    end
    for _, v in pairs(Config['ArtHeist']['painting']) do
        v['taken'] = false
    end
    for _, v in pairs(JewelryShowcase) do
        if v['taken'] then
            CreateModelSwap(v.x, v.y, v.z, 0.2, GetHashKey(v.prop2), GetHashKey(v.prop1), false)
        end
        v['taken'] = false
        -- CreateModelSwap(v.x, v.y, v.z, 0.2, GetHashKey(v.prop2), GetHashKey(v.prop1), false)-- this is not wworking good how to reset glasse ? 
    end

    lib.notify({description="jewelry cooldown ended", type='info'})
end

AddStateBagChangeHandler('doors', 'global', function (bagName, key, value, reserved, replicated)
    for _, v in pairs(GlobalState.doors) do
        AddDoorToSystem(v.doorHash, v.model, v.coords) --not needed if no restart 
        DoorSystemSetDoorState(v.doorHash, value.jewelry1_l.locked)
    end
    if value.jewelry1_l.locked==1 then
        RenableAllTargettingAndReset()
    end
end)

AddStateBagChangeHandler('lasers', 'global', function (bagName, key, value, reserved, replicated)
    for _, laser in ipairs(lasers_instances) do
        laser.setActive(value.status)
        laser.setVisible(value.visibility)        
    end
end)

function DrillSafe()
    LocalPlayer.state.invBusy = true
    local val = {anim = { x = -631.8915, y=-238.0029, z=38.0768, w=315.3711}} 
    local anim = {dict = 'anim@heists@fleeca_bank@drilling', lib = 'drill_straight_idle'}
    FreezeEntityPosition(cache.ped, true)
    SetCurrentPedWeapon(cache.ped, GetHashKey("WEAPON_UNARMED"),true)
    Citizen.Wait(250)
    local objHash = GetHashKey('hei_prop_heist_drill')
    -- Load Anim:
    lib.requestAnimDict(anim.dict)
    -- Load Model:
    lib.requestModel(objHash)
    -- Set Pos & Heading:
    SetEntityCoords(cache.ped, val.anim.x, val.anim.y, val.anim.z-0.95)
    SetEntityHeading(cache.ped, val.anim.w)
    -- Anim:
    TaskPlayAnimAdvanced(cache.ped, anim.dict, anim.lib, val.anim.x, val.anim.y, val.anim.z, 0.0, 0.0, val.anim.w, 3.0, -4.0, -1, 2, 0, 0, 0 )
    -- Object:
    local object = CreateObject(objHash, val.anim.x, val.anim.y, val.anim.z+0.02, true, true, true)
    AttachEntityToEntity(object, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.0, 0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
    SetEntityAsMissionEntity(object, true, true)
    -- Sound:
    RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
    RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
    RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
    local soundID = GetSoundId()
    Citizen.Wait(100)
    PlaySoundFromEntity(soundID, "Drill", object, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
    Citizen.Wait(100)
    -- Particle FX:
    local ptfx = {dict = 'core', name = 'ent_anim_pneumatic_drill'}
    lib.requestNamedPtfxAsset(ptfx.dict)
    SetPtfxAssetNextCall(ptfx.dict)
    ptfx.effect = StartParticleFxLoopedOnEntity(ptfx.name, object, 0.0, -0.5, 0.0, 0.0, 0.0, 0.0, 0.9, 0, 0, 0)
    ShakeGameplayCam("ROAD_VIBRATION_SHAKE", 1.0)
    Citizen.Wait(100)
    -- Drilling Minigame:
    return object,soundID
end

function EndDrill()
    LocalPlayer.state.invBusy = false
    local ptfx = {dict = 'core', name = 'ent_anim_pneumatic_drill'}
    ClearPedTasksImmediately(cache.ped)
    StopSound(soundID)
    ReleaseSoundId(soundID)
    DeleteObject(drillObject)
    DeleteEntity(drillObject)
    FreezeEntityPosition(cache.ped, false)
    StopParticleFxLooped(ptfx.effect, 0)
    StopGameplayCamShaking(true)
    Citizen.Wait(1000)
end

function StartDoorsHack(success)
    if success then
        local canStartHack = lib.callback.await('dgl_jewelry:checkJewelry', false)
        EndDrill(drillObject, soundID)
        if canStartHack then
            TriggerServerEvent("dgl_jewelry:openDoorsActivateLasers")--open doors for everyone+activate lazers
            -- lib.notify({description=_L("notif_police"),type="info"})
            PoliceCall()
            StartHeist()
        end
    else
        EndDrill(drillObject, soundID)
    end
    
end

exports.ox_target:addBoxZone({
	name = "drill",
    drawSprite=true,
	coords = vec3(-631.3, -237.35, 38.25),
	size = vec3(1.7, 0.30000000000001, 1.7),
	rotation = 306.5,
    debug = false,
    options = {
        {
            name = "Drill",
            items='drill',
            anyItem = true,
            canInteract=function ()
                return (GlobalState.doors.jewelry1_l.locked==1) and ((true and isNight()) or (not Config.RobOnlyAtNighttrue))
            end,
            onSelect=function ()
                drillObject, soundID =  DrillSafe()
                Config.DoorsHack()

            end,
            icon = 'fa-solid fa-cube',
            label = 'drill',
        }
    }
})

function StartLasersDeactivateHack(success)
    if success then
        if lib.callback.await("dgl_jewelry:deactivateLasers", false) then 
            lib.notify({description='lasers deactivated', type="info"})
            PoliceCall()
        else
            lib.notify({description="already hacked by someone else", type="error"})
        end
    else
        lib.notify({description="hack failed " , type="error"})
    end
end

exports.ox_target:addBoxZone({
	name = "lazerdeactivate",
    drawSprite=true,
	coords = vec3(-629.36, -230.47, 38.55),-- hard coded 
	size = vec3(0.35, 0.25, 0.30000000000001),
	rotation = 37.0,
    debug = false,
    options = {
        {
            name = _L('start_robbery'),
            items={computer=1, alphawifi=1},
            canInteract=function ()
                return GlobalState.lasers.status and ((true and isNight()) or (not Config.RobOnlyAtNighttrue))
            end,
            onSelect=function ()
                startKeypad()
                Config.LasersDeactivateHack()
            end,
            icon = 'fa-solid fa-cube',
            label = "hack electrical networks",
        }
    }
})

for k, v in pairs(Config['ArtHeist']['painting']) do
    exports.ox_target:addBoxZone({
        name = k,
        drawSprite=true,
        coords = v.targetZoneBox.coords,
        size = v.targetZoneBox.size,
        rotation = v.targetZoneBox.rotation,
        debug = false,
        options ={
            {
                name = _L('start_stealing'),
                items = {WEAPON_KNIFE=1, WEAPON_DAGGER=1, WEAPON_SWITCHBLADE=1},-- add pothers if exist
                anyItem = true,
                canInteract=function ()
                    return (GlobalState.doors.jewelry1_l.locked==0) and (not v['taken']) and (not ArtHeist['cutting'])
                end,
                distance = 1,
                onSelect = function ()--open to concurrency I guess
                    TriggerServerEvent('dgl_jewelry:syncPainting', k)
                    HeistAnimation(k)
                end,
                icon = 'fa-solid fa-cube',
                label = _L('start_stealing'),
            }

        }
    })
end

for _, v in pairs(JewelryShowcase) do
    exports.ox_target:addBoxZone({
        name = v.id,
        drawSprite=true,
        coords = v.targetZoneBox.coords,
        size = v.targetZoneBox.size,
        rotation = v.targetZoneBox.rotation,
        debug = false,
        options ={
            {
                name = _L('get_jewels'),
                items = {WEAPON_ASSAULTRIFLE=1, WEAPON_SMG=1, WEAPON_PISTOL=1},
                anyItem = true,
                canInteract=function ()
                    return (GlobalState.doors.jewelry1_l.locked==0) and (not JewelryShowcase[v.id]["taken"]) and (not IsPedInAnyVehicle(cache.ped, true))
                end,
                distance = 1.0,
                onSelect = function ()
                    local current_weapon = GetSelectedPedWeapon(cache.ped)

                    --returns: cooldown / inv full / true 
                    if current_weapon == GetHashKey("WEAPON_ASSAULTRIFLE") or current_weapon == GetHashKey("WEAPON_SMG") or current_weapon == GetHashKey("WEAPON_PISTOL") then
                        local canSteeljewel = lib.callback.await('dgl_jewelry:checkJewels', false, v.id)
                        -- SetEntityCoords(cache.ped, v.xplayer, v.yplayer, v.zplayer, true, false,false, false)
                        -- TaskGoStraightToCoord(cache.ped, v.xplayer, v.yplayer, v.zplayer, 1.0, -1, v.heading, 0.1)
                        -- TaskGoToCoordAnyMeans(cache.ped, v.xplayer, v.yplayer, v.zplayer, 1.0, 0, 0, 786603, 0xbf800000)
                        if type(canSteeljewel)=='boolean' then
                            SetEntityHeading(cache.ped, v.heading)
                            Jewelrytheft(v.x, v.y, v.z, v.prop1, v.prop2, v.id)
                        elseif canSteeljewel=='cooldown' then
                            lib.notify({description = _L("empty"), type='error'})
                        else
                            lib.notify({description = 'inventory full', type='error'})
                        end
                    else
                        SendTextMessagee(_L('need_weapon'), "error")
                    end
                end,
                icon = 'fa-solid fa-cube',
                label = _L('get_jewels'),
            }

        }
    })
end

RegisterNetEvent('dgl_jewelry:startSpray')
AddEventHandler('dgl_jewelry:startSpray', function()-- issue when two client start spraying here    
    local pos = GetEntityCoords(cache.ped)
        local sprayDistance = 4
        if not cache.vehicle then--close to lazers
            if GlobalState.lasers.visibility then
                lib.notify({description="save your spray untill you can't see laser", type='info'})
                return
            end
            local hasIem = lib.callback.await('dgl_jewelry:checkItem', false, 'spray')
            if hasIem then
                LocalPlayer.state.invBusy = true
                local animDict = lib.requestAnimDict('anim@scripted@freemode@postertag@graffiti_spray@male@')
                local anim = 'spray_can_var_02_male'
                local model = lib.requestModel(`prop_cs_spray_can`)
                local ptfxDict = lib.requestNamedPtfxAsset('scr_paintnspray')
                local ptfx = 'scr_respray_smoke'
                ClearPedTasks(cache.ped)
                local obj = CreateObject(model, pos.x, pos.y, pos.z, true, true, true)
                AttachEntityToEntity(obj, cache.ped, GetPedBoneIndex(cache.ped,18905), 0.07, 0.0, 0.03, 0.0, 90.0, 300.0, true, true, false, true, 1, true) -- to do replace with smoke coords
                -- TaskTurnPedToFaceEntity(cache.ped, vehicle, 1000)
                Wait(1000)
                TaskPlayAnim(cache.ped, animDict , anim, 8.0, 1.0, -1, 1)
                local waited = 0
                local waitStep = 2000
                local sprayPartList, index = {}, 1
                while waited < Config.sprayTime * 1000 do --loop for more smoke intensity
                    SetPtfxAssetNextCall(ptfxDict)
                    SetParticleFxNonLoopedColour(1.0, 0, 0)
                    local sprayPart = StartNetworkedParticleFxNonLoopedOnEntity(ptfx, obj, 0.0,0.0,-0.5, 0.0,0.0,0.0, 0.5, 1.0,1.0,1.0)  
                    sprayPartList[index] = sprayPart
                    index += 1
                    
                    if waited > 2000 and waited <= 2000+waitStep  and GlobalState.lasers.status and (#(pos - vector3(-625.2715, -233.0698, 38.0570)) <= sprayDistance) then--trriger once after waiting 2 sec
                        TriggerServerEvent("dgl_jewelry:setLasersVisibility", true)
                    end
                    Wait(waitStep)
                    waited += waitStep
                end
                -- Wait(15000)
                LocalPlayer.state.invBusy = false
                ClearPedTasks(cache.ped)
                DeleteObject(obj)
                RemoveAnimDict('anim@mp_player_intupperwave')
                SetModelAsNoLongerNeeded('prop_cs_spray_can')
                for index, sprayPart in ipairs(sprayPartList) do --simulate smoke fadeout 
                    if index==#sprayPartList-1 and GlobalState.lasers.status then
                        TriggerServerEvent("dgl_jewelry:setLasersVisibility", false )
                        Wait(waitStep)
                    elseif index>#sprayPartList-1 then
                        Wait(waitStep)
                    end
                    Wait(400)
                    RemoveParticleFx(sprayPart)
                end

            end
        else
            lib.notify({description="not when in car"})
        end
end)
