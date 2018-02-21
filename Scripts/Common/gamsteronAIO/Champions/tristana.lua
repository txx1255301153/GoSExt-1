
class "__gsoTristana"

function __gsoTristana:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.asNoQ = 0
    self.tristanaETar = nil
    self.eData = gsoAIO.Dmg.Damages["Tristana"].e
    self.rData = gsoAIO.Dmg.Damages["Tristana"].r
    self.getEData =
        function(stacks)
            return
            {
                dmgAP = self.eData.dmgAP(),
                dmgAD = self.eData.dmgAD(stacks),
                dmgType = self.eData.dmgType
            }
        end
    self.getRData =
        function()
            return
            {
                dmgAP = self.rData.dmgAP(),
                dmgType = self.rData.dmgType
            }
        end
    gsoAIO.Orb.baseAASpeed = 0.656
    gsoAIO.Orb.baseWindUp = 0.1480066
    gsoAIO.Callbacks:_setOnAttack(function(target) self:_onAttack(target) end)
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setAASpeed(function() return self:_aaSpeed() end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
end

function __gsoTristana:_onAttack(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    if isTarget then
        -- USE Q :
        local canQTime = qMinus > 1000 and qMinuss > 1000 and wMinuss > 750
        local isComboQ = isCombo and gsoAIO.Menu.menu.gsotristana.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Menu.menu.gsotristana.qset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime and Game.CanUseSpell(_Q) == 0
        if isQReady then
            self.asNoQ = myHero.attackSpeed
            self.lastQ = GetTickCount()
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
        end
    end
end

function __gsoTristana:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local eMinus = getTick - self.lastE
    local rMinus = getTick - self.lastR
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    if isTarget and Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 ) then
        local canQTime = qMinus > 1000 and qMinuss > 1000 and wMinuss > 750 and eMinus > 250 and eMinuss > 250 and rMinus > 250 and rMinuss > 250
        local isComboQ = isCombo and gsoAIO.Menu.menu.gsotristana.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Menu.menu.gsotristana.qset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime and Game.CanUseSpell(_Q) == 0
        if isQReady then
            self.asNoQ = myHero.attackSpeed
            self.lastQ = GetTickCount()
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
        end
    end
end

function __gsoTristana:_canMove(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local eMinus = getTick - self.lastE
    local rMinus = getTick - self.lastR
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if wMinuss > 500 and eMinus > 100 and eMinuss > 100 and rMinus > 100 and rMinuss > 100 then
        return true
    end
    return false
end

function __gsoTristana:_canAttack(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local eMinus = getTick - self.lastE
    local rMinus = getTick - self.lastR
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    if isTarget then
        
        -- USE R :
        local canRTime = wMinuss > 250 and eMinus > 450 and eMinuss > 450 and rMinus > 1000 and rMinuss > 1000
        local isRReady = (isCombo or isHarass) and canRTime and gsoAIO.Menu.menu.gsotristana.rset.ks:Value() and gsoAIO.Utils:_isReady(_R)
        if isRReady then
            local mePos = myHero.pos
            local meRange = myHero.range + ( myHero.boundingRadius * 0.5 )
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local unit = gsoAIO.OB.enemyHeroes[i]
                local unitPos = unit and unit.pos or nil
                local canRonUnit = unitPos and gsoAIO.Utils:_valid(unit, false) and gsoAIO.Utils:_getDistance(unitPos, mePos) < meRange + ( unit.boundingRadius * 0.5 )
                      canRonUnit = canRonUnit and not gsoAIO.Utils:_nearUnit(unitPos, unit.networkID)
                if canRonUnit then
                    local rDmg = gsoAIO.Dmg.PredHP(unit, self.getRData())
                    local checkEDmg = self.tristanaETar and self.tristanaETar.unit.networkID == unit.networkID
                    local eDmg = checkEDmg and gsoAIO.Dmg.PredHP(unit, self.getEData(self.tristanaETar.stacks)) or 0
                    local unitKillable = eDmg + rDmg > unit.health + (unit.hpRegen * 2)
                    if unitKillable then
                        local cPos = cursorPos
                        Control.SetCursorPos(unitPos)
                        gsoAIO.Orb.setCursor = unitPos
                        Control.KeyDown(HK_R)
                        Control.KeyUp(HK_R)
                        self.lastR = GetTickCount()
                        gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                        gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                        gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.1 }
                        return false
                    end
                end
            end
        end
        
        -- USE E :
        local canETime = wMinuss > 250 and eMinus > 1000 and eMinuss > 1000 and rMinus > 600 and rMinuss > 600
        local isComboE = isCombo and gsoAIO.Menu.menu.gsotristana.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Menu.menu.gsotristana.eset.harass:Value()
        local isEReady = (isComboE or isHarassE) and canETime and gsoAIO.Utils:_isReady(_E) and Game.Timer() > gsoAIO.Orb.lAttack + (gsoAIO.Orb.animT * 0.5)
        if isEReady then
            local targetPos = target.pos
            local targetID = target.networkID
            if not gsoAIO.Utils:_nearUnit(targetPos, targetID) then
                local cPos = cursorPos
                self.lastE = GetTickCount()
                Control.SetCursorPos(targetPos)
                gsoAIO.Orb.setCursor = targetPos
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                self.tristanaETar = { id = targetID, stacks = 1, unit = target }
                gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.1 }
                return false
            end
        end
    end
    if wMinuss > 800 and eMinus > 200 and eMinuss > 200 and rMinus > 200 and rMinuss > 200 then
        return true
    end
    return false
end

function __gsoTristana:_aaSpeed()
    local qDiff = GetTickCount() - gsoAIO.WndMsg.lastQ
    if qDiff > 7000 and qDiff < 8000 then
        return self.asNoQ
    end
    return myHero.attackSpeed
end

function __gsoTristana:_tick()
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero  = gsoAIO.OB.enemyHeroes[i]
        for i = 0, hero.buffCount do
            local buff = hero:GetBuff(i)
            if buff and buff.count > 0 and buff.duration > 1 and buff.name:lower() == "tristanaechargesound" and self.tristanaETar and not self.tristanaETar.endTime then
                self.tristanaETar.endTime = Game.Timer() + buff.duration - gsoAIO.Utils.minPing
            end
        end
    end
    if self.tristanaETar and self.tristanaETar.endTime and Game.Timer() > self.tristanaETar.endTime then
        self.tristanaETar = nil
    end
    local getTick = GetTickCount()
    if getTick - self.lastW > 1000 and Game.CanUseSpell(_W) == 0 then
        local dActions = gsoAIO.WndMsg.delayedSpell
        for k,v in pairs(dActions) do
            if k == 1 then
                if gsoAIO.Orb.dActionsC == 0 then
                    v[1]()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() return 0 end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.lastW = GetTickCount()
                    gsoAIO.WndMsg.delayedSpell[k] = nil
                    gsoAIO.Orb.lMove = 0
                    break
                end
                if GetTickCount() - v[2] > 125 then
                    gsoAIO.WndMsg.delayedSpell[k] = nil
                end
                break
            end
        end
    end
end