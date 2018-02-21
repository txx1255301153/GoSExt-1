
class "__gsoJinx"

function __gsoJinx:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.hasQBuff = false
    self.loadedChamps = false
    gsoAIO.Orb.baseAASpeed = 0.625
    gsoAIO.Orb.baseWindUp = 0.17708122
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
end

function __gsoJinx:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    
    -- USE E :
    local canETime = wMinus > 550 and wMinuss > 550 and eMinus > 1000 and eMinuss > 1000 and rMinus > 550 and rMinuss > 550
    local isComboE = isCombo and gsoAIO.Menu.menu.gsojinx.eset.combo:Value()
    local isHarassE = isHarass and gsoAIO.Menu.menu.gsojinx.eset.harass:Value()
    local isEReady = (isComboE or isHarassE) and canETime and gsoAIO.Utils:_isReady(_E)
    if isEReady then
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local unit = gsoAIO.OB.enemyHeroes[i]
            local unitPos = unit and unit.pos or nil
            if unitPos and gsoAIO.Utils:_getDistance(myHero.pos, unitPos) < 900 and gsoAIO.Utils:_isImmobile(unit) and unitPos:ToScreen().onScreen then
                local cPos = cursorPos
                Control.SetCursorPos(unitPos)
                gsoAIO.Orb.setCursor = unitPos
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                self.lastE = GetTickCount()
                gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                return
            end
        end
    end
    
    -- USE Q :
    local canQTime = qMinus > 650 and qMinuss > 650 and wMinus > 550 and wMinuss > 550 and rMinus > 550 and rMinuss > 550
    local isComboQ = isCombo and gsoAIO.Menu.menu.gsojinx.qset.combo:Value()
    local isHarassQ = isHarass and gsoAIO.Menu.menu.gsojinx.qset.harass:Value()
    local isQReady = (isComboQ or isHarassQ) and canQTime and Game.CanUseSpell(_Q) == 0
    if isQReady then
        local mePos = myHero.pos
        local canCastQ = false
        local qRange = 575 + ( 25 * myHero:GetSpellData(_Q).level )
        if not isTarget and not self.hasQBuff and gsoAIO.Utils:_countEnemyHeroesInRange(mePos, qRange + 300) > 0 then
            canCastQ = true
        end
        if isTarget and self.hasQBuff and gsoAIO.Utils:_getDistance(mePos, target.pos) < 525 + myHero.boundingRadius then
            canCastQ = true
        end
        if canCastQ then
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            self.lastQ = GetTickCount()
            return
        end
    end
    
    if not isTarget or afterAttack then
        
        local wout = gsoAIO.Menu.menu.gsojinx.wset.wout:Value()
        if not wout or (wout and not isTarget) then
            -- USE W :
            local canWTime = wMinus > 1000 and wMinuss > 1000 and rMinus > 550 and rMinuss > 550
            local isComboW = isCombo and gsoAIO.Menu.menu.gsojinx.wset.combo:Value()
            local isHarassW = isHarass and gsoAIO.Menu.menu.gsojinx.wset.harass:Value()
            local isWReady = (isComboW or isHarassW) and canWTime and gsoAIO.Utils:_isReady(_W)
            if isWReady then
                local wTarget = isTarget and target or gsoAIO.TS:_getTarget(1175, false, false, gsoAIO.OB.enemyHeroes)
                local wTargetPos = wTarget and wTarget.pos or nil
                if wTargetPos then
                    local mePos = myHero.pos
                    local sW = { delay = 0.5, range = 1450, width = 70, speed = 3200, sType = "line", col = true }
                    local castpos,HitChance,pos = gsoAIO.TPred:GetBestCastPosition(wTarget, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
                    local canWonTarget = HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sW.range
                          canWonTarget = canWonTarget and gsoAIO.Utils:_getDistance(wTargetPos, castpos) < 500
                    if canWonTarget then
                        local cPos = cursorPos
                        Control.SetCursorPos(castpos)
                        gsoAIO.Orb.setCursor = castpos
                        Control.KeyDown(HK_W)
                        Control.KeyUp(HK_W)
                        self.lastW = GetTickCount()
                        gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                        gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                        return
                    end
                end
            end
        end
    end
end

function __gsoJinx:_canMove(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if wMinus > 500 and wMinuss > 500 and rMinus > 500 and rMinuss > 500 then
        return true
    end
    return false
end

function __gsoJinx:_canAttack(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if wMinus > 600 and wMinuss > 600 and rMinus > 600 and rMinuss > 600 then
        return true
    end
    return false
end

function __gsoJinx:_tick()
    self.hasQBuff = gsoAIO.Utils:_hasBuff(myHero, "jinxq")
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsojinx.rset.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    if gsoAIO.Menu.menu.gsojinx.rset.semir:Value() then
        local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
        local wMinus = getTick - self.lastW
        local wMinuss = getTick - gsoAIO.WndMsg.lastW
        local rMinus = getTick - self.lastR
        local rMinuss = getTick - gsoAIO.WndMsg.lastR
        local canRTime = wMinus > 550 and wMinuss > 550 and rMinus > 1000 and rMinuss > 1000
        local isRReady = canRTime and gsoAIO.Utils:_isReady(_R)
        if isRReady then
            local rTargets = {}
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local heroName = hero.charName
                if gsoAIO.Menu.menu.gsojinx.rset.useon[heroName] and gsoAIO.Menu.menu.gsojinx.rset.useon[heroName]:Value() then
                    rTargets[#rTargets+1] = hero
                end
            end
            local rrange = gsoAIO.Menu.menu.gsojinx.rset.rrange:Value()
            local rTarget = gsoAIO.TS:_getTarget(rrange, false, false, rTargets)
            local rTargetPos = rTarget and rTarget.pos or nil
            if rTargetPos then
                local mePos = myHero.pos
                local sR = { delay = 0.5, range = rrange, width = 225, speed = 1750, sType = "line", col = false }
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
end