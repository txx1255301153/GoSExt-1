
class "__gsoEzreal"

function __gsoEzreal:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ        = 0
    self.lastW        = 0
    self.lastE        = 0
    self.lastR        = 0
    self.shouldWaitT  = 0
    self.shouldWait   = false
    self.loadedChamps = false
    gsoAIO.Orb.baseAASpeed = 0.625
    gsoAIO.Orb.baseWindUp = 0.18838652
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
    gsoAIO.Callbacks:_setDraw(function() self:_draw() end)
end

function __gsoEzreal:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    
    if not isTarget or afterAttack then
        
        -- Q :
        local canQTime = qMinus > 1000 and qMinuss > 1000 and wMinus > 450 and wMinuss > 450 and eMinus > 650 and eMinuss > 650 and rMinuss > 1500
        local isComboQ = isCombo and gsoAIO.Menu.menu.gsoezreal.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Menu.menu.gsoezreal.qset.harass:Value()
        local isQReady = canQTime and gsoAIO.Utils:_isReady(_Q)
        local isQReadyCombo = isQReady and (isComboQ or isHarassQ)
        
        -- Q FARM :
        if isQReady and ( not isTarget or (isTarget and self.canQ) ) and self:_castQFarm() then
            self.canW = false
            return
        end
        
        -- USE Q :
        if isQReadyCombo and ( not isTarget or (isTarget and self.canQ) ) then
            local qTarget = isTarget and target or gsoAIO.TS:_getTarget(1150, true, false, gsoAIO.OB.enemyHeroes)
            if qTarget ~= nil then
                local sQ = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
                local mePos = myHero.pos
                local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(qTarget, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
                local distMeToPredPos = gsoAIO.Utils:_getDistance(mePos, castpos)
                local distUnitToPredPos = gsoAIO.Utils:_getDistance(qTarget.pos, castpos)
                if HitChance > gsoAIO.Menu.menu.gsoezreal.qset.hitchance:Value()-1 and castpos:ToScreen().onScreen and distMeToPredPos < sQ.range and distUnitToPredPos < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_Q)
                    Control.KeyUp(HK_Q)
                    self.lastQ = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.canW = false
                    return
                end
            end
        end
        
        -- USE W :
        local canWTime = qMinus > 650 and qMinuss > 650 and wMinus > 1000 and wMinuss > 1000 and eMinus > 650 and eMinuss > 650 and rMinuss > 1500
        local isComboW = isCombo and gsoAIO.Menu.menu.gsoezreal.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Menu.menu.gsoezreal.wset.harass:Value()
        local isWReady = (isComboW or isHarassW) and canWTime and gsoAIO.Utils:_isReady(_W)
        if isWReady and ( not isTarget or (isTarget and self.canW) ) then
            local wTarget = isTarget and target or gsoAIO.TS:_getTarget(1000, false, false, gsoAIO.OB.enemyHeroes)
            if wTarget ~= nil then
                local mePos = myHero.pos
                local sW = { delay = 0.25, range = 1000, width = 80, speed = 1550, sType = "line", col = false }
                local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(wTarget, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
                local distMeToPredPos = gsoAIO.Utils:_getDistance(mePos, castpos)
                local distUnitToPredPos = gsoAIO.Utils:_getDistance(wTarget.pos, castpos)
                if HitChance > gsoAIO.Menu.menu.gsoezreal.wset.hitchance:Value()-1 and castpos:ToScreen().onScreen and distMeToPredPos < sW.range and distUnitToPredPos < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    self.lastW = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.canQ = false
                    return
                end
            end
        end
    end
end

function __gsoEzreal:_canMove(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if qMinus > 250 and qMinuss > 250 and wMinus > 250 and wMinuss > 250 and eMinus > 250 and eMinuss > 250 and rMinuss > 1000 then
        return true
    end
    return false
end

function __gsoEzreal:_canAttack(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if qMinus > 350 and qMinuss > 350 and wMinus > 350 and wMinuss > 350 and eMinus > 350 and eMinuss > 350 and rMinuss > 1100 then
        return true
    end
    return false
end

function __gsoEzreal:_castQ(t, tPos, mePos)
    local sQ = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
    local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(t, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
    local distMeToPredPos = gsoAIO.Utils:_getDistance(mePos, castpos)
    local distUnitToPredPos = gsoAIO.Utils:_getDistance(tPos, castpos)
    if HitChance > gsoAIO.Menu.menu.gsoezreal.qset.hitchance:Value()-1 and castpos:ToScreen().onScreen and distMeToPredPos < sQ.range and distUnitToPredPos < 500 then
        local cPos = cursorPos
        Control.SetCursorPos(castpos)
        gsoAIO.Orb.setCursor = castpos
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        self.lastQ = GetTickCount()
        gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
        gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
        self.canW = false
        return true
    end
    return false
end

function __gsoEzreal:_castQFarm()
    local meRange = myHero.range + myHero.boundingRadius
    local manaPercent = 100 * myHero.mana / myHero.maxMana
    local isLH = gsoAIO.Menu.menu.gsoezreal.qset.lasthit:Value() and (gsoAIO.Menu.menu.orb.keys.lastHit:Value() or gsoAIO.Menu.menu.orb.keys.harass:Value())
    local isLC = gsoAIO.Menu.menu.gsoezreal.qset.laneclear:Value() and gsoAIO.Menu.menu.orb.keys.laneClear:Value()
    if isLH or isLC then
        local canLH = manaPercent > gsoAIO.Menu.menu.gsoezreal.qset.qlh:Value()
        local canLC = manaPercent > gsoAIO.Menu.menu.gsoezreal.qset.qlc:Value()
        if not canLH and not canLC then return false end
        if self.shouldWait == true and Game.Timer() > self.shouldWaitT + 0.5 then
            self.shouldWait = false
        end
        local almostLH = false
        local laneClearT = {}
        local lastHitT = {}
        
        -- [[ set enemy minions ]]
        local mLH = gsoAIO.Menu.menu.orb.delays.lhDelay:Value()*0.001
        for i = 1, #gsoAIO.OB.enemyMinions do
            local eMinion = gsoAIO.OB.enemyMinions[i]
            local eMinion_handle	= eMinion.handle
            local eMinion_health	= eMinion.health
            local myHero_aaData		= myHero.attackData
            local myHero_pFlyTime	= gsoAIO.Utils:_getDistance(myHero.pos, eMinion.pos) / 2000
            for k1,v1 in pairs(gsoAIO.Farm.aAttacks) do
                for k2,v2 in pairs(gsoAIO.Farm.aAttacks[k1]) do
                    if v2.canceled == false and eMinion_handle == v2.to.handle then
                        local checkT	= Game.Timer()
                        local pEndTime	= v2.startTime + v2.pTime
                        if pEndTime > checkT and  pEndTime - checkT < myHero_pFlyTime - mLH then
                            eMinion_health = eMinion_health - v2.dmg
                        end
                    end
                end
            end
            local myHero_dmg = ((25 * myHero:GetSpellData(_Q).level) - 10) + (1.1 * myHero.totalDamage) + (0.4 * myHero.ap)
            if eMinion_health - myHero_dmg < 0 then
                lastHitT[#lastHitT+1] = eMinion
            else
                if eMinion.health - gsoAIO.Farm:_possibleDmg(eMinion, 2.5) - myHero_dmg < 0 then
                    almostLH = true
                    self.shouldWait = true
                    self.shouldWaitT = Game.Timer()
                else
                    laneClearT[#laneClearT+1] = eMinion
                end
            end
        end

        -- [[ lasthit ]]
        if isLH and canLH then
            local canCheckT = false
            for i = 1, #lastHitT do
                local unit = lastHitT[i]
                local unitPos = unit.pos
                local mePos = myHero.pos
                local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                local mHandle = unit.handle
                if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
            end
            if not canCheckT or (canCheckT and Game.Timer() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                for i = 1, #lastHitT do
                    local minion = lastHitT[i]
                    local minionPos = minion.pos
                    local mePos = myHero.pos
                    local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                    local mHandle = minion.handle
                    if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                        local distance = gsoAIO.Utils:_getDistance(mePos, minionPos)
                        if distance < 1150 and self:_castQ(minion, minionPos, mePos) then
                            gsoAIO.TS.LHTimers[0].tick = Game.Timer() + 0.75
                            gsoAIO.TS.LHTimers[0].id = mHandle
                            return true
                        end
                    end
                end
            end

        -- [[ laneclear ]]
        elseif isLC and canLC then

            local canCheckT = false
            for i = 1, #lastHitT do
                local unit = lastHitT[i]
                local unitPos = unit.pos
                local mePos = myHero.pos
                local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                local mHandle = unit.handle
                if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
            end
            if not canCheckT or (canCheckT and Game.Timer() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                for i = 1, #lastHitT do
                    local minion = lastHitT[i]
                    local minionPos = minion.pos
                    local mePos = myHero.pos
                    local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                    local mHandle = minion.handle
                    if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                        local distance = gsoAIO.Utils:_getDistance(mePos, minionPos)
                        if distance < 1150 and self:_castQ(minion, minionPos, mePos) then
                            gsoAIO.TS.LHTimers[0].tick = Game.Timer() + 0.75
                            gsoAIO.TS.LHTimers[0].id = mHandle
                            return true
                        end
                    end
                end
            end
            if not almostLH and not self.shouldWait then
                canCheckT = false
                for i = 1, #gsoAIO.OB.enemyHeroes do
                    local unit = gsoAIO.OB.enemyHeroes[i]
                    local unitPos = unit.pos
                    local mePos = myHero.pos
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
                if not canCheckT or (canCheckT and Game.Timer() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                    for i = 1, #gsoAIO.OB.enemyHeroes do
                        local unit = gsoAIO.OB.enemyHeroes[i]
                        local unitPos = unit.pos
                        local mePos = myHero.pos
                        local distance = gsoAIO.Utils:_getDistance(mePos, unitPos)
                        if gsoAIO.Utils:_valid(unit, true) and distance < 1150 and self:_castQ(unit, unitPos, mePos) then return true end
                    end
                end
                canCheckT = false
                for i = 1, #laneClearT do
                    local unit = laneClearT[i]
                    local unitPos = unit.pos
                    local mePos = myHero.pos
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
                if not canCheckT or (canCheckT and Game.Timer() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                    for i = 1, #laneClearT do
                        local minion = laneClearT[i]
                        local minionPos = minion.pos
                        local mePos = myHero.pos
                        local distance = gsoAIO.Utils:_getDistance(myHero.pos, minionPos)
                        if distance < 1150 and self:_castQ(minion, minionPos, mePos) then return true end
                    end
                end
            end
        end
    end
    return false
end

function __gsoEzreal:_tick()
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsoezreal.rset.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    if getTick - self.lastE > 1000 and Game.CanUseSpell(_E) == 0 then
        local dActions = gsoAIO.WndMsg.delayedSpell
        for k,v in pairs(dActions) do
            if k == 2 then
                if gsoAIO.Orb.dActionsC == 0 then
                    v[1]()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() return 0 end, 50 }
                    gsoAIO.Orb.enableAA = false
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.lastE = GetTickCount()
                    gsoAIO.WndMsg.delayedSpell[k] = nil
                    break
                end
                if GetTickCount() - v[2] > 125 then
                    gsoAIO.WndMsg.delayedSpell[k] = nil
                end
                break
            end
        end
    end
    if gsoAIO.Menu.menu.gsoezreal.rset.semir:Value() then
        local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
        local wMinus = getTick - self.lastW
        local wMinuss = getTick - gsoAIO.WndMsg.lastW
        local rMinus = getTick - self.lastR
        local rMinuss = getTick - gsoAIO.WndMsg.lastR
        local canRTime = wMinus > 350 and wMinuss > 350 and rMinus > 1000 and rMinuss > 1000
        local isRReady = canRTime and gsoAIO.Utils:_isReady(_R)
        if isRReady then
            local rTargets = {}
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local heroName = hero.charName
                if gsoAIO.Menu.menu.gsoezreal.rset.useon[heroName] and gsoAIO.Menu.menu.gsoezreal.rset.useon[heroName]:Value() then
                    rTargets[#rTargets+1] = hero
                end
            end
            local rrange = gsoAIO.Menu.menu.gsoezreal.rset.rrange:Value()
            local rTarget = gsoAIO.TS:_getTarget(rrange, false, false, rTargets)
            local rTargetPos = rTarget and rTarget.pos or nil
            if rTargetPos then
                local mePos = myHero.pos
                local sR = { delay = 0.25, range = rrange, width = 125, speed = 1600, sType = "line", col = false }
                local castpos,HitChance,pos = gsoAIO.TPred:GetBestCastPosition(rTarget, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
                local canRonTarget = HitChance > 0 and gsoAIO.Utils:_getDistance(mePos, castpos) < sR.range
                      canRonTarget = canRonTarget and gsoAIO.Utils:_getDistance(rTargetPos, castpos) < 500
                if canRonTarget then
                    local cPos = cursorPos
                    local extCastPos = mePos:Extended(castpos, 500)
                    Control.SetCursorPos(extCastPos)
                    gsoAIO.Orb.setCursor = extCastPos
                    Control.KeyDown(HK_R)
                    Control.KeyUp(HK_R)
                    self.lastR = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                end
            end
        end
    end
    
    -- AUTO Q :
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    local canQTime = qMinus > 1000 and qMinuss > 1000 and wMinus > 450 and wMinuss > 450 and eMinus > 650 and eMinuss > 650 and rMinuss > 1500
    local isComboQ = isCombo and gsoAIO.Menu.menu.gsoezreal.qset.combo:Value()
    local isHarassQ = isHarass and gsoAIO.Menu.menu.gsoezreal.qset.harass:Value()
    local isQReady = canQTime and gsoAIO.Utils:_isReady(_Q)
    if isQReady and not isComboQ and not isHarassQ then
        local manaPercent = 100 * myHero.mana / myHero.maxMana
        local isAutoQ = gsoAIO.Menu.menu.gsoezreal.autoq.enable:Value() and manaPercent > gsoAIO.Menu.menu.gsoezreal.autoq.mana:Value()
        local meRange = myHero.range + myHero.boundingRadius
        if isAutoQ then
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local unit = gsoAIO.OB.enemyHeroes[i]
                local unitPos = unit.pos
                local mePos = myHero.pos
                local distance = gsoAIO.Utils:_getDistance(mePos, unitPos)
                local isTargetAA = distance < meRange + unit.boundingRadius
                if gsoAIO.Utils:_valid(unit, true) and distance < 1150 and ( not isTargetAA or (isTargetAA and self.canQ) ) then
                    local sQ = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
                    local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(unit, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
                    local distMeToPredPos = gsoAIO.Utils:_getDistance(mePos, castpos)
                    local distUnitToPredPos = gsoAIO.Utils:_getDistance(unitPos, castpos)
                    if HitChance > 0 and castpos:ToScreen().onScreen and distMeToPredPos < sQ.range and distUnitToPredPos < 200 then
                        local cPos = cursorPos
                        Control.SetCursorPos(castpos)
                        gsoAIO.Orb.setCursor = castpos
                        Control.KeyDown(HK_Q)
                        Control.KeyUp(HK_Q)
                        self.lastQ = GetTickCount()
                        gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                        gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                        self.canW = false
                        break
                    end
                end
            end
        end
    end
end

function __gsoEzreal:_draw()
    if gsoAIO.Menu.menu.gsodraw.texts1.enableautoq:Value() then
        local mePos = myHero.pos:To2D()
        local posX = mePos.x - 50
        local posY = mePos.y
        if gsoAIO.Menu.menu.gsoezreal.autoq.enable:Value() then
            Draw.Text("Auto Q Enabled", gsoAIO.Menu.menu.gsodraw.texts1.sizeautoq:Value(), posX, posY, gsoAIO.Menu.menu.gsodraw.texts1.colorautoqe:Value()) 
        else
            Draw.Text("Auto Q Disabled", gsoAIO.Menu.menu.gsodraw.texts1.sizeautoq:Value(), posX, posY, gsoAIO.Menu.menu.gsodraw.texts1.colorautoqd:Value()) 
        end
    end
end