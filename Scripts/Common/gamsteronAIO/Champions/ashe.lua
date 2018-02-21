
class "__gsoAshe"

function __gsoAshe:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastR = 0
    self.QEndTime = 0
    self.hasQBuff = false
    self.asNoQ = myHero.attackSpeed
    self.loadedChamps = false
    gsoAIO.Orb.baseAASpeed = 0.658
    gsoAIO.Orb.baseWindUp = 0.2192982
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setAASpeed(function() return self:_aaSpeed() end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setBonusDmgUnit(function(unit) return self:_dmgUnit(unit) end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
end

function __gsoAshe:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    
    -- USE Q :
    local canQTime = qMinus > 1000 and qMinuss > 1000 and wMinus > 350 and wMinuss > 350 and rMinus > 350 and rMinuss > 350
    local isComboQ = isCombo and gsoAIO.Menu.menu.gsoashe.qset.combo:Value()
    local isHarassQ = isHarass and gsoAIO.Menu.menu.gsoashe.qset.harass:Value()
    local isQReady = (isComboQ or isHarassQ) and canQTime and Game.CanUseSpell(_Q) == 0
    if isQReady and afterAttack and isTarget and Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 ) then
        self.asNoQ = myHero.attackSpeed
        self.lastQ = GetTickCount()
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        self.canW = false
        return
    end
    
    if not isTarget or afterAttack then
        
        -- USE R :
        local canRTime = wMinus > 350 and wMinuss > 350 and rMinus > 1000 and rMinuss > 1000
        local isComboRd = isCombo and gsoAIO.Menu.menu.gsoashe.rset.rcd:Value()
        local isHarassRd = isHarass and gsoAIO.Menu.menu.gsoashe.rset.rcd:Value()
        local isComboRi = isCombo and gsoAIO.Menu.menu.gsoashe.rset.rci:Value()
        local isHarassRi = isHarass and gsoAIO.Menu.menu.gsoashe.rset.rhi:Value()
        local isRdReady = (isComboRd or isHarassRd)
        local isRiReady = (isComboRi or isHarassRi)
        if (isRdReady or isRiReady) and canRTime and gsoAIO.Utils:_isReady(_R) and (not isTarget or (isTarget and self.canR)) then
            local mePos = myHero.pos
            local canRonTarget = false
            local rPos = nil
            if isRdReady then
                local t = nil
                local menuDist = gsoAIO.Menu.menu.gsoashe.rset.rdist:Value()
                for i = 1, #gsoAIO.OB.enemyHeroes do
                    local hero = gsoAIO.OB.enemyHeroes[i]
                    local distance = gsoAIO.Utils:_getDistance(mePos, hero.pos)
                    if gsoAIO.Utils:_valid(hero, false) and distance < menuDist then
                        menuDist = distance
                        t = hero
                    end
                end
                if t then
                    local tPos = t.pos
                    local sR = { delay = 0.25, range = 1500, width = 125, speed = 1600, sType = "line", col = false }
                    local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(t, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
                    local canRd = HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(t.pos, castpos) < 500
                          canRd = canRd and gsoAIO.Utils:_pointOnLineSegment(castpos.x, castpos.z, tPos.x, tPos.z, mePos.x, mePos.z)
                    if canRd then
                        canRonTarget = true
                        rPos = castpos
                    end
                end
            end
            if not canRonTarget and isRiReady then
                for i = 1, #gsoAIO.OB.enemyHeroes do
                    local unit = gsoAIO.OB.enemyHeroes[i]
                    local unitPos = unit and unit.pos or nil
                    if unitPos and gsoAIO.Utils:_valid(unit, false) and gsoAIO.Utils:_getDistance(mePos, unitPos) < 1000 and gsoAIO.Utils:_isImmobile(unit) then
                        local rPred = unitPos
                        if rPred and rPred:ToScreen().onScreen then
                            canRonTarget = true
                            rPos = rPred
                            break
                        end
                    end
                end
            end
            if canRonTarget then
                local cPos = cursorPos
                self.lastR = GetTickCount()
                Control.SetCursorPos(rPos)
                gsoAIO.Orb.setCursor = rPos
                Control.KeyDown(HK_R)
                Control.KeyUp(HK_R)
                gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                gsoAIO.Orb.lMove = 0
                self.canW = false
                return
            end
        end
        
        -- USE W :
        local canWTime = wMinus > 1000 and wMinuss > 1000 and rMinus > 700 and rMinuss > 700
        local isComboW = isCombo and gsoAIO.Menu.menu.gsoashe.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Menu.menu.gsoashe.wset.harass:Value()
        local isWReady = (isComboW or isHarassW) and canWTime and gsoAIO.Utils:_isReady(_W)
        if isWReady and (not isTarget or (isTarget and self.canW)) then
            local wTarget = isTarget and target or gsoAIO.TS:_getTarget(1200, false, false, gsoAIO.OB.enemyHeroes)
            if wTarget ~= nil then
                local mePos = myHero.pos
                local sW = { delay = 0.25, range = 1200, width = 75, speed = 2000, sType = "line", col = true }
                local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(wTarget, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sW.range and gsoAIO.Utils:_getDistance(wTarget.pos, castpos) < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    self.lastW = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    gsoAIO.Orb.lMove = 0
                    self.canR = false
                    return
                end
            end
        end
    end
end

function __gsoAshe:_aaSpeed()
    local num1 = self.QEndTime - GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    if num1 > -1500 and num1 < 0 then
        return self.asNoQ
    end
    return myHero.attackSpeed
end

function __gsoAshe:_canMove(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if wMinus > 250 and wMinuss > 250 and rMinus > 250 and rMinuss > 250 then
        return true
    end
    return false
end

function __gsoAshe:_canAttack(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if wMinus > 350 and wMinuss > 350 and rMinus > 350 and rMinuss > 350 then
        return true
    end
    return false
end

function __gsoAshe:_tick()
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsoashe.rset.semirmenu.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    local hasQBuff = false
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        local buffName = buff and buff.name or nil
        if buffName and buff.count > 0 and buff.duration > 0 and buffName == "AsheQAttack" then
            hasQBuff = true
            self.QEndTime = GetTickCount() + (buff.duration*1000)
            break
        end
    end
    if gsoAIO.Menu.menu.gsoashe.rset.semirmenu.semir:Value() then
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
                if gsoAIO.Menu.menu.gsoashe.rset.semirmenu.useon[heroName] and gsoAIO.Menu.menu.gsoashe.rset.semirmenu.useon[heroName]:Value() then
                    rTargets[#rTargets+1] = hero
                end
            end
            local rrange = gsoAIO.Menu.menu.gsoashe.rset.semirmenu.rrange:Value()
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
                    gsoAIO.Orb.lMove = 0
                end
            end
        end
    end
    self.hasQBuff = hasQBuff
end

function __gsoAshe:_dmgUnit(unit)
    local dmg = myHero.totalDamage
    local crit = 0.1 + myHero.critChance
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == "ashepassiveslow" then
            local aacompleteT = myHero.attackData.windUpTime + (gsoAIO.Utils:_getDistance(myHero.pos, unit.pos) / myHero.attackData.projectileSpeed)
            if aacompleteT + 0.1 < buff.duration then
                return dmg * crit
            end
        end
    end
    return 0
end