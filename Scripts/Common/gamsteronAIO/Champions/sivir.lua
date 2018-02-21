
class "__gsoSivir"

function __gsoSivir:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastReset = 0
    self.asNoW = myHero.attackSpeed
    gsoAIO.Orb.baseAASpeed = 0.625
    gsoAIO.Orb.baseWindUp = 0.1199999
    gsoAIO.Callbacks:_setOnMove(function(target) return self:_onMove(target) end)
    gsoAIO.Callbacks:_setAASpeed(function() return self:_aaSpeed() end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
end

function __gsoSivir:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    if isTarget and Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 ) then
        local canWTime = wMinus > 1000 and wMinuss > 1000
        local isComboW = isCombo and gsoAIO.Menu.menu.gsosivir.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Menu.menu.gsosivir.wset.harass:Value()
        local isWReady = (isComboW or isHarassW) and canWTime and Game.CanUseSpell(_W) == 0
        if isWReady then
            self.asNoW = myHero.attackSpeed
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            self.lastW = GetTickCount()
            self.canQ = false
            gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.aaReset = true end, endTime = Game.Timer() + 0.05 }
            return
        end
    end
    if not isTarget or afterAttack then
        local canQTime = qMinus > 1000 and qMinuss > 1000
        local isComboQ = isCombo and gsoAIO.Menu.menu.gsosivir.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Menu.menu.gsosivir.qset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime and gsoAIO.Utils:_isReady(_Q)
              isQReady = isQReady and ( not isTarget or (isTarget and self.canQ) )
        if isQReady then
            local qTarget = isTarget and target or gsoAIO.TS:_getTarget(1250, false, false, gsoAIO.OB.enemyHeroes)
            local qTargetPos = qTarget and qTarget.pos or nil
            if qTargetPos then
                local sQ = { delay = 0.25, range = 1250, width = 60, speed = 1350, sType = "line", col = false }
                local mePos = myHero.pos
                local castpos,HitChance,pos = gsoAIO.TPred:GetBestCastPosition(qTarget, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sQ.range and gsoAIO.Utils:_getDistance(qTargetPos, castpos) < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_Q)
                    Control.KeyUp(HK_Q)
                    self.lastQ = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    return
                end
            end
        end
    end
end

function __gsoSivir:_aaSpeed()
    local wDiff = GetTickCount() - gsoAIO.WndMsg.lastW - (gsoAIO.Utils.maxPing*1000)
    if wDiff > 3500 and wDiff < 4500 then
        return self.asNoW
    end
    return myHero.attackSpeed
end

function __gsoSivir:_canMove(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    if qMinus > 250 and qMinuss > 250 then
        return true
    end
    return false
end

function __gsoSivir:_canAttack(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    if qMinus > 350 and qMinuss > 350 then
        return true
    end
    return false
end