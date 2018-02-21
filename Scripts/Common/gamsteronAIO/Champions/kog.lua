
class "__gsoKogMaw"

function __gsoKogMaw:__init()
    gsoAIO.TS.apDmg = true
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.hasWBuff = false
    self.loadedChamps = false
    gsoAIO.Orb.baseAASpeed = 0.665
    gsoAIO.Orb.baseWindUp = 0.1662234
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
end

function __gsoKogMaw:_onMove(target)
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
    
    if not isTarget or afterAttack then
        
        local wMana = 40 - ( myHero:GetSpellData(_W).currentCd * myHero.mpRegen )
        local meMana = myHero.mana - wMana
        
        -- USE Q :
        local canQTime = qMinus > 1000 and qMinuss > 1000 and eMinus > 650 and eMinuss > 650 and rMinus > 650 and rMinuss > 650
        local isComboQ = isCombo and gsoAIO.Menu.menu.gsokog.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Menu.menu.gsokog.qset.harass:Value()
        local stopQIfW = gsoAIO.Menu.menu.gsokog.wset.stopq:Value() and self.hasWBuff
        local isQReady = (isComboQ or isHarassQ) and canQTime and gsoAIO.Utils:_isReady(_Q) and not stopQIfW
        if isQReady and meMana > myHero:GetSpellData(_Q).mana and ( (not isTarget and wMinus > 500 and wMinuss > 500) or (isTarget and self.canQ) ) then
            local qTarget = isTarget and target or gsoAIO.TS:_getTarget(1175, false, false, gsoAIO.OB.enemyHeroes)
            local qTargetPos = qTarget and qTarget.pos or nil
            if qTargetPos then
                local mePos = myHero.pos
                local sQ = { delay = 0.25, range = 1175, width = 70, speed = 1650, sType = "line", col = true }
                local castpos,HitChance,pos = gsoAIO.TPred:GetBestCastPosition(qTarget, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
                local canQonTarget = HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sQ.range
                      canQonTarget = canQonTarget and gsoAIO.Utils:_getDistance(qTargetPos, castpos) < 500
                if canQonTarget then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_Q)
                    Control.KeyUp(HK_Q)
                    self.lastQ = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.canE = false
                    self.canR = false
                    return
                end
            end
        end
        
        -- USE E :
        local canETime = qMinus > 650 and qMinuss > 650 and eMinus > 1000 and eMinuss > 1000 and rMinus > 650 and rMinuss > 650
        local isComboE = isCombo and gsoAIO.Menu.menu.gsokog.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Menu.menu.gsokog.eset.harass:Value()
        local stopEIfW = gsoAIO.Menu.menu.gsokog.wset.stope:Value() and self.hasWBuff
        local isEReady = (isComboE or isHarassE) and canETime and gsoAIO.Utils:_isReady(_E) and not stopEIfW
        if isEReady and meMana > myHero:GetSpellData(_E).mana and ( myHero.mana * 100 ) / myHero.maxMana > gsoAIO.Menu.menu.gsokog.eset.emana:Value() and ( (not isTarget and wMinus > 500 and wMinuss > 500) or (isTarget and self.canE) ) then
            local eTarget = isTarget and target or gsoAIO.TS:_getTarget(1280, false, false, gsoAIO.OB.enemyHeroes)
            if eTarget then
                local mePos = myHero.pos
                local sE = { delay = 0.25, range = 1280, width = 120, speed = 1350, sType = "line", col = false }
                local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(eTarget, sE.delay, sE.width*0.5, sE.range, sE.speed, mePos, sE.col, sE.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sE.range and gsoAIO.Utils:_getDistance(eTarget.pos, castpos) < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    self.lastE = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.canQ = false
                    self.canR = false
                    return
                end
            end
        end
        
        -- USE R :
        local canRTime = qMinus > 650 and qMinuss > 650 and eMinus > 650 and eMinuss > 650 and rMinus > 1000 and rMinuss > 1000
        local isComboR = isCombo and gsoAIO.Menu.menu.gsokog.rset.combo:Value()
        local isHarassR = isHarass and gsoAIO.Menu.menu.gsokog.rset.harass:Value()
        local rStacks = gsoAIO.Utils:_buffCount(myHero, "kogmawlivingartillerycost") < gsoAIO.Menu.menu.gsokog.rset.stack:Value()
        local stopRIfW = gsoAIO.Menu.menu.gsokog.wset.stopr:Value() and self.hasWBuff
        local isRReady = (isComboR or isHarassR) and canRTime and gsoAIO.Utils:_isReady(_R) and rStacks and not stopRIfW
        if isRReady and meMana > myHero:GetSpellData(_R).mana and ( myHero.mana * 100 ) / myHero.maxMana > gsoAIO.Menu.menu.gsokog.rset.rmana:Value() and ( (not isTarget and wMinus > 500 and wMinuss > 500) or (isTarget and self.canR) ) then
            
            -- spell data
            local sR = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false }
            sR.range = 900 + ( 300 * myHero:GetSpellData(_R).level )
            
            -- only enemies with hp lower than 40%
            local onlyLowR = gsoAIO.Menu.menu.gsokog.rset.onlylow:Value()
            
            -- check for target in attack range
            local rTarget = nil
            if not onlyLowR and isTarget then rTarget = target end
            if onlyLowR and isTarget and ( target.health * 100 ) / target.maxHealth < 39 then rTarget = target end
            
            -- check for targets in R range
            local rTargets = {}
            if not rTarget then
                if onlyLowR then
                    for i = 1, #gsoAIO.OB.enemyHeroes do
                        local hero = gsoAIO.OB.enemyHeroes[i]
                        if hero and ( hero.health * 100 ) / hero.maxHealth < 39 then
                            rTargets[#rTargets+1] = hero
                        end
                    end
                else
                    rTargets = gsoAIO.OB.enemyHeroes
                end
            end
            
            -- target
            local rT = rTarget and rTarget or gsoAIO.TS:_getTarget(sR.range + (sR.width*0.5), false, false, rTargets)
            
            -- use spell
            if rT then
                local mePos = myHero.pos
                local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(rT, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sR.range and gsoAIO.Utils:_getDistance(rT.pos, castpos) < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_R)
                    Control.KeyUp(HK_R)
                    self.lastR = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.canQ = false
                    self.canE = false
                    return
                end
            end
        end
    end
end

function __gsoKogMaw:_canMove(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.WndMsg.lastQ
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.WndMsg.lastR
    if qMinus > 250 and qMinuss > 250 and eMinus > 250 and eMinuss > 250 and rMinus > 250 and rMinuss > 250 then
        return true
    end
    return false
end

function __gsoKogMaw:_canAttack(target)
    
    local isTarget = target and target.type == Obj_AI_Hero
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
    
    -- USE W :
    local canWTime = qMinus > 550 and qMinuss > 550 and wMinus > 1000 and wMinuss > 1000 and eMinus > 550 and eMinuss > 550 and rMinus > 550 and rMinuss > 550
    local isComboW = isCombo and gsoAIO.Menu.menu.gsokog.wset.combo:Value()
    local isHarassW = isHarass and gsoAIO.Menu.menu.gsokog.wset.harass:Value()
    local isWReady = (isComboW or isHarassW) and canWTime and Game.CanUseSpell(_W) == 0
    if isWReady and Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 ) then
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local hero = gsoAIO.OB.enemyHeroes[i]
            local wRange = 610 + ( 20 * myHero:GetSpellData(_W).level ) + myHero.boundingRadius + hero.boundingRadius
            if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(myHero.pos, hero.pos) < wRange then
                self.lastW = GetTickCount()
                print("ok")
                Control.KeyDown(HK_W)
                Control.KeyUp(HK_W)
                self.canQ = false
                self.canE = false
                self.canR = false
                return
            end
        end
    end
    
    if qMinus > 450 and qMinuss > 450 and eMinus > 450 and eMinuss > 450 and rMinus > 450 and rMinuss > 450 then
        return true
    end
    return false
end

function __gsoKogMaw:_tick()
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsokog.rset.semirmenu.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    local hasWBuff = false
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        local buffName = buff and buff.name or nil
        if buffName and buff.count > 0 and buff.duration > 0 then
            if buffName == "KogMawBioArcaneBarrage" then
                hasWBuff = true
                break
            end
        end
    end
    self.hasWBuff = hasWBuff
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
    
    local canRTime = qMinus > 350 and qMinuss > 350 and eMinus > 350 and eMinuss > 350 and rMinus > 1000 and rMinuss > 1000
    local isRReady = canRTime and gsoAIO.Utils:_isReady(_R)
    if isRReady and Game.Timer() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT + gsoAIO.Utils.maxPing then
        
        -- spell data
        local sR = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false }
        sR.range = 900 + ( 300 * myHero:GetSpellData(_R).level )
        
        local rStacks = gsoAIO.Utils:_buffCount(myHero, "kogmawlivingartillerycost") < gsoAIO.Menu.menu.gsokog.rset.stack:Value()
        local checkRStacksKS = gsoAIO.Menu.menu.gsokog.rset.ksmenu.csksr:Value()
        if gsoAIO.Menu.menu.gsokog.rset.ksmenu.ksr:Value() and ( not checkRStacksKS or ( checkRStacksKS and rStacks ) ) then
        
            -- check for killable targets in R range
            local rTargets = {}
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local baseRDmg = 60 + ( 40 * myHero:GetSpellData(_R).level ) + ( myHero.bonusDamage * 0.65 ) + ( myHero.ap * 0.25 )
                local rMultipier = math.floor(100 - ( ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth ))
                local rDmg = rMultipier > 60 and baseRDmg * 2 or baseRDmg * ( 1 + ( rMultipier * 0.00833 ) )
                      rDmg = gsoAIO.Dmg.PredHP(hero, { dmgAP = rDmg, dmgType = "ap" } )
                local unitKillable = rDmg > hero.health + (hero.hpRegen * 2)
                if unitKillable then
                    rTargets[#rTargets+1] = hero
                end
            end
            
            -- target
            local rT = #rTargets == 0 and nil or gsoAIO.TS:_getTarget(sR.range + (sR.width*0.5), false, false, rTargets)
            
            -- use spell
            if rT then
                local mePos = myHero.pos
                local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(rT, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sR.range and gsoAIO.Utils:_getDistance(rT.pos, castpos) < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_R)
                    Control.KeyUp(HK_R)
                    self.lastR = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.canQ = false
                    self.canE = false
                    return
                end
            end
        end
        
        local checkRStacksSemi = gsoAIO.Menu.menu.gsokog.rset.semirmenu.semistacks:Value()
        if gsoAIO.Menu.menu.gsokog.rset.semirmenu.semir:Value() and ( not checkRStacksSemi or ( checkRStacksSemi and rStacks ) ) then
            -- spell data
            local sR = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false }
            sR.range = 900 + ( 300 * myHero:GetSpellData(_R).level )
            
            -- only enemies with hp lower than 40%
            local onlyLowR = gsoAIO.Menu.menu.gsokog.rset.semirmenu.semilow:Value()

            -- check for targets in R range
            local rTargets = {}
            if onlyLowR then
                for i = 1, #gsoAIO.OB.enemyHeroes do
                    local hero = gsoAIO.OB.enemyHeroes[i]
                    if hero and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth < 40 then
                        rTargets[#rTargets+1] = hero
                    end
                end
            else
                rTargets = gsoAIO.OB.enemyHeroes
            end
            
            -- target
            local rT = gsoAIO.TS:_getTarget(sR.range + (sR.width*0.5), false, false, rTargets)
            
            -- use spell
            if rT then
                local mePos = myHero.pos
                local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(rT, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sR.range and gsoAIO.Utils:_getDistance(rT.pos, castpos) < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    gsoAIO.Orb.setCursor = castpos
                    Control.KeyDown(HK_R)
                    Control.KeyUp(HK_R)
                    self.lastR = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.canQ = false
                    self.canE = false
                    return
                end
            end
        end
    end
end