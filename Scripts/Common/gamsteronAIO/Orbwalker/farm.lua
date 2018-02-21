
class "__gsoFarm"

function __gsoFarm:__init()
    self.aaDmg          = myHero.totalDamage
    self.lastHit        = {}
    self.almostLH       = {}
    self.laneClear      = {}
    self.aAttacks       = {}
    self.shouldWaitT    = 0
    self.shouldWait     = false
end

function __gsoFarm:_tick()
    self.aaDmg   = myHero.totalDamage + gsoAIO.Callbacks._bonusDmg()
    if self.shouldWait == true and Game.Timer() > self.shouldWaitT + 0.5 then
        self.shouldWait = false
    end
    self:_setActiveAA()
    self:_handleActiveAA()
    self:_setEnemyMinions()
end

function __gsoFarm:_predPos(speed, pPos, unit)
    local unitPath = unit.pathing
    if unitPath.hasMovePath == true then
        local uPos    = unit.pos
        local ePos    = unitPath.endPos
        local distUP  = gsoAIO.Utils:_getDistance(pPos, uPos)
        local distEP  = gsoAIO.Utils:_getDistance(pPos, ePos)
        local unitMS  = unit.ms
        if distEP > distUP then
            return uPos:Extended(ePos, 50+(unitMS*(distUP / (speed - unitMS))))
        else
            return uPos:Extended(ePos, 50+(unitMS*(distUP / (speed + unitMS))))
        end
    end
    return unit.pos
end

function __gsoFarm:_possibleDmg(eMin, time)
    local result = 0
    for i = 1, #gsoAIO.OB.allyMinions do
        local aMin = gsoAIO.OB.allyMinions[i]
        local aaData  = aMin.attackData
        local aDmg    = (aMin.totalDamage*(1+aMin.bonusDamagePercent))
        if aaData.target == eMin.handle then
            local endT    = aaData.endTime
            local animT   = aaData.animationTime
            local windUpT = aaData.windUpTime
            local pSpeed  = aaData.projectileSpeed
            local pFlyT   = pSpeed > 0 and gsoAIO.Utils:_getDistance(aMin.pos, eMin.pos) / pSpeed or 0
            local pStartT = endT - animT
            local pEndT   = pStartT + pFlyT + windUpT
            local checkT  = Game.Timer()
            pEndT         = pEndT > checkT and pEndT or pEndT + animT + pFlyT
            while pEndT - checkT < time do
                result = result + aDmg
                pEndT = pEndT + animT + pFlyT
            end
        end
    end
    return result
end

function __gsoFarm:_setEnemyMinions()
    for i=1, #self.lastHit do self.lastHit[i]=nil end
    for i=1, #self.almostLH do self.almostLH[i]=nil end
    for i=1, #self.laneClear do self.laneClear[i]=nil end
    for i = 1, #gsoAIO.OB.enemyMinions do
        local eMinion = gsoAIO.OB.enemyMinions[i]
        local eMinion_handle	= eMinion.handle
        local distance = gsoAIO.Utils:_getDistance(myHero.pos, eMinion.pos)
        if distance < myHero.range + myHero.boundingRadius + eMinion.boundingRadius then
            local eMinion_health	= eMinion.health
            local myHero_aaData		= myHero.attackData
            local myHero_pFlyTime	= myHero_aaData.windUpTime + (distance / myHero_aaData.projectileSpeed) + (gsoAIO.Menu.menu.orb.delays.lhDelay:Value()*0.001)
            for k1,v1 in pairs(self.aAttacks) do
                for k2,v2 in pairs(self.aAttacks[k1]) do
                    if v2.canceled == false and eMinion_handle == v2.to.handle then
                        local checkT	= Game.Timer()
                        local pEndTime	= v2.startTime + v2.pTime
                        if pEndTime > checkT and  pEndTime - checkT < myHero_pFlyTime then
                            eMinion_health = eMinion_health - v2.dmg
                        end
                    end
                end
            end
            local myHero_dmg = self.aaDmg + gsoAIO.Callbacks._bonusDmgUnit(eMinion)
            if eMinion_health - myHero_dmg < 0 then
                self.lastHit[#self.lastHit+1] = { eMinion, eMinion_health }
            else
                if eMinion.health - self:_possibleDmg(eMinion, myHero.attackData.animationTime*3) - myHero_dmg < 0 then
                    self.shouldWait = true
                    self.shouldWaitT = Game.Timer()
                    self.almostLH[#self.almostLH+1] = eMinion
                else
                    self.laneClear[#self.laneClear+1] = eMinion
                end
            end
        end
    end
end

function __gsoFarm:_setActiveAA()
    for i = 1, #gsoAIO.OB.allyMinions do
        local aMinion = gsoAIO.OB.allyMinions[i]
        local aHandle	= aMinion.handle
        local aAAData	= aMinion.attackData
        if aAAData.endTime > Game.Timer() then
            for i = 1, #gsoAIO.OB.enemyMinions do
                local eMinion = gsoAIO.OB.enemyMinions[i]
                local eHandle	= eMinion.handle
                if eHandle == aAAData.target then
                    local checkT		= Game.Timer()
                    -- p -> projectile
                    local pSpeed  = aAAData.projectileSpeed
                    local aMPos   = aMinion.pos
                    local eMPos   = eMinion.pos
                    local pFlyT		= pSpeed > 0 and gsoAIO.Utils:_getDistance(aMPos, eMPos) / pSpeed or 0
                    local pStartT	= aAAData.endTime - aAAData.windDownTime
                    if not self.aAttacks[aHandle] then
                      self.aAttacks[aHandle] = {}
                    end
                    local aaID = aAAData.endTime
                    if checkT < pStartT + pFlyT then
                        if pSpeed > 0 then
                            if checkT > pStartT then
                                if not self.aAttacks[aHandle][aaID] then
                                    self.aAttacks[aHandle][aaID] = {
                                        canceled  = false,
                                        speed     = pSpeed,
                                        startTime = pStartT,
                                        pTime     = pFlyT,
                                        pos       = aMPos:Extended(eMPos, pSpeed*(checkT-pStartT)),
                                        from      = aMinion,
                                        fromPos   = aMPos,
                                        to        = eMinion,
                                        dmg       = (aMinion.totalDamage*(1+aMinion.bonusDamagePercent))-eMinion.flatDamageReduction
                                    }
                                end
                            elseif aMinion.pathing.hasMovePath == true then
                              --print("attack canceled")
                              self.aAttacks[aHandle][aaID] = {
                                  canceled  = true,
                                  from      = aMinion
                              }
                            end
                          elseif not self.aAttacks[aHandle][aaID] then
                              self.aAttacks[aHandle][aaID] = {
                                  canceled  = false,
                                  speed     = pSpeed,
                                  startTime = pStartT - aAAData.windUpTime,
                                  pTime     = aAAData.windUpTime,
                                  pos       = aMPos,
                                  from      = aMinion,
                                  fromPos   = aMPos,
                                  to        = eMinion,
                                  dmg       = (aMinion.totalDamage*(1+aMinion.bonusDamagePercent))-eMinion.flatDamageReduction
                              }
                          end
                    end
                    break
                end
            end
        end
    end
end

function __gsoFarm:_handleActiveAA()
    local aAttacks2 = self.aAttacks
    for k1,v1 in pairs(aAttacks2) do
        local count		= 0
        local checkT	= Game.Timer()
        for k2,v2 in pairs(aAttacks2[k1]) do
            count = count + 1
            if v2.speed == 0 and (not v2.from or v2.from.dead) then
                --print("dead")
                self.aAttacks[k1] = nil
                break
            end
            if v2.canceled == false then
                local ranged = v2.speed > 0
                if ranged == true then
                    self.aAttacks[k1][k2].pTime = gsoAIO.Utils:_getDistance(v2.fromPos, self:_predPos(v2.speed, v2.pos, v2.to)) / v2.speed
                end
                if checkT > v2.startTime + self.aAttacks[k1][k2].pTime or not v2.to or v2.to.dead then
                    self.aAttacks[k1][k2] = nil
                elseif ranged == true then
                    self.aAttacks[k1][k2].pos = v2.fromPos:Extended(v2.to.pos, (checkT-v2.startTime)*v2.speed)
                end
            end
        end
        if count == 0 then
            --print("no active attacks")
            self.aAttacks[k1] = nil
        end
    end
end