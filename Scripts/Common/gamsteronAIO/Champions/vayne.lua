
class "__gsoVayne"

function __gsoVayne:__init()
    require "MapPositionGOS"
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastE = 0
    self.lastReset = 0
    gsoAIO.Orb.baseAASpeed = 0.658
    gsoAIO.Orb.baseWindUp = 0.1754385
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
end

function __gsoVayne:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    
    if isTarget and afterAttack then
        
        -- USE E :
        local canETime = eMinus > 1000 and eMinuss > 1000
        local isComboE = isCombo and gsoAIO.Menu.menu.gsovayne.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Menu.menu.gsovayne.eset.harass:Value()
        local isEReady = (isComboE or isHarassE) and canETime and gsoAIO.Utils:_isReady(_E)
        if isEReady and self.canE then
            local targetPos = target.pos
            local mePos = myHero.pos
            local ePred = target:GetPrediction(2000,0.15)
            local canEonTarget = ePred and gsoAIO.Utils:_getDistance(ePred, targetPos) < 500 and not gsoAIO.Utils:_nearUnit(targetPos, target.networkID)
            if canEonTarget and gsoAIO.Utils:_checkWall(mePos, ePred, 475) and gsoAIO.Utils:_checkWall(mePos, targetPos, 475) then
                self.lastE = GetTickCount()
                local cPos = cursorPos
                Control.SetCursorPos(targetPos)
                gsoAIO.Orb.setCursor = targetPos
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                self.canQ = false
                return
            end
        end
    end
    if not isTarget or afterAttack then
    
        -- USE Q :
        local canQTime = qMinus > 1000 and qMinuss > 1000
        local isComboQ = isCombo and gsoAIO.Menu.menu.gsovayne.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Menu.menu.gsovayne.qset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime and gsoAIO.Utils:_isReady(_Q)
        if isQReady and (self.canQ or ( eMinus > 500 and eMinuss > 500 ) ) then
            local mePos = myHero.pos
            local meRange = myHero.range + myHero.boundingRadius
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local heroPos = hero.pos
                local distToMouse = gsoAIO.Utils:_getDistance(mePos, mousePos)
                local distToHero = gsoAIO.Utils:_getDistance(mePos, heroPos)
                local distToEndPos = gsoAIO.Utils:_getDistance(mePos, hero.pathing.endPos)
                local extRange
                if distToEndPos > distToHero then
                    extRange = distToMouse > 200 and 200 or distToMouse
                else
                    extRange = distToMouse > 300 and 300 or distToMouse
                end
                local extPos = mePos + (mousePos-mePos):Normalized() * extRange
                local distEnemyToExt = gsoAIO.Utils:_getDistance(extPos, heroPos)
                if gsoAIO.Utils:_valid(hero, true) and distEnemyToExt < meRange + hero.boundingRadius then
                    canQtoPos = true
                    Control.KeyDown(HK_Q)
                    Control.KeyUp(HK_Q)
                    self.lastQ = GetTickCount()
                    self.canE = false
                    return
                end
            end
        end
    end
end

function __gsoVayne:_canMove(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    if qMinus > 250 and qMinuss > 250 and eMinus > 500 and eMinuss > 500 then
        return true
    end
    return false
end

function __gsoVayne:_canAttack(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    if qMinus > 400 and qMinuss > 400 and eMinus > 600 and eMinuss > 600 then
        return true
    end
    return false
end

function __gsoVayne:_tick()
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff and buff.count > 0 and buff.name == "vaynetumblebonus" and Game.Timer() > self.lastReset + 1.2 and buff.duration > 5.8 then
            self.lastReset = Game.Timer()
            gsoAIO.Orb.aaReset = true
        end
    end
end