
class "__gsoOrb"

function __gsoOrb:__init()
    
    --[[ move if stop holding orb key ]]
    self.lastKey      = 0
    self.loaded       = false
    
    --[[ orbwalker ]]
    self.canMove      = true
    self.canAA        = true
    self.aaReset      = false
    self.lAttack      = 0
    self.lMove        = 0
    self.lMovePath    = mousePos
    self.setCursor    = nil
    
    --[[ delayed actions ]]
    self.dActionsC    = 0
    self.dActions     = {}
    
    --[[ local aa data ]]
    self.baseAASpeed  = 0
    self.baseWindUp   = 0
    self.windUpT      = 0
    self.animT        = 0
    
    --[[ server aa data ]]
    self.serverStart = 0
    self.serverWindup = 0
    self.serverAnim = 0
    
    --[[ minion ]]
    self.lastMinion = nil
    
    --[[ callbacks ]]
    gsoAIO.Callbacks:_setDraw(function() self:_draw() end)
    gsoAIO.Callbacks:_setWndMsg(function(msg, wParam) self:_onWndMsg(msg, wParam) end)
    gsoAIO.Callbacks:_setTick(function() self:_tick() end)
end

function __gsoOrb:_onWndMsg(msg, wParam)
    if wParam == HK_TCO then
        self.lAttack = Game.Timer()
    end
end

function __gsoOrb:_orb(unit)
    
    local aaSpeed = gsoAIO.Callbacks._aaSpeed() * self.baseAASpeed
    local numAS   = aaSpeed >= 2.5 and 2.5 or aaSpeed
    local animT   = 1 / numAS
    local windUpT = animT * self.baseWindUp
    self.serverAnim = aaSpeed >= 2.5 and animT or self.serverAnim
    self.serverWindup = aaSpeed >= 2.5 and windUpT or self.serverWindup
    local extraWindUp = math.abs(windUpT-self.serverWindup) + (gsoAIO.Menu.menu.orb.delays.windup:Value() * 0.001)
    local windUpAA = windUpT > self.serverWindup and self.serverWindup or windUpT
    self.windUpT = windUpT > self.serverWindup and windUpT or self.serverWindup
    self.animT = animT > self.serverAnim and animT or self.serverAnim
    if gsoAIO.Load.meTristana then
        local hasQBuff = GetTickCount() - gsoAIO.WndMsg.lastQ < 1000 and gsoAIO.Utils:_hasBuff(myHero, "tristanaq")
        self.animT = hasQBuff and animT or self.animT
    end
    if gsoAIO.Load.meSivir then
        local hasWBuff = GetTickCount() - gsoAIO.WndMsg.lastW < 1000 and gsoAIO.Utils:_hasBuff(myHero, "sivirwmarker")
        self.animT = hasWBuff and animT or self.animT
    end
    if gsoAIO.Load.meTwitch then
        local hasQBuff = GetTickCount() - gsoAIO.WndMsg.lastQ < 3000 and gsoAIO.Utils:_hasBuff(myHero, "twitchhideinshadowsbuff")
        self.animT = hasQBuff and animT or self.animT
    end
    if gsoAIO.Load.meAshe then
        local hasQBuff = GetTickCount() - gsoAIO.WndMsg.lastQ < 1000 and gsoAIO.Utils:_hasBuff(myHero, "asheqattack")
        self.animT = hasQBuff and animT or self.animT
    end
    if gsoAIO.Load.meJinx then
        self.animT = animT
    end
    
    local unitValid = unit and not unit.dead and unit.isTargetable and unit.visible and unit.valid
    if unitValid and unit.type == Obj_AI_Hero then
        unitValid = gsoAIO.Utils:_isImmortal(unit, true) == false
    end
    
    self.canAA    = self.dActionsC == 0 and gsoAIO.Callbacks._canAttack(unit) and not gsoAIO.TS.isBlinded
    self.canAA    = self.canAA and (self.aaReset or Game.Timer() > self.serverStart - windUpAA + self.animT - gsoAIO.Utils.minPing - 0.05 )
    self.canMove  = self.dActionsC == 0 and gsoAIO.Callbacks._canMove(unit)
    self.canMove  = self.canMove and Game.Timer() > self.serverStart + extraWindUp - ( gsoAIO.Utils.minPing * 0.5 )
    
    unit = unit and unit or self.lastMinion
    if unit and self.canAA then
        self:_attack(unit)
    elseif self.canMove then
        if self.lastMinion then
            self.lastMinion = nil
        end
        if unitValid and Game.Timer() > self.lAttack + ( gsoAIO.Orb.animT * 0.5 ) and Game.Timer() < self.lAttack + ( self.animT * 0.75 ) and gsoAIO.Items:_botrk(unit) then
            return
        end
        if Game.Timer() > self.lMove + (gsoAIO.Menu.menu.orb.delays.humanizer:Value()*0.001) and GetTickCount() > gsoAIO.Items.lastBotrk + 100 then
            self:_move()
            return
        end
        gsoAIO.Callbacks._onMove(unit)
    else
        gsoAIO.Callbacks._onAttack(unit)
    end
end

function __gsoOrb:_tick()

--  DISABLE IF LOAD :
    if not self.loaded and GetTickCount() < gsoAIO.Load.loadTime + 1250 then
        return
    elseif not self.loaded then
        self.loaded = true
    end

--  SET CURSOR POS :
    if self.setCursor then
        Control.SetCursorPos(self.setCursor)
    end

--  DISABLE IN EVADING TIME :
    if ExtLibEvade and ExtLibEvade.Evading then return end

--  OBJECT TICK :
    gsoAIO.OB:_tick()

--  FARM TICK :
    gsoAIO.Farm:_tick()

--  CHAMPIONS TICK :
    gsoAIO.Callbacks._onTick()

--  HANDLE DELAYED ACTIONS :
    local dActions = self.dActions
    local cDActions = 0
    for k,v in pairs(dActions) do
        cDActions = cDActions + 1
        if not v[3] and GetTickCount() - k > v[2] then
            v[1]()
            v[3] = true
            self.setCursor = nil
        elseif v[3] and GetTickCount() - k > v[2] + 25 then
            self.dActions[k] = nil
        end
    end
    self.dActionsC = cDActions

--  GET SERVER AA DATA :
    local aSpell = myHero.activeSpell
    local aSpellName = aSpell.name:lower()
    if not gsoAIO.Utils.noAttacks[aSpellName] and (aSpellName:find("attack") or gsoAIO.Utils.attacks[aSpellName]) and aSpell.startTime > self.serverStart then
        self.serverStart = aSpell.startTime
        self.serverWindup = aSpell.windup
        self.serverAnim = aSpell.animation
    end

--  EXECUTE MODES :
    local ck  = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local hk  = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local lhk = gsoAIO.Menu.menu.orb.keys.lastHit:Value()
    local lck = gsoAIO.Menu.menu.orb.keys.laneClear:Value()
    if Game.IsChatOpen() == false and (ck or hk or lhk or lck) then
        local AAtarget = nil
        if ck then
            AAtarget = gsoAIO.TS:_comboT()
        elseif hk then
            AAtarget = gsoAIO.TS:_harassT()
        elseif lhk then
            AAtarget = gsoAIO.TS:_lastHitT()
        elseif lck then
            AAtarget = gsoAIO.TS:_laneClearT()
        end
        if ExtLibEvade then
            if not ExtLibEvade.Evading then
                self:_orb(AAtarget)
            end
        else
            self:_orb(AAtarget)
        end
    elseif self.dActionsC == 0 and GetTickCount() < self.lastKey + 1000 then
        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
        self.lastKey = 0
    end
end

function __gsoOrb:_attack(unit)
    if ExtLibEvade and ExtLibEvade.Evading then return end
    if unit.type == Obj_AI_Minion then
        self.lastMinion = unit
    end
    self.aaReset = false
    self.lMove = 0
    local cPos = cursorPos
    local unitPos = unit.pos
    Control.SetCursorPos(unitPos)
    self.setCursor = unitPos
    Control.KeyDown(HK_TCO)
    Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
    Control.mouse_event(MOUSEEVENTF_RIGHTUP)
    Control.KeyUp(HK_TCO)
    self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
    self.dActionsC = self.dActionsC + 1
    if gsoAIO.Load.meTristana and gsoAIO.Champ.tristanaETar and gsoAIO.Champ.tristanaETar.id == unit.networkID then
        gsoAIO.Champ.tristanaETar.stacks = gsoAIO.Champ.tristanaETar.stacks + 1
        if gsoAIO.Champ.tristanaETar.stacks == 5 then
            gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Champ.tristanaETar = nil end, endTime = Game.Timer() + self.windUpT + (gsoAIO.Utils:_getDistance(myHero.pos, unit.pos) / 2000) }
        end
    end
    if not gsoAIO.Champ.canQ then gsoAIO.Champ.canQ = true end
    if not gsoAIO.Champ.canW then gsoAIO.Champ.canW = true end
    if not gsoAIO.Champ.canE then gsoAIO.Champ.canE = true end
    if not gsoAIO.Champ.canR then gsoAIO.Champ.canR = true end
    self.lAttack = Game.Timer()
end

function __gsoOrb:_move()
    local mPos = gsoAIO.Callbacks._mousePos()
    if mPos ~= nil then
        if ExtLibEvade and ExtLibEvade.Evading then return end
        if Control.IsKeyDown(2) then self.lastKey = GetTickCount() end
        local cPos = cursorPos
        Control.SetCursorPos(mPos)
        self.setCursor = mPos
        self.lMovePath = mPos
        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
        Control.mouse_event(MOUSEEVENTF_RIGHTUP)
        self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
        self.dActionsC = self.dActionsC + 1
        self.lMove = Game.Timer()
    else
        if ExtLibEvade and ExtLibEvade.Evading then return end
        if Control.IsKeyDown(2) then self.lastKey = GetTickCount() end
        self.lMovePath = mousePos
        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
        Control.mouse_event(MOUSEEVENTF_RIGHTUP)
        self.lMove = Game.Timer()
    end
end

function __gsoOrb:_draw()
    local mePos = myHero.pos
    local meBB = myHero.boundingRadius
    if gsoAIO.Menu.menu.gsodraw.circle1.merange:Value() and mePos:ToScreen().onScreen then
        Draw.Circle(mePos, myHero.range + meBB + 50, gsoAIO.Menu.menu.gsodraw.circle1.mewidth:Value(), gsoAIO.Menu.menu.gsodraw.circle1.mecolor:Value())
    end
    if gsoAIO.Menu.menu.gsodraw.circle1.herange:Value() then
        local countEH = #gsoAIO.OB.enemyHeroes
        for i = 1, countEH do
            local hero = gsoAIO.OB.enemyHeroes[i]
            local heroPos = hero.pos
            if gsoAIO.Utils:_getDistance(mePos, heroPos) < 2000 and heroPos:ToScreen().onScreen then
                Draw.Circle(heroPos, hero.range + hero.boundingRadius + meBB, gsoAIO.Menu.menu.gsodraw.circle1.hewidth:Value(), gsoAIO.Menu.menu.gsodraw.circle1.hecolor:Value())
            end
        end
    end
    if gsoAIO.Menu.menu.gsodraw.circle1.cpos:Value() then
        Draw.Circle(mousePos, gsoAIO.Menu.menu.gsodraw.circle1.cposradius:Value(), gsoAIO.Menu.menu.gsodraw.circle1.cposwidth:Value(), gsoAIO.Menu.menu.gsodraw.circle1.cposcolor:Value())
    end
end