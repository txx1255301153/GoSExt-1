
class "__gsoTwitch"

function __gsoTwitch:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.hasQBuff = false
    self.qBuffTime = 0
    self.lastW  = 0
    self.lastE  = 0
    self.eBuffs = {}
    self.asNoQ = myHero.attackSpeed
    self.boolRecall = true
    self.QASBuff = false
    self.QASTime = 0
    self.lastASCheck = 0
    gsoAIO.Orb.baseAASpeed = 0.679
    gsoAIO.Orb.baseWindUp = 0.2019159
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setAASpeed(function() return self:_aaSpeed() end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setDraw(function() self:_draw() end)
    gsoAIO.Callbacks:_setBonusDmg(function() return 3 end)
end

function __gsoTwitch:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    
    local stopifQBuff = false
    local num1 = 1350 - ( getTick - gsoAIO.WndMsg.lastQ )
    if num1 > -50 and num1 < 550 then
        stopifQBuff = true
    end
    
    if not isTarget or afterAttack then
        
        -- USE W :
        local canWTime = wMinus > 1000 and wMinuss > 1000 and eMinus > 700 and eMinuss > 700
        local isComboW = isCombo and gsoAIO.Menu.menu.gsotwitch.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Menu.menu.gsotwitch.wset.harass:Value()
        local stopWIfR = gsoAIO.Menu.menu.gsotwitch.wset.stopwult:Value() and GetTickCount() < gsoAIO.WndMsg.lastR + 5450
        local stopWIfQ = gsoAIO.Menu.menu.gsotwitch.wset.stopq:Value() and self.hasQBuff
        local isWReady = (isComboW or isHarassW) and canWTime == true and gsoAIO.Utils:_isReady(_W) and not stopWIfR and not stopWIfQ and not stopifQBuff
        if isWReady and ( not isTarget or (isTarget and self.canW) ) then
            local wTarget = isTarget and target or gsoAIO.TS:_getTarget(950, false, false, gsoAIO.OB.enemyHeroes)
            if wTarget ~= nil then
                local mePos = myHero.pos
                local sW = { delay = 0.25, range = 950, width = 275, speed = 1400, sType = "circular", col = false }
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
                    self.canE = false
                    gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
                    return
                end
            end
        end
        
        -- USE E :
        local canETime = wMinus > 350 and wMinuss > 350 and eMinus > 1000 and eMinuss > 1000
        local isComboE = isCombo and gsoAIO.Menu.menu.gsotwitch.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Menu.menu.gsotwitch.eset.harass:Value()
        local isEReady = (isComboE or isHarassE) and canETime and gsoAIO.Utils:_isReady(_E) and not stopifQBuff
        if isEReady and ( not isTarget or (isTarget and self.canE) ) then
            local xStacks   = gsoAIO.Menu.menu.gsotwitch.eset.stacks:Value()
            local xEnemies  = gsoAIO.Menu.menu.gsotwitch.eset.enemies:Value()
            local countE    = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_getDistance(myHero.pos, hero.pos) < 1200 and gsoAIO.Utils:_valid(hero, false) then
                    local nID = hero.networkID
                    if self.eBuffs[nID] and self.eBuffs[nID].count >= xStacks then
                        countE = countE + 1
                    end
                end
            end
            if countE >= xEnemies then
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                self.lastE = GetTickCount()
                self.canW = false
                gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
                return
            end
        end
    end
end

function __gsoTwitch:_aaSpeed()
    local num1 = GetTickCount()-self.QASTime-(gsoAIO.Utils.maxPing*1000)
    if num1 > -150 and num1 < 1500 then
        return self.asNoQ
    end
    return myHero.attackSpeed
end

function __gsoTwitch:_canMove(target)
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

function __gsoTwitch:_canAttack(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local num1 = 1350-(getTick-gsoAIO.WndMsg.lastQ)
    if num1 > -50 and num1 < (gsoAIO.Orb.windUpT*1000) + 250 then
        return false
    end
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    if wMinus > 450 and wMinuss > 450 and eMinus > 400 and eMinuss > 400 then
        return true
    end
    return false
end

function __gsoTwitch:_tick()
    if GetTickCount() - gsoAIO.WndMsg.lastQ < 500 and GetTickCount() > self.lastASCheck + 1000 then
        self.asNoQ = myHero.attackSpeed
        self.lastASCheck = GetTickCount()
    end
    local boolRecall = gsoAIO.Menu.menu.gsotwitch.qset.recallkey:Value()
    if boolRecall == self.boolRecall then
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        Control.KeyDown(string.byte("B"))
        Control.KeyUp(string.byte("B"))
        self.boolRecall = not boolRecall
    end
    local hasQBuff = false
    local QASBuff = false
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        local buffName = buff and buff.name or nil
        if buffName and buff.count > 0 and buff.duration > 0 then
            if buffName == "globalcamouflage" or buffName == "TwitchHideInShadows" then
                hasQBuff = true
                self.qBuffTime = GetTickCount() + (buff.duration*1000)
                break
            end
            if buffName == "twitchhideinshadowsbuff" then
                QASBuff = true
                self.QASTime = GetTickCount() + (buff.duration*1000)
            end
        end
    end
    self.hasQBuff = hasQBuff
    self.QASBuff = QASBuff
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero  = gsoAIO.OB.enemyHeroes[i]
        local nID   = hero.networkID
        if not self.eBuffs[nID] then
            self.eBuffs[nID] = { count = 0, durT = 0 }
        end
        if not hero.dead then
            local hasB = false
            local cB = self.eBuffs[nID].count
            local dB = self.eBuffs[nID].durT
            for i = 0, hero.buffCount do
                local buff = hero:GetBuff(i)
                if buff and buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
                    hasB = true
                    if cB < 6 and buff.duration > dB then
                        self.eBuffs[nID].count = cB + 1
                        self.eBuffs[nID].durT = buff.duration
                    else
                        self.eBuffs[nID].durT = buff.duration
                    end
                    break
                end
            end
            if not hasB then
                self.eBuffs[nID].count = 0
                self.eBuffs[nID].durT = 0
            end
        end
    end
    
    -- E KS :
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.WndMsg.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.WndMsg.lastE
    local canETime = wMinus > 350 and wMinuss > 350 and eMinus > 1000 and eMinuss > 1000
    local isEReady = canETime and gsoAIO.Utils:_isReady(_E)
    if isEReady then
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local hero  = gsoAIO.OB.enemyHeroes[i]
            local nID   = hero.networkID
            if self.eBuffs[nID] and self.eBuffs[nID].count > 0 and gsoAIO.Utils:_getDistance(myHero.pos, hero.pos) < 1200 then
                local elvl = myHero:GetSpellData(_E).level
                local basedmg = 5 + ( elvl * 15 )
                local cstacks = self.eBuffs[nID].count
                local perstack = ( 10 + (5*elvl) ) * cstacks
                local bonusAD = myHero.bonusDamage * 0.25 * cstacks
                local bonusAP = myHero.ap * 0.2 * cstacks
                local edmg = basedmg + perstack + bonusAD + bonusAP
                local tarm = hero.armor - myHero.armorPen
                      tarm = tarm > 0 and myHero.armorPenPercent * tarm or tarm
                local DmgDealt = tarm > 0 and edmg * ( 100 / ( 100 + tarm ) ) or edmg * ( 2 - ( 100 / ( 100 - tarm ) ) )
                local HPRegen = hero.hpRegen * 1.5
                if hero.health + hero.shieldAD + HPRegen < DmgDealt and gsoAIO.Utils:_valid(hero, false) then
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    self.lastE = GetTickCount()
                    self.canW = false
                    gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
                end
            end
        end
    end
end

function __gsoTwitch:_draw()
    local mePos = myHero.pos
    if GetTickCount() < gsoAIO.WndMsg.lastQ + 16000 then
        local mePos2D = mePos:To2D()
        local posX = mePos2D.x - 50
        local posY = mePos2D.y
        local num1 = math.floor(1350+gsoAIO.WndMsg.qLatency-(GetTickCount()-gsoAIO.WndMsg.lastQ))
        local timerEnabled = gsoAIO.Menu.menu.gsodraw.texts1.enabletime:Value()
        local timerColor = gsoAIO.Menu.menu.gsodraw.texts1.colortime:Value()
        if num1 > 1 then
            if timerEnabled then
                local str1 = tostring(num1)
                local str2 = ""
                for i = 1, #str1 do
                    if #str1 <=2 then
                        str2 = 0
                        break
                    end
                    local char1 = i <= #str1-2 and str1:sub(i,i) or "0"
                    str2 = str2..char1
                end
                Draw.Text(str2, 50, posX+50, posY-15, timerColor)
            end
        elseif self.hasQBuff then
            local num2 = math.floor(self.qBuffTime-GetTickCount() + gsoAIO.WndMsg.qLatency)
            if num2 > 1 then
                if gsoAIO.Menu.menu.gsodraw.circle1.invenable:Value() then
                    Draw.Circle(mePos, 500, 1, gsoAIO.Menu.menu.gsodraw.circle1.invcolor:Value())
                end
                if gsoAIO.Menu.menu.gsodraw.circle1.notenable:Value() then
                    Draw.Circle(mePos, 800, 1, gsoAIO.Menu.menu.gsodraw.circle1.notcolor:Value())
                end
                if timerEnabled then
                    local str1 = tostring(num2)
                    local str2 = ""
                    for i = 1, #str1 do
                        if #str1 <=2 then
                            str2 = 0
                            break
                        end
                        local char1 = i <= #str1-2 and str1:sub(i,i) or "0"
                        str2 = str2..char1
                    end
                    Draw.Text(str2, 50, posX+50, posY-15, timerColor)
                end
            end
        end
    end
end