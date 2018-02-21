
class "__gsoTeemo"

function __gsoTeemo:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastR = 0
    gsoAIO.Orb.baseAASpeed = 0.69
    gsoAIO.Orb.baseWindUp = 0.215743
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
end

function __gsoTeemo:_onMove(target)
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
    if not isTarget or afterAttack then
        
        -- USE Q :
        local canQTime = qMinus > 1000 and qMinuss > 1000 and rMinus > 750 and rMinuss > 750
        local isComboQ = isCombo and gsoAIO.Menu.menu.gsoteemo.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Menu.menu.gsoteemo.qset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime and gsoAIO.Utils:_isReady(_Q)
        if isQReady and (not isTarget or (isTarget and self.canQ)) then
            local qTarget = isTarget and target or gsoAIO.TS:_getTarget(680, false, false, gsoAIO.OB.enemyHeroes)
            local qTargetPos = qTarget and qTarget.pos or nil
            if qTargetPos and not gsoAIO.Utils:_nearUnit(qTargetPos, qTarget.networkID) then
                local cPos = cursorPos
                self.lastQ = GetTickCount()
                Control.SetCursorPos(qTargetPos)
                gsoAIO.Orb.setCursor = qTargetPos
                Control.KeyDown(HK_Q)
                Control.KeyUp(HK_Q)
                gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                self.canR = false
                gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
                return
            end
        end
        
        -- USE R :
        local canRTime = qMinus > 350 and qMinuss > 350 and rMinus > 1000 and rMinuss > 1000
        local isComboR = isCombo and gsoAIO.Menu.menu.gsoteemo.rset.combo:Value()
        local isHarassR = isHarass and gsoAIO.Menu.menu.gsoteemo.rset.harass:Value()
        local isRReady = (isComboR or isHarassR) and canRTime and gsoAIO.Utils:_isReady(_R)
        if isRReady and (not isTarget or (isTarget and self.canR)) then
            local canRonTarget = false
            local castPos = nil
            local mePos = myHero.pos
            local rRange = 150 + ( 250 * myHero:GetSpellData(_R).level )
            local checkImmo = gsoAIO.Menu.menu.gsoteemo.rset.immo:Value()
            if checkImmo then
                for i = 1, #gsoAIO.OB.enemyHeroes do
                    local unit = gsoAIO.OB.enemyHeroes[i]
                    local unitPos = unit.pos
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < rRange and gsoAIO.Utils:_isImmobile(unit) then
                        canRonTarget = true
                        castPos = unitPos
                        break
                    end
                end
            else
                local isTeemoTarget = isTarget and gsoAIO.Utils:_getDistance(mePos, target.pos) < rRange
                local rTarget = isTeemoTarget and target or gsoAIO.TS:_getTarget(rRange, false, false, gsoAIO.OB.enemyHeroes)
                if rTarget then
                    local sR = { delay = 0.25, range = rRange, width = 200, speed = 1000, sType = "circular", col = false }
                    local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(rTarget, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
                    if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sR.range and gsoAIO.Utils:_getDistance(rTarget.pos, castpos) < 500 then
                        canRonTarget = true
                        castPos = castpos
                    end
                end
            end
            if canRonTarget then
                local cPos = cursorPos
                Control.SetCursorPos(castPos)
                gsoAIO.Orb.setCursor = castPos
                Control.KeyDown(HK_R)
                Control.KeyUp(HK_R)
                self.lastR = GetTickCount()
                gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
                self.canQ = false
                return
            end
        end
        
        -- USE W :
        local canWTime = wMinus > 1000 and wMinuss > 1000
        local isComboW = isCombo and gsoAIO.Menu.menu.gsoteemo.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Menu.menu.gsoteemo.wset.harass:Value()
        local isWReady = (isComboW or isHarassW) and canWTime and Game.CanUseSpell(_W) == 0
        if isWReady then
            local mePos = myHero.pos
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local unit = gsoAIO.OB.enemyHeroes[i]
                local unitPos = unit.pos
                if gsoAIO.Utils:_getDistance(mePos, unitPos) < gsoAIO.Menu.menu.gsoteemo.wset.mindist:Value() then
                    self.lastW = GetTickCount()
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    return
                end
            end
        end
    end
end

function __gsoTeemo:_canMove(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if qMinus > 250 and qMinuss > 250 and rMinus > 250 and rMinuss > 250 then
        return true
    end
    return false
end

function __gsoTeemo:_canAttack(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if qMinus > 350 and qMinuss > 350 and rMinus > 350 and rMinuss > 350 then
        return true
    end
    return false
end