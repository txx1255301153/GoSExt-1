
class "__gsoDraven"

function __gsoDraven:__init()
    self.qParticles = {}
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.lMove = 0
    gsoAIO.Orb.baseAASpeed = 0.679
    gsoAIO.Orb.baseWindUp = 0.1561439
    gsoAIO.Callbacks:_setMousePos(function() return self:_setMousePos() end)
    gsoAIO.Callbacks:_setOnMove(function(target) return self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
    gsoAIO.Callbacks:_setDraw(function() self:_draw() end)
end

function __gsoDraven:_onAttack(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    
    if isTarget then
    
        -- USE Q :
        local canQTime = qMinus > 1000 and qMinuss > 1000 and eMinus > 250 and eMinuss > 250
        local isComboQ = isCombo and gsoAIO.Menu.menu.gsodraven.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Menu.menu.gsodraven.qset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime and Game.CanUseSpell(_Q) == 0
        if isQReady then
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            self.lastQ = GetTickCount()
        end
    end
end

function __gsoDraven:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    
    if not isTarget or afterAttack then
        
        -- USE E :
        local canETime = wMinus > 250 and wMinuss > 250 and eMinus > 1000 and eMinuss > 1000
        local isComboE = isCombo and gsoAIO.Menu.menu.gsodraven.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Menu.menu.gsodraven.eset.harass:Value()
        local isEReady = (isComboE or isHarassE) and canETime and gsoAIO.Utils:_isReady(_E)
        if isEReady then
            local eTarget = isTarget and target or gsoAIO.TS:_getTarget(1050, false, false, gsoAIO.OB.enemyHeroes)
            if eTarget then
                local sE = { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false }
                local mePos = myHero.pos
                local targetPos = eTarget.pos
                local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(eTarget, sE.delay, sE.width*0.5, sE.range, sE.speed, mePos, sE.col, sE.sType)
                local distToPred = gsoAIO.Utils:_getDistance(mePos, castpos)
                local distToTarget = gsoAIO.Utils:_getDistance(mePos, targetPos)
                local isOnLine = gsoAIO.Utils:_pointOnLineSegment(castpos.x, castpos.z, mePos.x, mePos.z, targetPos.x, targetPos.z)
                if HitChance > 0 and castpos:ToScreen().onScreen and distToPred < sE.range and distToPred > 125 and distToTarget > 125 and gsoAIO.Utils:_getDistance(targetPos, castpos) < 250 and isOnLine then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    self.lastE = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    return
                end
            end
        end
        
        -- USE W :
        local canWTime = wMinus > 1000 and wMinuss > 1000 and eMinus > 250 and eMinuss > 250
        local isComboW = isCombo and gsoAIO.Menu.menu.gsodraven.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Menu.menu.gsodraven.wset.harass:Value()
        local isWReady = (isComboW or isHarassW) and canWTime and gsoAIO.Utils:_isReady(_W)
        if isWReady then
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero  = gsoAIO.OB.enemyHeroes[i]
                local heroPos = hero and hero.pos or nil
                local canWifEnemy = heroPos and gsoAIO.Utils:_valid(hero, false)
                      canWifEnemy = isTarget or (not isTarget and gsoAIO.Utils:_getDistance(myHero.pos, heroPos) < gsoAIO.Menu.menu.gsodraven.wset.hdist:Value())
                if canWifEnemy then
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    self.lastW = GetTickCount()
                    return
                end
            end
        end
    end
end

function __gsoDraven:_canMove(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    if wMinus > 250 and wMinuss > 250 and eMinus > 250 and eMinuss > 250 then
        return true
    end
    return false
end

function __gsoDraven:_canAttack(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    if wMinus > 150 and wMinuss > 150 and eMinus > 400 and eMinuss > 400 then
        return true
    end
    return false
end

function __gsoDraven:_setMousePos()
    if not gsoAIO.Menu.menu.gsodraven.aset.catch:Value() then return nil end
    local qPos = nil
    local kID = nil
    local num = 1000000000
    for k,v in pairs(self.qParticles) do
        if not v.success then
            local mePos = myHero.pos
            local distanceToHero = gsoAIO.Utils:_getDistance(v.pos, mePos)
            local distanceToMouse = gsoAIO.Utils:_getDistance(v.pos, mousePos)
            local qMode = gsoAIO.Menu.menu.gsodraven.aset.dist.mode:Value()
            if qMode == 1 and distanceToMouse < num then
                qPos = v.pos
                num = distanceToMouse
                kID = k
            elseif qMode == 2 and distanceToHero < num then
                qPos = v.pos
                num = distanceToHero
                kID = k
            else
                self.qParticles[k].active = false
            end
        end
    end
    if qPos ~= nil then
        qPos = qPos:Extended(mousePos, gsoAIO.Menu.menu.gsodraven.aset.dist.stopmove:Value())
        local stopNearUnit = gsoAIO.Utils:_nearTurret(qPos, 0, true) or gsoAIO.Utils:_nearHeroes(qPos, 0, true) or gsoAIO.Utils:_nearMinions(qPos, 0, true)
        local stopUnderTurret = gsoAIO.Menu.menu.gsodraven.aset.catcht:Value() and gsoAIO.Utils:_nearTurret(qPos, 775, false)
        local stopOutOfAARange = gsoAIO.Menu.menu.gsodraven.aset.catcho:Value() and not gsoAIO.Utils:_nearHeroes(qPos, myHero.range + myHero.boundingRadius + 30, false)
        if qPos and ( stopNearUnit or stopUnderTurret or stopOutOfAARange ) then
            qPos = nil
            self.qParticles[kID].active = false
        else
            self.qParticles[kID].active = true
        end
    end
    return qPos
end

function __gsoDraven:_tick()
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsodraven.rset.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    if gsoAIO.Menu.menu.gsodraven.rset.semir:Value() then
        local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
        local eMinus = getTick - self.lastE
        local eMinuss = getTick - gsoAIO.WndMsg.lastE
        local rMinus = getTick - self.lastR
        local rMinuss = getTick - gsoAIO.WndMsg.lastR
        local canRTime = eMinus > 350 and eMinuss > 350 and rMinus > 1000 and rMinuss > 1000
        local isRReady = canRTime and gsoAIO.Utils:_isReady(_R)
        if isRReady then
            local rTargets = {}
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local heroName = hero.charName
                if gsoAIO.Menu.menu.gsodraven.rset.useon[heroName] and gsoAIO.Menu.menu.gsodraven.rset.useon[heroName]:Value() then
                    rTargets[#rTargets+1] = hero
                end
            end
            local rrange = gsoAIO.Menu.menu.gsodraven.rset.rrange:Value()
            local rTarget = gsoAIO.TS:_getTarget(rrange, false, false, rTargets)
            local rTargetPos = rTarget and rTarget.pos or nil
            if rTargetPos then
                local mePos = myHero.pos
                local sR = { delay = 0.25, range = rrange, width = 125, speed = 2000, sType = "line", col = false }
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
    local mePos = myHero.pos
    for i = 1, Game.ParticleCount() do
        local particle = Game.Particle(i)
        local particlePos = particle and particle.pos or nil
        if particlePos and gsoAIO.Utils:_getDistance(mePos, particlePos) < 500 and particle.name == "Draven_Base_Q_reticle" then
            local particleID = particle.handle
            if not self.qParticles[particleID] then
                self.qParticles[particleID] = { pos = particlePos, tick = GetTickCount(), success = false, active = false }
                gsoAIO.Orb.lMove = 0
            end
        end
    end
    for k,v in pairs(self.qParticles) do
        local timerMinus = GetTickCount() - v.tick
        local numMenu = 900 + gsoAIO.Menu.menu.gsodraven.aset.dist.extradur:Value() - (gsoAIO.Utils.minPing*1000)
        if not v.success and timerMinus > numMenu then
            self.qParticles[k].success = true
            gsoAIO.Orb.lMove = 0
        end
        if timerMinus > numMenu and timerMinus < numMenu + 100 then
            gsoAIO.Orb.lMove = 0
        end
        if timerMinus > 2000 then
            self.qParticles[k] = nil
        end
    end
end

function __gsoDraven:_draw()
    if gsoAIO.Menu.menu.gsodraven.aset.catch:Value() then
        local aenabled = gsoAIO.Menu.menu.gsodraw.circle1.aaxeenable:Value()
        local ienabled = gsoAIO.Menu.menu.gsodraw.circle1.iaxeenable:Value()
        if aenabled or ienabled then
            for k,v in pairs(self.qParticles) do
                if not v.success then
                    if v.active and aenabled then
                        local acol = gsoAIO.Menu.menu.gsodraw.circle1.aaxecolor:Value()
                        local arad = gsoAIO.Menu.menu.gsodraw.circle1.aaxeradius:Value()
                        local awid = gsoAIO.Menu.menu.gsodraw.circle1.aaxewidth:Value()
                        Draw.Circle(v.pos, arad, awid, acol)
                    elseif ienabled then
                        local icol = gsoAIO.Menu.menu.gsodraw.circle1.iaxecolor:Value()
                        local irad = gsoAIO.Menu.menu.gsodraw.circle1.iaxeradius:Value()
                        local iwid = gsoAIO.Menu.menu.gsodraw.circle1.iaxewidth:Value()
                        Draw.Circle(v.pos, irad, iwid, icol)
                    end
                end
            end
        end
    end
end