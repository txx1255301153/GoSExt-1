
class "__gsoTS"

function __gsoTS:__init()
    self.apDmg = false
    self.isTeemo = false
    self.isBlinded = false
    self.loadedChamps = false
    self.lastTarget = nil
    self.lastFound = -10000000
    self.selectedTarget = nil
    self.lastSelTick = 0
    self.enemyHNames = {}
    self.LHTimers     = {
        [0] = { tick = 0, id = 0 },
        [1] = { tick = 0, id = 0 },
        [2] = { tick = 0, id = 0 },
        [3] = { tick = 0, id = 0 },
        [4] = { tick = 0, id = 0 }
    }
    gsoAIO.Callbacks:_setDraw(function() self:_draw() end)
    gsoAIO.Callbacks:_setWndMsg(function(msg, wParam) self:_onWndMsg(msg, wParam) end)
    gsoAIO.Callbacks:_setTick(function() self:_tick() end)
end

function __gsoTS:_getTarget(_range, orb, changeRange, enemyList)
    if gsoAIO.Menu.menu.ts.selected.only:Value() == true and gsoAIO.Utils:_valid(self.selectedTarget, true) then
        return self.selectedTarget
    end
    local result  = nil
    local num     = 10000000
    local mode    = gsoAIO.Menu.menu.ts.Mode:Value()
    local prioT  = { 10000000, 10000000 }
    for i = 1, #enemyList do
        local unit = enemyList[i]
        local unitID = unit.networkID
        local unitPos = unit.pos
        local mePos = myHero.pos
        local canTrist = gsoAIO.Load.meTristana and gsoAIO.Menu.menu.ts.tristE.enable:Value() and gsoAIO.Champ.tristanaETar and gsoAIO.Champ.tristanaETar.stacks >= gsoAIO.Menu.menu.ts.tristE.stacks:Value() and unitID == gsoAIO.Champ.tristanaETar.id
        local range = changeRange == true and _range + myHero.boundingRadius + unit.boundingRadius or _range
        local meExtended = gsoAIO.Orb.lMovePath and mePos:Extended(gsoAIO.Orb.lMovePath, (0.15+(gsoAIO.Utils.maxPing*1.5)) * myHero.ms) or mePos
        local dist1 = gsoAIO.Utils:_getDistance(mePos, unitPos)
        local dist2 = gsoAIO.Utils:_getDistance(meExtended, unitPos)
        local dist3 = dist2 > dist1 and dist2 or dist1
        if gsoAIO.Utils:_valid(unit, orb) and dist3 < range then
            if gsoAIO.Menu.menu.ts.selected.enable:Value() and self.selectedTarget and unitID == self.selectedTarget.networkID then
                return self.selectedTarget
            elseif canTrist then
                return unit
            elseif mode == 1 then
                local unitName = unit.charName
                local priority = 6
                if unitName ~= nil then
                    priority = gsoAIO.Menu.menu.ts.priority[unitName] and gsoAIO.Menu.menu.ts.priority[unitName]:Value() or priority
                end
                local calcNum = 1
                if priority == 1 then
                    calcNum = 1
                elseif priority == 2 then
                    calcNum = 1.15
                elseif priority == 3 then
                    calcNum = 1.3
                elseif priority == 4 then
                    calcNum = 1.45
                elseif priority == 5 then
                    calcNum = 1.6
                elseif priority == 6 then
                    calcNum = 1.75
                end
                local def = self.apDmg == true and unit.magicResist - myHero.magicPen or unit.armor - myHero.armorPen
                def = def * calcNum
                if def > 0 then
                      def = self.apDmg == true and myHero.magicPenPercent * def or myHero.bonusArmorPenPercent * def
                end
                local hpE = unit.health
                hpE = hpE * calcNum
                hpE = hpE * ( ( 100 + def ) / 100 )
                hpE = hpE - (unit.totalDamage*unit.attackSpeed*2) - unit.ap
                if hpE < num then
                    num     = hpE
                    result  = unit
                end
            elseif mode == 2 then
                if dist3 < num then
                    num = dist3
                    result = unit
                end
            elseif mode == 3 then
                local hpE = unit.health
                if hpE < num then
                    num = hpE
                    result = unit
                end
            elseif mode == 4 then
                local unitName = unit.charName
                local hpE = unit.health - (unit.totalDamage*unit.attackSpeed*2) - unit.ap
                local priority = 6
                if unitName ~= nil then
                    priority = gsoAIO.Menu.menu.ts.priority[unitName] and gsoAIO.Menu.menu.ts.priority[unitName]:Value() or priority
                end
                if priority == prioT[1] and hpE < prioT[2] then
                    prioT[2] = hpE
                    result = unit
                elseif priority < prioT[1] then
                    prioT[1] = priority
                    prioT[2] = hpE
                    result = unit
                end
            end
        end
    end
    return result
end

function __gsoTS:_comboT()
    return self:_getTarget(myHero.range, true, true, gsoAIO.OB.enemyHeroes)
end

function __gsoTS:_lastHitT()
    local result  = nil
    local min     = 10000000
    for i = 1, #gsoAIO.Farm.lastHit do
        local eMinionLH = gsoAIO.Farm.lastHit[i]
        local minion	= eMinionLH[1]
        local hp		= eMinionLH[2]
        local checkT = Game.Timer() < self.LHTimers[0].tick
        local mHandle = minion.handle
        if (not checkT or (checkT and self.LHTimers[0].id ~= mHandle)) and hp < min then
            min = hp
            result = minion
            self.LHTimers[4].tick = Game.Timer() + 0.75
            self.LHTimers[4].id = mHandle
        end
    end
    return result
end

function __gsoTS:_getTurret()
    local result = nil
    for i=1, #gsoAIO.OB.enemyTurrets do
        local turret = gsoAIO.OB.enemyTurrets[i]
        local range = myHero.range + myHero.boundingRadius + turret.boundingRadius
        if gsoAIO.Utils:_getDistance(myHero.pos, turret.pos) < range then
            result = turret
            break
        end
    end
    return result
end

function __gsoTS:_laneClearT()
    local result	= self:_lastHitT()
    if not result then
        result = self:_comboT()
        if not result and #gsoAIO.Farm.almostLH == 0 and gsoAIO.Farm.shouldWait == false then
            result = self:_getTurret()
            if not result then
                local min = 10000000
                for i = 1, #gsoAIO.Farm.laneClear do
                    local minion = gsoAIO.Farm.laneClear[i]
                    local hp     = minion.health
                    if hp < min then
                        min = hp
                        result = minion
                    end
                end
            end
        end
    end
    return result
end

function __gsoTS:_harassT()
    local result = self:_lastHitT()
    return result == nil and self:_comboT() or result
end

function __gsoTS:_draw()
    if gsoAIO.Menu.menu.gsodraw.circle1.seltar:Value() and gsoAIO.Utils:_valid(self.selectedTarget, true) then
        Draw.Circle(self.selectedTarget.pos, gsoAIO.Menu.menu.gsodraw.circle1.seltarradius:Value(), gsoAIO.Menu.menu.gsodraw.circle1.seltarwidth:Value(), gsoAIO.Menu.menu.gsodraw.circle1.seltarcolor:Value())
    end
end

function __gsoTS:_tick()
    if gsoAIO.TS.isTeemo == true then
        self.isBlinded = gsoAIO.Utils:_hasBuff(myHero, "blindingdart")
    end
    if self.loadedChamps == false then
        for i = 1, Game.HeroCount() do
            local hero = Game.Hero(i)
            if hero.team ~= gsoAIO.OB.meTeam then
                local eName = hero.charName
                if eName and #eName > 0 and not gsoAIO.Menu.menu.ts.priority[eName] then
                    self.enemyHNames[#self.enemyHNames+1] = eName
                    self.lastFound = Game.Timer()
                    local priority = gsoAIO.Utils.Priorities[eName] ~= nil and gsoAIO.Utils.Priorities[eName] or 5
                    gsoAIO.Menu.menu.ts.priority:MenuElement({ id = eName, name = eName, value = priority, min = 1, max = 5, step = 1 })
                    if eName == "Teemo" then          self.isTeemo = true
                    elseif eName == "Kayle" then      gsoAIO.Utils.undyingBuffs["JudicatorIntervention"] = true
                    elseif eName == "Taric" then      gsoAIO.Utils.undyingBuffs["TaricR"] = true
                    elseif eName == "Kindred" then    gsoAIO.Utils.undyingBuffs["kindredrnodeathbuff"] = true
                    elseif eName == "Zilean" then     gsoAIO.Utils.undyingBuffs["ChronoShift"] = true; gsoAIO.Utils.undyingBuffs["chronorevive"] = true
                    elseif eName == "Tryndamere" then gsoAIO.Utils.undyingBuffs["UndyingRage"] = true
                    elseif eName == "Jax" then        gsoAIO.Utils.undyingBuffs["JaxCounterStrike"] = true
                    elseif eName == "Fiora" then      gsoAIO.Utils.undyingBuffs["FioraW"] = true
                    elseif eName == "Aatrox" then     gsoAIO.Utils.undyingBuffs["aatroxpassivedeath"] = true
                    elseif eName == "Vladimir" then   gsoAIO.Utils.undyingBuffs["VladimirSanguinePool"] = true
                    elseif eName == "KogMaw" then     gsoAIO.Utils.undyingBuffs["KogMawIcathianSurprise"] = true
                    elseif eName == "Karthus" then    gsoAIO.Utils.undyingBuffs["KarthusDeathDefiedBuff"] = true
                    end
                end
            end
        end
        if Game.Timer() > self.lastFound + 5 and Game.Timer() < self.lastFound + 10 then
            self.loadedChamps = true
        end
    end
end

function __gsoTS:_onWndMsg(msg, wParam)
    local getTick = GetTickCount()
    if msg == WM_LBUTTONDOWN and gsoAIO.Menu.menu.ts.selected.enable:Value() == true then
        if getTick > self.lastSelTick + 100 and getTick > gsoAIO.WndMsg.lastQ + 250 and getTick > gsoAIO.WndMsg.lastW + 250 and getTick > gsoAIO.WndMsg.lastE + 250 and getTick > gsoAIO.WndMsg.lastR + 250 then 
            local num = 10000000
            local enemy = nil
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local heroPos = hero.pos
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(myHero.pos, heroPos) < 10000 then
                    local distance = gsoAIO.Utils:_getDistance(heroPos, mousePos)
                    if distance < 150 and distance < num then
                        enemy = hero
                        num = distance
                    end
                end
            end
            if enemy ~= nil then
                self.selectedTarget = enemy
            else
                self.selectedTarget = nil
            end
            self.lastSelTick = GetTickCount()
        end
    end
end