
local mathSqrt = math.sqrt

class "__gsoUtils"

function __gsoUtils:__init()
    self.latencies = {}
    self.maxPing = Game.Latency() * 0.001
    self.minPing = Game.Latency() * 0.001
    self.delayedActions = {}
    self.attacks = {
        ["caitlynheadshotmissile"] = true,
        ["quinnwenhanced"] = true,
        ["viktorqbuff"] = true
    }
    self.noAttacks = {
        ["volleyattack"] = true,
        ["volleyattackwithsound"] = true,
        ["sivirwattackbounce"] = true,
        ["asheqattacknoonhit"] = true
    }
    self.undyingBuffs = {
        ["zhonyasringshield"] = true
    }
    self.Priorities = {
        ["Aatrox"] = 3, ["Ahri"] = 2, ["Akali"] = 2, ["Alistar"] = 5, ["Amumu"] = 5, ["Anivia"] = 2, ["Annie"] = 2, ["Ashe"] = 1, ["AurelionSol"] = 2, ["Azir"] = 2,
        ["Bard"] = 3, ["Blitzcrank"] = 5, ["Brand"] = 2, ["Braum"] = 5, ["Caitlyn"] = 1, ["Camille"] = 3, ["Cassiopeia"] = 2, ["Chogath"] = 5, ["Corki"] = 1,
        ["Darius"] = 4, ["Diana"] = 2, ["DrMundo"] = 5, ["Draven"] = 1, ["Ekko"] = 2, ["Elise"] = 3, ["Evelynn"] = 2, ["Ezreal"] = 1, ["Fiddlesticks"] = 3, ["Fiora"] = 3,
        ["Fizz"] = 2, ["Galio"] = 5, ["Gangplank"] = 2, ["Garen"] = 5, ["Gnar"] = 5, ["Gragas"] = 4, ["Graves"] = 2, ["Hecarim"] = 4, ["Heimerdinger"] = 3, ["Illaoi"] =  3,
        ["Irelia"] = 3, ["Ivern"] = 5, ["Janna"] = 4, ["JarvanIV"] = 3, ["Jax"] = 3, ["Jayce"] = 2, ["Jhin"] = 1, ["Jinx"] = 1, ["Kalista"] = 1, ["Karma"] = 2, ["Karthus"] = 2,
        ["Kassadin"] = 2, ["Katarina"] = 2, ["Kayle"] = 2, ["Kayn"] = 2, ["Kennen"] = 2, ["Khazix"] = 2, ["Kindred"] = 2, ["Kled"] = 4, ["KogMaw"] = 1, ["Leblanc"] = 2,
        ["LeeSin"] = 3, ["Leona"] = 5, ["Lissandra"] = 2, ["Lucian"] = 1, ["Lulu"] = 3, ["Lux"] = 2, ["Malphite"] = 5, ["Malzahar"] = 3, ["Maokai"] = 4, ["MasterYi"] = 1,
        ["MissFortune"] = 1, ["MonkeyKing"] = 3, ["Mordekaiser"] = 2, ["Morgana"] = 3, ["Nami"] = 3, ["Nasus"] = 4, ["Nautilus"] = 5, ["Nidalee"] = 2, ["Nocturne"] = 2,
        ["Nunu"] = 4, ["Olaf"] = 4, ["Orianna"] = 2, ["Ornn"] = 4, ["Pantheon"] = 3, ["Poppy"] = 4, ["Quinn"] = 1, ["Rakan"] = 3, ["Rammus"] = 5, ["RekSai"] = 4,
        ["Renekton"] = 4, ["Rengar"] = 2, ["Riven"] = 2, ["Rumble"] = 2, ["Ryze"] = 2, ["Sejuani"] = 4, ["Shaco"] = 2, ["Shen"] = 5, ["Shyvana"] = 4, ["Singed"] = 5,
        ["Sion"] = 5, ["Sivir"] = 1, ["Skarner"] = 4, ["Sona"] = 3, ["Soraka"] = 3, ["Swain"] = 3, ["Syndra"] = 2, ["TahmKench"] = 5, ["Taliyah"] = 2, ["Talon"] = 2,
        ["Taric"] = 5, ["Teemo"] = 2, ["Thresh"] = 5, ["Tristana"] = 1, ["Trundle"] = 4, ["Tryndamere"] = 2, ["TwistedFate"] = 2, ["Twitch"] = 1, ["Udyr"] = 4, ["Urgot"] = 4,
        ["Varus"] = 1, ["Vayne"] = 1, ["Veigar"] = 2, ["Velkoz"] = 2, ["Vi"] = 4, ["Viktor"] = 2, ["Vladimir"] = 3, ["Volibear"] = 4, ["Warwick"] = 4, ["Xayah"] = 1,
        ["Xerath"] = 2, ["XinZhao"] = 3, ["Yasuo"] = 2, ["Yorick"] = 4, ["Zac"] = 5, ["Zed"] = 2, ["Ziggs"] = 2, ["Zilean"] = 3, ["Zoe"] = 2, ["Zyra"] = 2
    }
    Callback.Add('Tick', function() self:_tick() end)
end

function __gsoUtils:_tick()
    self.latencies[GetTickCount() + 2500] = Game.Latency() * 0.001
    local maxPing = 0
    local minPing = 50
    for k,v in pairs(self.latencies) do
        if v > maxPing then
            maxPing = v
        end
        if v < minPing then
            minPing = v
        end
        if GetTickCount() > k then
            self.latencies[k] = nil
        end
    end
    self.maxPing = maxPing
    self.minPing = minPing
    for i = 1, #gsoAIO.Utils.delayedActions do
        local dAction = gsoAIO.Utils.delayedActions[i]
        if dAction and Game.Timer() > dAction.endTime then
            dAction.func()
            gsoAIO.Utils.delayedActions[i] = nil
        end
    end
end

function __gsoUtils:_getDistance(a, b)
  local x = a.x - b.x
  local z = a.z - b.z
  return mathSqrt(x * x + z * z)
end

function __gsoUtils:_movePos(unit, time)
    local unitPath = unit.pathing
    if unitPath.hasMovePath == true then
        local uPos  = unit.pos
        local ePos  = unitPath.endPos
        local dist1 = gsoAIO.Utils:_getDistance(ePos, uPos)
        local predPos = uPos:Extended(ePos, time * unit.ms)
        local dist2 = gsoAIO.Utils:_getDistance(predPos, uPos)
        if dist2 > dist1 then
            return ePos
        else
            return predPos
        end
    end
    return unit.pos
end

function __gsoUtils:_pointOnLineSegment(x, z, ax, az, bx, bz)
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((x - ax) * bxax + (z - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    if t < 0 then return false
    elseif t > 1 then return false
    else return true
    end
end

function __gsoUtils:_isImmortal(unit, orb)
    local unitHPPercent = 100 * unit.health / unit.maxHealth
    if self.undyingBuffs["JaxCounterStrike"] ~= nil then    self.undyingBuffs["JaxCounterStrike"] = orb end
    if self.undyingBuffs["kindredrnodeathbuff"] ~= nil then self.undyingBuffs["kindredrnodeathbuff"] = unitHPPercent < 10 end
    if self.undyingBuffs["UndyingRage"] ~= nil then         self.undyingBuffs["UndyingRage"] = unitHPPercent < 15 end
    if self.undyingBuffs["ChronoShift"] ~= nil then         self.undyingBuffs["ChronoShift"] = unitHPPercent < 15; self.undyingBuffs["chronorevive"] = unitHPPercent < 15 end
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local undyingBuff = self.undyingBuffs[buff.name]
            if undyingBuff and undyingBuff == true then
                return true
            end
        end
    end
    return false
end

function __gsoUtils:_valid(unit, orb)
    if not unit or self:_isImmortal(unit, orb) then
        return false
    end
    if not unit.dead and unit.isTargetable and unit.visible and unit.valid then
        return true
    end
    return false
end

function __gsoUtils:_castAgain(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
end

function __gsoUtils:_isImmobile(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local bType = buff.type
            if bType == 5 or bType == 11 or bType == 29 or bType == 24 or buff.name == "recall" then
                return true
            end
        end
    end
    return false
end

function __gsoUtils:_nearTurret(pos, range, bb)
    for i = 1, #gsoAIO.OB.enemyTurrets do
        local unit = gsoAIO.OB.enemyTurrets[i]
        local range = bb and unit.boundingRadius or range
        if self:_getDistance(pos, unit.pos) < range then
            return true
        end
    end
    return false
end

function __gsoUtils:_nearHeroes(pos, range, bb)
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local unit = gsoAIO.OB.enemyHeroes[i]
        local range = bb and unit.boundingRadius or range
        if self:_getDistance(pos, unit.pos) < range then
            return true
        end
    end
    return false
end

function __gsoUtils:_nearMinions(pos, range, bb)
    for i = 1, #gsoAIO.OB.enemyMinions do
        local unit = gsoAIO.OB.enemyMinions[i]
        local range = bb and unit.boundingRadius or range
        if self:_getDistance(pos, unit.pos) < range then
            return true
        end
    end
    return false
end

function __gsoUtils:_nearUnit(pos, id)
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local unit = gsoAIO.OB.enemyHeroes[i]
        if id ~= unit.networkID and self:_getDistance(pos, unit.pos) < unit.boundingRadius then
            return true
        end
    end
    for i = 1, #gsoAIO.OB.enemyMinions do
        local unit = gsoAIO.OB.enemyMinions[i]
        if self:_getDistance(pos, unit.pos) < unit.boundingRadius then
            return true
        end
    end
    return false
end

function __gsoUtils:_buffCount(unit, bName)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == bName then
            return buff.count
        end
    end
    return 0
end

function __gsoUtils:_hasBuff(unit, bName)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == bName then
            return true
        end
    end
    return false
end

function __gsoUtils:_isReady(spell)
    return gsoAIO.Orb.dActionsC == 0 and Game.CanUseSpell(spell) == 0
end

function __gsoUtils:_checkWall(from, to, distance)
    local pos1 = to + (to-from):Normalized() * 50
    local pos2 = pos1 + (to-from):Normalized() * (distance - 50)
    local point1 = Point(pos1.x, pos1.z)
    local point2 = Point(pos2.x, pos2.z)
    if (MapPosition:inWall(point1) and MapPosition:inWall(point2)) or MapPosition:intersectsWall(LineSegment(point1, point2)) then
        return true
    end
    return false
end

function __gsoUtils:_countEnemyHeroesInRange(sourcePos, range, bb)
    local count = 0
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local unit = gsoAIO.OB.enemyHeroes[i]
        local extraRange = bb and unit.boundingRadius or 0
        if gsoAIO.Utils:_getDistance(sourcePos, unit.pos) < range + extraRange then
            count = count + 1
        end
    end
    return count
end