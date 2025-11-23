--============================================================--
--  REA25 Dynamic Dirt – Enhanced Tire Coloring v1.0.7
--  by Papa_Matze
--============================================================--

READynamicDirt = {}
READynamicDirt.version = "1.0.7.0"
READynamicDirt.debug = false

------------------------------------------------------------
-- Hilfsfunktion
------------------------------------------------------------
local function clamp(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

------------------------------------------------------------
-- für Map laden
------------------------------------------------------------
function READynamicDirt:loadMap(name)
    print("REA DynamicDirt v"..READynamicDirt.version.." geladen.")

    self.timer       = 0
    self.updateDelay = 200
    self.lastWetTime = 0
    self.groundWet   = 0
end

function READynamicDirt:deleteMap() end
function READynamicDirt:mouseEvent() end
function READynamicDirt:keyEvent() end
function READynamicDirt:draw() end

------------------------------------------------------------
-- Bodenfeuchtigkeit
------------------------------------------------------------
function READynamicDirt:updateWetness()
    if g_currentMission == nil or g_currentMission.environment == nil then return end

    local env = g_currentMission.environment
    local now = env.dayTime or 0

    if self.lastWetTime == 0 or (now - self.lastWetTime) > 1000 then
        local wet = env.weather:getGroundWetness() or 0
        self.groundWet = clamp(wet, 0, 1)
        self.lastWetTime = now
    end
end

function READynamicDirt:getWetness()
    return self.groundWet or 0
end

------------------------------------------------------------
-- Reifenfärbung Farbtabelle
------------------------------------------------------------
local TireColor = {
    [WheelsUtil.GROUND_SOFT_TERRAIN] = { r=0.28, g=0.18, b=0.10 },
    [WheelsUtil.GROUND_FIELD]        = { r=0.32, g=0.20, b=0.12 },
    [WheelsUtil.GROUND_ROAD]         = { r=0.08, g=0.08, b=0.08 },
    [WheelsUtil.GROUND_HARD_TERRAIN] = { r=0.20, g=0.20, b=0.20 },

    GRASS = { r=0.05, g=0.35, b=0.05 },
    LIME  = { r=0.92, g=0.92, b=0.92 },
    SNOW  = { r=0.92, g=0.92, b=1.00 },
}

------------------------------------------------------------
-- Map-Material erkennen
------------------------------------------------------------
local function detectCustomMaterial(name)
    name = name:lower()

    if name:find("grass") or name:find("gras") then return TireColor.GRASS end
    if name:find("lime")  or name:find("kalk") then return TireColor.LIME  end
    if name:find("snow")  or name:find("schnee") then return TireColor.SNOW end

    return nil
end

------------------------------------------------------------
-- Reifen einfärben
------------------------------------------------------------
local function applyTireColor(vehicle, wheel)
    if wheel.lastTerrainMaterial == nil then return end

    local groundType = wheel.lastTerrainMaterial
    local color = TireColor[groundType]

    if wheel.lastTerrainName ~= nil then
        local c = detectCustomMaterial(wheel.lastTerrainName)
        if c ~= nil then color = c end
    end

    if color == nil then return end

    -- Shader-Boost
    local boost = 1.6
    local r = math.min(1, color.r * boost)
    local g = math.min(1, color.g * boost)
    local b = math.min(1, color.b * boost)

    if groundType == WheelsUtil.GROUND_FIELD then
        r = r * 1.15
        g = g * 1.10
        b = b * 1.10
    end

    if wheel.node ~= nil then
        setShaderParameter(wheel.node, "dirtColor", r, g, b, 1, false)
    end
end

------------------------------------------------------------
-- Staubboost
------------------------------------------------------------
local function boostDust()
    if g_currentMission == nil then return end
    local env = g_currentMission.environment

    if env.setDustScale ~= nil then
        env:setDustScale(2.2) -- x2 Giants Standard
    end
end

------------------------------------------------------------
-- Dirt-Update je Fahrzeug
------------------------------------------------------------
function READynamicDirt:updateVehicleDirt(vehicle, wet)
    local speedKmh = 0
    if vehicle.getLastSpeed ~= nil then 
        speedKmh = vehicle:getLastSpeed()
    elseif vehicle.lastSpeed ~= nil then
        speedKmh = vehicle.lastSpeed * 3600
    end

    if speedKmh < 0.5 then return end

    local onField = false
    if vehicle.getIsOnField ~= nil then 
        onField = vehicle:getIsOnField()
    end

    local base = 0.0002
    local speedFactor = clamp(speedKmh / 25, 0.2, 3.0)
    local factor = base * speedFactor

    if onField then factor = factor * 2.0
    else           factor = factor * 0.7 end

    factor = factor * (1.0 + wet * 3.0)

    if wet < 0.2 then factor = factor * 2.0 end

    local d = vehicle:getDirtAmount()
    d = clamp(d + factor, 0, 1)

    if not onField and wet < 0.1 and speedKmh > 30 then
        d = clamp(d - 0.0005 * (speedKmh / 30), 0, 1)
    end

    vehicle:setDirtAmount(d)
end

------------------------------------------------------------
-- Hauptupdate
------------------------------------------------------------
function READynamicDirt:update(dt)
    if g_currentMission == nil or g_currentMission.vehicles == nil then
        return
    end

    self.timer = self.timer + dt
    if self.timer < self.updateDelay then return end
    self.timer = 0

    self:updateWetness()
    local wet = self:getWetness()

    boostDust()

    for _, vehicle in ipairs(g_currentMission.vehicles) do
        if vehicle.spec_wheels ~= nil then
            for _, w in ipairs(vehicle.spec_wheels.wheels) do
                applyTireColor(vehicle, w)
            end
        end

        if vehicle.setDirtAmount ~= nil then
            self:updateVehicleDirt(vehicle, wet)
        end
    end
end

------------------------------------------------------------
-- Registrieren
------------------------------------------------------------
addModEventListener(READynamicDirt)
--============================================================--
-- ENDE
--============================================================--
