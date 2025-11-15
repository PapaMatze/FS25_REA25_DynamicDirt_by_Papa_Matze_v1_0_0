-- ############################################################
-- REA25 DynamicDirt by Papa Matze  -  STABILE FIX-VERSION
-- ############################################################

READynamicDirt = {}

function READynamicDirt:loadMap(name)
    print("REA25 DynamicDirt: FIX v2 geladen")
    self.timer = 0
end

function READynamicDirt:deleteMap()
end

function READynamicDirt:keyEvent(unicode, sym, modifier, isDown)
end

function READynamicDirt:mouseEvent(posX, posY, isDown, isUp, button)
end

function READynamicDirt:update(dt)
    ----------------------------------------------------------------
    -- WICHTIGER FIX:
    -- g_currentMission oder vehicles können beim Laden NIL sein.
    -- Dadurch ist 'ipairs(g_currentMission.vehicles)' gecrasht.
    ----------------------------------------------------------------
    if g_currentMission == nil then
        return
    end

    local vehicles = g_currentMission.vehicles
    if vehicles == nil or type(vehicles) ~= "table" then
        return
    end

    -- kleines Intervall, damit nicht jede Frame gerechnet wird
    self.timer = (self.timer or 0) + dt
    if self.timer < 100 then
        return
    end
    self.timer = 0

    ----------------------------------------------------------------
    -- Einfacher, stabiler Dirt-Aufbau
    ----------------------------------------------------------------
    local count = #vehicles
    for i = 1, count do
        local vehicle = vehicles[i]

        if vehicle ~= nil
        and vehicle.getIsSynchronized ~= nil
        and vehicle:getIsSynchronized()
        then
            local getDirt = vehicle.getDirtAmount
            local setDirt = vehicle.setDirtAmount

            if getDirt ~= nil and setDirt ~= nil then
                local current = getDirt(vehicle) or 0
                local newDirt = current + 0.0015

                if newDirt > 1 then
                    newDirt = 1
                end

                setDirt(vehicle, newDirt)
            end
        end
    end
end

function READynamicDirt:draw()
end

addModEventListener(READynamicDirt)
