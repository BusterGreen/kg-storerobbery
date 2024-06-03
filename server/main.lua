local KGCore = exports['kg-core']:GetCoreObject()
local SafeCodes = {}
local cashA = 250 --<<how much minimum you can get from a robbery
local cashB = 450 --<< how much maximum you can get from a robbery

CreateThread(function()
    while true do
        SafeCodes = {
            [1] = math.random(1000, 9999),
            [2] = { math.random(1, 149), math.random(500.0, 600.0), math.random(360.0, 400), math.random(600.0, 900.0) },
            [3] = { math.random(150, 359), math.random(-300.0, -60.0), math.random(0, 100), math.random(-500.0, -160.0) },
            [4] = math.random(1000, 9999),
            [5] = math.random(1000, 9999),
            [6] = { math.random(1, 149), math.random(150.0, 200.0), math.random(100, 140), math.random(150.0, 220.0), math.random(-100, 100), math.random(140, 300) },
            [7] = math.random(1000, 9999),
            [8] = math.random(1000, 9999),
            [9] = math.random(1000, 9999),
            [10] = { math.random(1, 149), math.random(300.0, 500.0), math.random(200, 260), math.random(500.0, 800.0), math.random(300, 440), math.random(650, 900) },
            [11] = math.random(1000, 9999),
            [12] = math.random(1000, 9999),
            [13] = math.random(1000, 9999),
            [14] = { math.random(150, 450), math.random(-360.0, 0.0), math.random(360, 720) },
            [15] = math.random(1000, 9999),
            [16] = math.random(1000, 9999),
            [17] = math.random(1000, 9999),
            [18] = { math.random(150, 450), math.random(1.0, 100.0), math.random(360, 450), math.random(300.0, 340.0), math.random(350, 400), math.random(320.0, 340.0), math.random(350, 600) },
            [19] = math.random(1000, 9999),
        }
        Wait((1000 * 60) * 40)
    end
end)

RegisterNetEvent('kg-storerobbery:server:takeMoney', function(register, isDone)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    if not Player then return end
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    if #(playerCoords - Config.Registers[register][1].xyz) > 3.0 or (not Config.Registers[register].robbed and not isDone) or (Config.Registers[register].time <= 0 and not isDone) then
        return DropPlayer(src, 'Attempted exploit abuse')
    end
    if isDone then
        local bags = math.random(1, 3)
        local info = {
            worth = math.random(cashA, cashB)
        }
        exports['kg-inventory']:AddItem(src, 'markedbills', bags, false, info, 'kg-storerobbery:server:takeMoney')
        TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items['markedbills'], 'add')
        if math.random(1, 100) <= Config.stickyNoteChance then
            local code = SafeCodes[Config.Registers[register].safeKey]
            if Config.Safes[Config.Registers[register].safeKey].type == 'keypad' then
                info = {
                    label = Lang:t('text.safe_code') .. tostring(code)
                }
            else
                local label = Lang:t('text.safe_code') .. ' '

                for i = 1, #code do
                    label = label .. tostring(math.floor((code[i] % 360) / 3.60)) .. ' - '
                end

                info = { label = label:sub(1, -3) }
            end
            exports['kg-inventory']:AddItem(src, 'stickynote', 1, false, info, 'kg-storerobbery:server:takeMoney')
            TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items['stickynote'], 'add')
        end
    end
end)

RegisterNetEvent('kg-storerobbery:server:setRegisterStatus', function(register)
    Config.Registers[register].robbed = true
    Config.Registers[register].time = Config.resetTime
    TriggerClientEvent('kg-storerobbery:client:setRegisterStatus', -1, register, Config.Registers[register])
end)

RegisterNetEvent('kg-storerobbery:server:setSafeStatus', function(safe)
    Config.Safes[safe].robbed = true
    TriggerClientEvent('kg-storerobbery:client:setSafeStatus', -1, safe, true)

    SetTimeout(math.random(40, 80) * (60 * 1000), function()
        Config.Safes[safe].robbed = false
        TriggerClientEvent('kg-storerobbery:client:setSafeStatus', -1, safe, false)
    end)
end)

RegisterNetEvent('kg-storerobbery:server:SafeReward', function(safe)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    if not Player then return end
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    if #(playerCoords - Config.Safes[safe][1].xyz) > 3.0 or Config.Safes[safe].robbed then
        return DropPlayer(src, 'Attempted exploit abuse')
    end
    local bags = math.random(1, 3)
    local info = {
        worth = math.random(cashA, cashB)
    }
    exports['kg-inventory']:AddItem(src, 'markedbills', bags, false, info, 'kg-storerobbery:server:SafeReward')
    TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items['markedbills'], 'add')
    local luck = math.random(1, 100)
    local odd = math.random(1, 100)
    if luck <= 10 then
        exports['kg-inventory']:AddItem(src, 'rolex', math.random(3, 7), false, false, 'kg-storerobbery:server:SafeReward')
        TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items['rolex'], 'add')
        if luck == odd then
            Wait(500)
            exports['kg-inventory']:AddItem(src, 'goldbar', 1, false, false, 'kg-storerobbery:server:SafeReward')
            TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items['goldbar'], 'add')
        end
    end
end)

RegisterNetEvent('kg-storerobbery:server:callCops', function(type, safe, streetLabel, coords)
    local cameraId
    if type == 'safe' then
        cameraId = Config.Safes[safe].camId
    else
        cameraId = Config.Registers[safe].camId
    end
    local alertData = {
        title = '10-33 | Shop Robbery',
        coords = { x = coords.x, y = coords.y, z = coords.z },
        description = Lang:t('email.someone_is_trying_to_rob_a_store', { street = streetLabel, cameraId1 = cameraId })
    }
    TriggerClientEvent('kg-storerobbery:client:robberyCall', -1, type, safe, streetLabel, coords)
    TriggerClientEvent('kg-phone:client:addPoliceAlert', -1, alertData)
end)

RegisterNetEvent('kg-storerobbery:server:removeAdvancedLockpick', function()
    local Player = KGCore.Functions.GetPlayer(source)
    if not Player then return end
    exports['kg-inventory']:RemoveItem(source, 'advancedlockpick', 1, false, 'kg-storerobbery:server:removeAdvancedLockpick')
end)

RegisterNetEvent('kg-storerobbery:server:removeLockpick', function()
    local Player = KGCore.Functions.GetPlayer(source)
    if not Player then return end
    exports['kg-inventory']:RemoveItem(source, 'lockpick', 1, false, 'kg-storerobbery:server:removeLockpick')
end)

CreateThread(function()
    while true do
        local toSend = {}
        for k in ipairs(Config.Registers) do
            if Config.Registers[k].time > 0 and (Config.Registers[k].time - Config.tickInterval) >= 0 then
                Config.Registers[k].time = Config.Registers[k].time - Config.tickInterval
            else
                if Config.Registers[k].robbed then
                    Config.Registers[k].time = 0
                    Config.Registers[k].robbed = false
                    toSend[#toSend + 1] = Config.Registers[k]
                end
            end
        end

        if #toSend > 0 then
            --The false on the end of this is redundant
            TriggerClientEvent('kg-storerobbery:client:setRegisterStatus', -1, toSend, false)
        end

        Wait(Config.tickInterval)
    end
end)

KGCore.Functions.CreateCallback('kg-storerobbery:server:isCombinationRight', function(_, cb, safe)
    cb(SafeCodes[safe])
end)

KGCore.Functions.CreateCallback('kg-storerobbery:server:getPadlockCombination', function(_, cb, safe)
    cb(SafeCodes[safe])
end)

KGCore.Functions.CreateCallback('kg-storerobbery:server:getRegisterStatus', function(_, cb)
    cb(Config.Registers)
end)

KGCore.Functions.CreateCallback('kg-storerobbery:server:getSafeStatus', function(_, cb)
    cb(Config.Safes)
end)
