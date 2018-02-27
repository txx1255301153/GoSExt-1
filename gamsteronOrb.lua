




local gsoVersion = "1.4"
      gsoSDK = nil





local gsoMyHero = myHero
local gsoGameHero = Game.Hero
local gsoMathSqrt = math.sqrt
local gsoGameTimer = Game.Timer
local gsoDrawColor = Draw.Color
local gsoDrawCircle = Draw.Circle
local gsoGameMinion = Game.Minion
local gsoGameTurret = Game.Turret
local gsoGameLatency = Game.Latency
local gsoGetTickCount = GetTickCount
local gsoControlKeyUp = Control.KeyUp
local gsoGameHeroCount = Game.HeroCount
local gsoGameIsChatOpen = Game.IsChatOpen
local gsoControlKeyDown = Control.KeyDown
local gsoGameMinionCount = Game.MinionCount
local gsoGameTurretCount = Game.TurretCount
local gsoControlIsKeyDown = Control.IsKeyDown
local gsoControlSetCursor = Control.SetCursorPos
local gsoControlMouseEvent = Control.mouse_event






local gsoLoaded = false
local gsoLatencies = {}
local gsoDelayedActions = {}
local gsoSetCursorPos = nil
local gsoLastKey = 0
local gsoBaseAASpeed = 0
local gsoBaseWindUp = 0
local gsoServerStart = 0
local gsoServerWindup = 0
local gsoServerAnim = 0
local gsoLastFound = -10000000
local gsoLastSelTick = 0
local gsoIsTeemo = false
local gsoLoadedChamps = false





local gsoMenu = MenuElement({name = "Gamsteron Orbwalker", id = "gamsteronorb", type = MENU })
local gsoMode = { isCombo = false, isHarass = false, isLastHit = false, isLaneClear = false }
local gsoTimers = { lastAttackSend = 0, lastMoveSend = 0, millisecondsToAttack = 0, millisecondsToMove = 0, windUpTime = 0, animationTime = 0, endTime = 0, startTime = 0 }
local gsoState = { isAttacking = false, isMoving = false, isEvading = false, isChangingCursorPos = false, isBlindedByTeemo = false, canAttack = true, canMove = true, enabledAttack = true, enabledMove = true, enabledOrb = true }
local gsoExtra = { lastMovePos = myHero.pos, maxLatency = Game.Latency() * 0.001, minLatency = Game.Latency() * 0.001, lastTarget = nil, selectedTarget = nil, allyTeam = myHero.team }





local gsoPriorities = {
    ["Aatrox"] = 3, ["Ahri"] = 2, ["Akali"] = 2, ["Alistar"] = 5, ["Amumu"] = 5, ["Anivia"] = 2, ["Annie"] = 2, ["Ashe"] = 1, ["AurelionSol"] = 2, ["Azir"] = 2,
    ["Bard"] = 3, ["Blitzcrank"] = 5, ["Brand"] = 2, ["Braum"] = 5, ["Caitlyn"] = 1, ["Camille"] = 3, ["Cassiopeia"] = 2, ["Chogath"] = 5, ["Corki"] = 1,
    ["Darius"] = 4, ["Diana"] = 2, ["DrMundo"] = 5, ["Draven"] = 1, ["Ekko"] = 2, ["Elise"] = 3, ["Evelynn"] = 2, ["Ezreal"] = 1, ["Fiddlesticks"] = 3, ["Fiora"] = 3,
    ["Fizz"] = 2, ["Galio"] = 5, ["Gangplank"] = 2, ["Garen"] = 5, ["Gnar"] = 5, ["Gragas"] = 4, ["Graves"] = 2, ["Hecarim"] = 4, ["Heimerdinger"] = 3, ["Illaoi"] =  3,
    ["Irelia"] = 3, ["Ivern"] = 5, ["Janna"] = 4, ["JarvanIV"] = 3, ["Jax"] = 3, ["Jayce"] = 2, ["Jhin"] = 1, ["Jinx"] = 1, ["Kalista"] = 1, ["Karma"] = 2, ["Karthus"] = 2,
    ["Kassadin"] = 2, ["Katarina"] = 2, ["Kayle"] = 2, ["Kayn"] = 2, ["Kennen"] = 2, ["Khazix"] = 2, ["Kindred"] = 2, ["Kled"] = 4, ["KogMaw"] = 1, ["Leblanc"] = 2,
    ["LeeSin"] = 3, ["Leona"] = 5, ["Lissandra"] = 2, ["Lucian"] = 1, ["Lulu"] = 3, ["Lux"] = 2, ["Malphite"] = 5, ["Malzahar"] = 3, ["Maokai"] = 4, ["MasterYi"] = 1,
    ["MissFortune"] = 1, ["MonkeyKing"] = 3, ["Mordekaiser"] = 2, ["Morgana"] = 3, ["Nami"] = 3, ["Nasus"] = 4, ["Nautilus"] = 5, ["Nidalee"] = 2, ["Nocturne"] = 2,
    ["Nunu"] = 4, ["Olaf"] = 4, ["Orianna"] = 2, ["Ornn"] = 4, ["Pantheon"] = 3, ["Poppy"] = 4, ["Quinn"] = 1, ["Rakan"] = 3, ["Rammus"] = 5, ["RekSai"] = 4,
    ["Renekton"] = 4, ["Rengar"] = 2, ["Riven"] = 2, ["Rumble"] = 2, ["Ryze"] = 2, ["Sejuani"] = 4, ["Shaco"] = 2, ["Shen"] = 5, ["Shyvana"] = 4, ["Singed"] = 5,
    ["Sion"] = 5, ["Sivir"] = 1, ["Skarner"] = 4, ["Sona"] = 3, ["Soraka"] = 3, ["Swain"] = 3, ["Syndra"] = 2, ["TahmKench"] = 5, ["Taliyah"] = 2, ["Talon"] = 2,
    ["Taric"] = 5, ["Teemo"] = 2, ["Thresh"] = 5, ["Tristana"] = 1, ["Trundle"] = 4, ["Tryndamere"] = 2, ["TwistedFate"] = 2, ["Twitch"] = 1, ["Udyr"] = 4, ["Urgot"] = 4,
    ["Varus"] = 1, ["Vayne"] = 1, ["Veigar"] = 2, ["Velkoz"] = 2, ["Vi"] = 4, ["Viktor"] = 2, ["Vladimir"] = 3, ["Volibear"] = 4, ["Warwick"] = 4, ["Xayah"] = 1,
    ["Xerath"] = 2, ["XinZhao"] = 3, ["Yasuo"] = 2, ["Yorick"] = 4, ["Zac"] = 5, ["Zed"] = 2, ["Ziggs"] = 2, ["Zilean"] = 3, ["Zoe"] = 2, ["Zyra"] = 2
}
local gsoNoAttacks = {
    ["volleyattack"] = true,
    ["volleyattackwithsound"] = true,
    ["sivirwattackbounce"] = true,
    ["asheqattacknoonhit"] = true
}
local gsoAttacks = {
    ["caitlynheadshotmissile"] = true,
    ["quinnwenhanced"] = true,
    ["viktorqbuff"] = true
}
local gsoUndyingBuffs = {
    ["zhonyasringshield"] = true
}
local gsoPriorityMultiplier = {
    [1] = 1,
    [2] = 1.15,
    [3] = 1.3,
    [4] = 1.45,
    [5] = 1.6,
    [6] = 1.75
}





local gsoOnAttack = {}
local gsoOnMove = {}
local gsoCanAttack = {}
local gsoCanMove = {}
local function gsoAttackSpeed() return gsoMyHero.attackSpeed end
local function gsoBonusDmg() return 0 end
local function gsoBonusDmgUnit(unit) return 0 end





local function gsoDistance(a, b)
    local x = a.x - b.x
    local z = a.z - b.z
    return gsoMathSqrt(x * x + z * z)
end

local function gsoIsImmortal(unit, jaxE)
    local hp = 100 * ( unit.health / unit.maxHealth )
    if gsoUndyingBuffs["JaxCounterStrike"] ~= nil then    gsoUndyingBuffs["JaxCounterStrike"] = jaxE end
    if gsoUndyingBuffs["kindredrnodeathbuff"] ~= nil then gsoUndyingBuffs["kindredrnodeathbuff"] = hp < 10 end
    if gsoUndyingBuffs["UndyingRage"] ~= nil then         gsoUndyingBuffs["UndyingRage"] = hp < 15 end
    if gsoUndyingBuffs["ChronoShift"] ~= nil then         gsoUndyingBuffs["ChronoShift"] = hp < 15; gsoUndyingBuffs["chronorevive"] = hp < 15 end
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and gsoUndyingBuffs[buff.name] then
            return true
        end
    end
    return false
end

local function gsoValid(unit)
    if unit and not unit.dead and unit.isTargetable and unit.visible and unit.valid then
        return true
    end
    return false
end





local function gsoGetEnemyMinions(range, sourcePos, bb)
    local result = {}
    for i = 1, gsoGameMinionCount() do
        local minion = gsoGameMinion(i)
        if minion and minion.team ~= gsoExtra.allyTeam and gsoDistance(minion.pos, sourcePos) < range + ( bb and minion.boundingRadius or 0 ) and gsoValid(minion) and not minion.isImmortal then
            result[#result+1] = minion
        end
    end
    return result
end

local function gsoGetAllyMinions(range, sourcePos, bb)
    local result = {}
    for i = 1, gsoGameMinionCount() do
        local minion = gsoGameMinion(i)
        if minion and minion.team == gsoExtra.allyTeam and gsoDistance(minion.pos, sourcePos) < range + ( bb and minion.boundingRadius or 0 ) and gsoValid(minion) then
            result[#result+1] = minion
        end
    end
    return result
end

local function gsoGetEnemyTurrets(range, sourcePos, bb)
    local result = {}
    for i = 1, gsoGameTurretCount() do
        local turret = gsoGameTurret(i)
        if turret and turret.team ~= gsoExtra.allyTeam and gsoDistance(turret.pos, sourcePos) < range + ( bb and turret.boundingRadius or 0 ) and gsoValid(turret) and not turret.isImmortal then
            result[#result+1] = turret
        end
    end
    return result
end

local function gsoGetAllyTurret(range, sourcePos, bb)
    local result = {}
    for i = 1, gsoGameTurretCount() do
        local turret = gsoGameTurret(i)
        if turret and turret.team == gsoExtra.allyTeam and gsoDistance(turret.pos, sourcePos) < range + ( bb and turret.boundingRadius or 0 ) and gsoValid(turret) then
            result[#result+1] = turret
        end
    end
    return result
end

local function gsoGetEnemyHeroes(range, sourcePos, bb, jaxE)
    local result = {}
    for i = 1, gsoGameHeroCount() do
        local hero = gsoGameHero(i)
        if hero and hero.team ~= gsoExtra.allyTeam and gsoDistance(hero.pos, sourcePos) < range + ( bb and hero.boundingRadius or 0 ) and gsoValid(hero) and not gsoIsImmortal(hero, jaxE) then
            result[#result+1] = hero
        end
    end
    return result
end

local function gsoGetAllyHeroes(range, sourcePos, bb)
    local result = {}
    for i = 1, gsoGameHeroCount() do
        local hero = gsoGameHero(i)
        if hero and hero.team == gsoExtra.allyTeam and gsoDistance(hero.pos, sourcePos) < range + ( bb and hero.boundingRadius or 0 ) and gsoValid(hero) then
            result[#result+1] = hero
        end
    end
    return result
end





local function gsoReducedDmg(unit, dmg, isAP)
    local def = isAP and unit.magicResist - gsoMyHero.magicPen or unit.armor - gsoMyHero.armorPen
    if def > 0 then def = isAP and gsoMyHero.magicPenPercent * def or gsoMyHero.bonusArmorPenPercent * def end
    return def > 0 and dmg * ( 100 / ( 100 + def ) ) or dmg * ( 2 - ( 100 / ( 100 - def ) ) )
end

local function gsoCalculateDmg(unit, spellData)
    local dmgType = spellData.dmgType and spellData.dmgType or ""
    if not unit then assert(false, "[234] CalculateDmg: unit is nil !") end
    if dmgType == "ad" and spellData.dmgAD then
        local dmgAD = spellData.dmgAD - unit.shieldAD
        return dmgAD < 0 and 0 or gsoReducedDmg(unit, dmgAD, false) 
    elseif dmgType == "ap" and spellData.dmgAP then
        local dmgAP = spellData.dmgAP - unit.shieldAD - unit.shieldAP
        return dmgAP < 0 and 0 or gsoReducedDmg(unit, dmgAP, true) 
    elseif dmgType == "true" and spellData.dmgTrue then
        return spellData.dmgTrue - unit.shieldAD
    elseif dmgType == "mixed" and spellData.dmgAD and spellData.dmgAP then
        local dmgAD = spellData.dmgAD - unit.shieldAD
        local shieldAD = dmgAD < 0 and (-1) * dmgAD or 0
              dmgAD = dmgAD < 0 and 0 or gsoReducedDmg(unit, dmgAD, false)
        local dmgAP = spellData.dmgAP - shieldAD - unit.shieldAP
              dmgAP = dmgAP < 0 and 0 or gsoReducedDmg(unit, dmgAP, true)
        return dmgAD + dmgAP
    end
    assert(false, "[234] CalculateDmg: spellData - expected array { dmgType = string(ap or ad or mixed or true), dmgAP = number or dmgAD = number or ( dmgAP = number and dmgAD = number ) or dmgTrue = number } !")
end





local function gsoGetTarget(range, sourcePos, dmgType, bb, jaxE)
    local selected = gsoExtra.selectedTarget
    local menuSelected = gsoMenu.ts.selected.enable:Value()
    local menuSelectedOnly = gsoMenu.ts.selected.only:Value()
    local selectedID = ( menuSelected and selected ) and selected.networkID or nil
    if menuSelected and menuSelectedOnly and gsoValid(selected) then
        if gsoDistance(selected.pos, sourcePos) < range + ( bb and selected.boundingRadius or 0 ) and not gsoIsImmortal(selected, jaxE) then
            return selected
        else
            return nil
        end
    end
    local result  = nil
    local num     = 10000000
    local mode    = gsoMenu.ts.Mode:Value()
    local enemyHeroes = gsoGetEnemyHeroes(range, sourcePos, bb, jaxE)
    for i = 1, #enemyHeroes do
        local x
        local unit = enemyHeroes[i]
        if selectedID and gsoValid(selected) and not gsoIsImmortal(selected, jaxE) and unit.networkID == selectedID then
            return selected
        elseif mode == 1 then
            local unitName = unit.charName
            local multiplier = gsoPriorityMultiplier[gsoMenu.ts.priority[unitName] and gsoMenu.ts.priority[unitName]:Value() or 6]
            local def = dmgType == "ap" and multiplier * (unit.magicResist - gsoMyHero.magicPen) or multiplier * (unit.armor - gsoMyHero.armorPen)
            if def > 0 then def = dmgType == "ap" and gsoMyHero.magicPenPercent * def or gsoMyHero.bonusArmorPenPercent * def end
                  x = ( ( unit.health * multiplier * ( ( 100 + def ) / 100 ) ) - ( unit.totalDamage * unit.attackSpeed * 2 ) ) - unit.ap
        elseif mode == 2 then
            x = gsoDistance(unit.pos, sourcePos)
        elseif mode == 3 then
            x = unit.health
        elseif mode == 4 then
            local unitName = unit.charName
                  x = gsoMenu.ts.priority[unitName] and gsoMenu.ts.priority[unitName]:Value() or 6
        end
        if x < num then
            num = x
            result = unit
        end
    end
    return result
end





class "__gsoSDK"
    function __gsoSDK:__init()
        self.Menu = gsoMenu
        self.Mode = gsoMode
        self.Timers = gsoTimers
        self.State = gsoState
        self.Extra = gsoExtra
    end
    function __gsoSDK:CursorPositionChanged()
        setCursorPosition[gsoGetTickCount()] = { function() return 0 end, 50 }
        gsoState.isChangingCursorPos = true
    end
    function __gsoSDK:OnAttack(func)
        gsoOnAttack[#gsoOnAttack+1] = func
    end
    function __gsoSDK:OnMove(func)
        gsoOnMove[#gsoOnMove+1] = func
    end
    function __gsoSDK:CanAttack(func)
        gsoCanAttack[#gsoCanAttack+1] = func
    end
    function __gsoSDK:CanMove(func)
        gsoCanMove[#gsoCanMove+1] = func
    end
    function __gsoSDK:EnableAttack(boolean)
        gsoState.enabledAttack = boolean
    end
    function __gsoSDK:EnableMove(boolean)
        gsoState.enabledMove = boolean
    end
    function __gsoSDK:EnableOrb(boolean)
        gsoState.enabledOrb = boolean
    end
    function __gsoSDK:ResetAttack()
        gsoLastAttackSend = 0
        gsoServerStart = 0
    end
    function __gsoSDK:HeroIsValid(unit)
        if unit.dead or not unit.isTargetable or not unit.visible or not unit.valid or gsoIsImmortal(unit) then
            return false
        end
        return true
    end
gsoSDK = __gsoSDK()





function OnLoad()
    gsoMenu:MenuElement({name = "Target Selector", id = "ts", type = MENU })
        gsoMenu.ts:MenuElement({ id = "Mode", name = "Mode", value = 1, drop = { "Auto", "Closest", "Least Health", "Least Priority" } })
        gsoMenu.ts:MenuElement({ id = "priority", name = "Priorities", type = MENU })
        gsoMenu.ts:MenuElement({ id = "selected", name = "Selected Target", type = MENU })
            gsoMenu.ts.selected:MenuElement({ id = "enable", name = "Enable", value = true })
            gsoMenu.ts.selected:MenuElement({ id = "only", name = "Only Selected Target", value = false })
            gsoMenu.ts.selected:MenuElement({name = "Draw",  id = "draw", type = MENU})
                gsoMenu.ts.selected.draw:MenuElement({name = "Enable",  id = "enable", value = true})
                gsoMenu.ts.selected.draw:MenuElement({name = "Color",  id = "color", color = gsoDrawColor(255, 204, 0, 0)})
                gsoMenu.ts.selected.draw:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
                gsoMenu.ts.selected.draw:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
    gsoMenu:MenuElement({name = "Orbwalker", id = "orb", type = MENU })
        gsoMenu.orb:MenuElement({name = "Delays", id = "delays", type = MENU})
            gsoMenu.orb.delays:MenuElement({name = "Extra Kite Delay", id = "windup", value = 0, min = 0, max = 50, step = 1 })
            gsoMenu.orb.delays:MenuElement({name = "Extra LastHit Delay", id = "lhDelay", value = 0, min = 0, max = 50, step = 1 })
            gsoMenu.orb.delays:MenuElement({name = "Extra Move Delay", id = "humanizer", value = 200, min = 120, max = 300, step = 10 })
        gsoMenu.orb:MenuElement({name = "Keys", id = "keys", type = MENU})
            gsoMenu.orb.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
            gsoMenu.orb.keys:MenuElement({name = "Harass Key", id = "harass", key = string.byte("C")})
            gsoMenu.orb.keys:MenuElement({name = "LastHit Key", id = "lastHit", key = string.byte("X")})
            gsoMenu.orb.keys:MenuElement({name = "LaneClear Key", id = "laneClear", key = string.byte("V")})
        gsoMenu.orb:MenuElement({name = "Drawings", id = "draw", type = MENU})
            gsoMenu.orb.draw:MenuElement({name = "Enable", id = "enable", value = true})
            gsoMenu.orb.draw:MenuElement({name = "gsoMyHero attack range", id = "me", type = MENU})
                gsoMenu.orb.draw.me:MenuElement({name = "Enable",  id = "enable", value = true})
                gsoMenu.orb.draw.me:MenuElement({name = "Color",  id = "color", color = gsoDrawColor(150, 49, 210, 0)})
                gsoMenu.orb.draw.me:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
            gsoMenu.orb.draw:MenuElement({name = "Enemy attack range", id = "he", type = MENU})
                gsoMenu.orb.draw.he:MenuElement({name = "Enable",  id = "enable", value = true})
                gsoMenu.orb.draw.he:MenuElement({name = "Color",  id = "color", color = gsoDrawColor(150, 255, 0, 0)})
                gsoMenu.orb.draw.he:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
            gsoMenu.orb.draw:MenuElement({name = "Cursor Posistion",  id = "cpos", type = MENU})
                gsoMenu.orb.draw.cpos:MenuElement({name = "Enable",  id = "enable", value = true})
                gsoMenu.orb.draw.cpos:MenuElement({name = "Color",  id = "color", color = gsoDrawColor(150, 153, 0, 76)})
                gsoMenu.orb.draw.cpos:MenuElement({name = "Width",  id = "width", value = 5, min = 1, max = 10})
                gsoMenu.orb.draw.cpos:MenuElement({name = "Radius",  id = "radius", value = 250, min = 1, max = 300})
    if _G.Orbwalker then
        GOS.BlockMovement = true
        GOS.BlockAttack = true
        _G.Orbwalker.Enabled:Value(false)
    end
    if _G.SDK and _G.SDK.Orbwalker then
        _G.SDK.Orbwalker:SetMovement(false)
        _G.SDK.Orbwalker:SetAttack(false)
    end
    if _G.EOW then
        _G.EOW:SetMovements(false)
        _G.EOW:SetAttacks(false)
    end
    gsoLoaded = true
    print("Gamsteron Orb "..gsoVersion.." | loaded!")
end


--[[
local gsoLatencies = {}
local gsoDelayedActions = {}
local gsoSetCursorPos = nil
local gsoLastKey = 0
local gsoBaseAASpeed = 0
local gsoBaseWindUp = 0
local gsoServerStart = 0
local gsoServerWindup = 0
local gsoServerAnim = 0
local gsoLastFound = -10000000
local gsoLastSelTick = 0
local gsoIsTeemo = false
local gsoLoadedChamps = false




local gsoMenu = MenuElement({name = "Gamsteron Orbwalker", id = "gamsteronorb", type = MENU })
local gsoMode = { isCombo = false, isHarass = false, isLastHit = false, isLaneClear = false }
local gsoTimers = { lastAttackSend = 0, lastMoveSend = 0, millisecondsToAttack = 0, millisecondsToMove = 0, windUpTime = 0, animationTime = 0, endTime = 0, startTime = 0 }
local gsoState = { isAttacking = false, isMoving = false, isEvading = false, isChangingCursorPos = false, isBlindedByTeemo = false, canAttack = true, canMove = true, enabledAttack = true, enabledMove = true, enabledOrb = true }
local gsoExtra = { lastMovePos = myHero.pos, maxLatency = gsoGame.Latency() * 0.001, minLatency = gsoGame.Latency() * 0.001, lastTarget = nil, selectedTarget = nil, allyTeam = myHero.team }
]]


function OnDraw()
    
    if not gsoLoaded or not gsoMenu.orb.draw.enable:Value() or not gsoState.enabledOrb or gsoMyHero.dead then return end
    
    local mePos = gsoMyHero.pos
    if gsoMenu.orb.draw.me.enable:Value() and mePos:ToScreen().onScreen then
        gsoDrawCircle(mePos, gsoMyHero.range + gsoMyHero.boundingRadius + 35, gsoMenu.orb.draw.me.width:Value(), gsoMenu.orb.draw.me.color:Value())
    end
    
    if gsoMenu.orb.draw.he.enable:Value() then
        local enemyHeroes = gsoGetEnemyHeroes(10000, gsoMyHero.pos, false, false)
        for i = 1, #enemyHeroes do
            local unit = enemyHeroes[i]
            local pos = unit.pos
            if pos:ToScreen().onScreen then
                gsoDrawCircle(pos, unit.range + unit.boundingRadius + gsoMyHero.boundingRadius, gsoMenu.orb.draw.he.width:Value(), gsoMenu.orb.draw.he.color:Value())
            end
        end
    end
    
    if gsoMenu.orb.draw.cpos.enable:Value() then
        gsoDrawCircle(mousePos, gsoMenu.orb.draw.cpos.radius:Value(), gsoMenu.orb.draw.cpos.width:Value(), gsoMenu.orb.draw.cpos.color:Value())
    end
    
    if gsoMenu.ts.selected.draw.enable:Value() and gsoValid(gsoExtra.selectedTarget) then
        gsoDrawCircle(gsoExtra.selectedTarget.pos, gsoMenu.ts.selected.draw.radius:Value(), gsoMenu.ts.selected.draw.width:Value(), gsoMenu.ts.selected.draw.color:Value())
    end
end





function OnTick()
    
    if not gsoLoaded or not gsoState.enabledOrb or gsoMyHero.dead then return end
    
    if gsoSetCursorPos then
        if gsoSetCursorPos.active and gsoGetTickCount() > gsoSetCursorPos.endTime then
            gsoSetCursorPos.action()
            gsoSetCursorPos.active = false
        elseif not gsoSetCursorPos.active and gsoGetTickCount() > gsoSetCursorPos.endTime + 25 then
            gsoState.isChangingCursorPos = false
            gsoSetCursorPos = nil
        end
    end
    
    local lat1 = 0
    local lat2 = 50
    gsoLatencies[#gsoLatencies+1] = { endTime = gsoGetTickCount() + 2500, Latency = gsoGameLatency() * 0.001 }
    local cacheLatencies = {}
    for i = 1, #gsoLatencies do
        local t = gsoLatencies[i]
        if gsoGetTickCount() < t.endTime then
            cacheLatencies[#cacheLatencies+1] = t
            if t.Latency > lat1 then
                lat1 = t.Latency
                gsoExtra.maxLatency = lat1
            end
            if t.Latency < lat2 then
                lat2 = t.Latency
                gsoExtra.minLatency = lat2
            end
        end
    end
    gsoLatencies = cacheLatencies
    
    local cacheDelayedActions = {}
    for i = 1, #gsoDelayedActions do
        local t = gsoDelayedActions[i]
        if gsoGameTimer() > t.endTime then
            t.func()
        else
            cacheDelayedActions[#cacheDelayedActions+1] = t
        end
    end
    gsoDelayedActions = cacheDelayedActions
    
    if gsoIsTeemo == true then
        local isBlinded = false
        for i = 0, gsoMyHero.buffCount do
            local buff = gsoMyHero:GetBuff(i)
            if buff and buff.count > 0 and buff.name:lower() == "blindingdart" and buff.duration > 0 then
                isBlinded = true
                break
            end
        end
        gsoState.isBlindedByTeemo = isBlinded
    end
    
    if not gsoLoadedChamps then
        for i = 1, gsoGameHeroCount() do
            local hero = gsoGameHero(i)
            if hero.team ~= gsoAllyTeam then
                local eName = hero.charName
                if eName and #eName > 0 and not gsoMenu.ts.priority[eName] then
                    gsoLastFound = gsoGameTimer()
                    local priority = gsoPriorities[eName] ~= nil and gsoPriorities[eName] or 5
                    gsoMenu.ts.priority:MenuElement({ id = eName, name = eName, value = priority, min = 1, max = 5, step = 1 })
                    if eName == "Teemo" then          gsoIsTeemo = true
                    elseif eName == "Kayle" then      gsoUndyingBuffs["JudicatorIntervention"] = true
                    elseif eName == "Taric" then      gsoUndyingBuffs["TaricR"] = true
                    elseif eName == "Kindred" then    gsoUndyingBuffs["kindredrnodeathbuff"] = true
                    elseif eName == "Zilean" then     gsoUndyingBuffs["ChronoShift"] = true; gsoUndyingBuffs["chronorevive"] = true
                    elseif eName == "Tryndamere" then gsoUndyingBuffs["UndyingRage"] = true
                    elseif eName == "Jax" then        gsoUndyingBuffs["JaxCounterStrike"] = true; gsoIsJax = true
                    elseif eName == "Fiora" then      gsoUndyingBuffs["FioraW"] = true
                    elseif eName == "Aatrox" then     gsoUndyingBuffs["aatroxpassivedeath"] = true
                    elseif eName == "Vladimir" then   gsoUndyingBuffs["VladimirSanguinePool"] = true
                    elseif eName == "KogMaw" then     gsoUndyingBuffs["KogMawIcathianSurprise"] = true
                    elseif eName == "Karthus" then    gsoUndyingBuffs["KarthusDeathDefiedBuff"] = true
                    end
                end
            end
        end
        if gsoGameTimer() > gsoLastFound + 2.5 and gsoGameTimer() < gsoLastFound + 5 then
            gsoLoadedChamps = true
        end
    end
    
    local aSpell = gsoMyHero.activeSpell
    local aSpellName = aSpell.name:lower()
    if not gsoNoAttacks[aSpellName] and (aSpellName:find("attack") or gsoAttacks[aSpellName]) and aSpell.startTime > gsoServerStart then
        gsoServerStart = aSpell.startTime
        gsoServerWindup = aSpell.windup
        gsoServerAnim = aSpell.animation
    end
    
    gsoMode = { isCombo = gsoMenu.orb.keys.combo:Value(), isHarass = gsoMenu.orb.keys.harass:Value(), isLastHit = gsoMenu.orb.keys.lastHit:Value(), isLaneClear = gsoMenu.orb.keys.laneClear:Value() }
    local aaTarget = nil
    if gsoMode.isCombo then
        aaTarget = gsoGetTarget(gsoMyHero.range + gsoMyHero.boundingRadius, gsoMyHero.pos, "ad", true, true)
    elseif not gsoState.isChangingCursorPos and gsoGetTickCount() < gsoLastKey + 1000 then
        gsoControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
        gsoLastKey = 0
    end
    
    if gsoBaseAASpeed == 0 then
        gsoBaseAASpeed  = 1 / gsoMyHero.attackData.animationTime / gsoMyHero.attackSpeed
    end
    if gsoBaseWindUp == 0 then
        gsoBaseWindUp = gsoMyHero.attackData.windUpTime / gsoMyHero.attackData.animationTime
    end
    
    local aaSpeed = gsoAttackSpeed() * gsoBaseAASpeed
    local numAS   = aaSpeed >= 2.5 and 2.5 or aaSpeed
    local animT   = 1 / numAS
    local windUpT = animT * gsoBaseWindUp
    
    gsoServerAnim = aaSpeed >= 2.5 and animT or gsoServerAnim
    gsoServerWindup = aaSpeed >= 2.5 and windUpT or gsoServerWindup
    
    local extraWindUp = math.abs(windUpT-gsoServerWindup) + (gsoMenu.orb.delays.windup:Value() * 0.001)
    local windUpAA = windUpT > gsoServerWindup and gsoServerWindup or windUpT
    
    gsoTimers.windUpTime = windUpT > gsoServerWindup and windUpT or gsoServerWindup
    gsoTimers.animationTime = animT > gsoServerAnim and animT or gsoServerAnim
    
    local sToAA = ( ( gsoServerStart - windUpAA ) + ( gsoTimers.animationTime - ( gsoExtra.minLatency - 0.05 ) ) ) - gsoGameTimer()
    local sToMove = ( ( gsoServerStart + extraWindUp ) - ( gsoExtra.minLatency * 0.5 ) ) - gsoGameTimer()
    local isChatOpen = gsoGameIsChatOpen()
    gsoTimers.secondsToAttack = sToAA > 0 and sToAA or 0
    gsoTimers.secondsToMove = sToMove > 0 and sToMove or 0
    gsoState.isEvading = ExtLibEvade and ExtLibEvade.Evading
    gsoState.canAttack = not gsoState.isChangingCursorPos and not gsoState.isBlindedByTeemo and not gsoState.isEvading and gsoState.enabledAttack and gsoTimers.secondsToAttack == 0 and not isChatOpen
    gsoState.canMove = not gsoState.isChangingCursorPos and not gsoState.isEvading and gsoState.enabledMove and gsoTimers.secondsToMove == 0 and not isChatOpen
    
    if gsoMode.isLaneClear or gsoMode.isLastHit or gsoMode.isHarass then
        gsoState.canMove = gsoState.canMove and gsoGameTimer() > gsoTimers.lastAttackSend + gsoTimers.windUpTime + gsoExtra.maxLatency + 0.05
    end
    
    if gsoMode.isCombo or gsoMode.isHarass or gsoMode.isLastHit or gsoMode.isLaneClear then
        if aaTarget and gsoState.canAttack then
            if ExtLibEvade and ExtLibEvade.Evading then
                gsoState.isMoving = true
                gsoState.isAttacking = false
                return
            end
            local args = { Process = true, Target = aaTarget }
            for i = 1, #gsoOnAttack do
                local action = gsoOnAttack[i](args)
                if not args.Process or not args.Target then
                    gsoState.isAttacking = false
                    return
                end
            end
            local cPos = cursorPos
            gsoControlSetCursor(args.Target.pos)
            gsoControlKeyDown(HK_TCO)
            gsoControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
            gsoControlMouseEvent(MOUSEEVENTF_RIGHTUP)
            gsoControlKeyUp(HK_TCO)
            gsoState.isChangingCursorPos = true
            gsoSetCursorPos = { endTime = gsoGetTickCount() + 50, action = function() gsoControlSetCursor(cPos.x, cPos.y) end, active = true }
            gsoTimers.lastMoveSend = 0
            gsoTimers.lastAttackSend = gsoGameTimer()
            gsoExtra.lastTarget = args.Target
            gsoState.isMoving = false
            gsoState.isAttacking = true
        elseif gsoState.canMove then
            local args = { Process = true }
            for i = 1, #gsoOnMove do
                local action = gsoOnMove[i](args)
                if not args.Process then
                    gsoState.isMoving = false
                    return
                end
            end
            if gsoGameTimer() > gsoTimers.lastMoveSend + ( gsoMenu.orb.delays.humanizer:Value() * 0.001 ) then
                if ExtLibEvade and ExtLibEvade.Evading then
                    gsoState.isMoving = true
                    gsoState.isAttacking = false
                    return
                end
                if gsoControlIsKeyDown(2) then gsoLastKey = gsoGetTickCount() end
                gsoExtra.lastMovePos = mousePos
                gsoControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
                gsoControlMouseEvent(MOUSEEVENTF_RIGHTUP)
                gsoTimers.lastMoveSend = gsoGameTimer()
                gsoState.isMoving = true
                gsoState.isAttacking = false
            end
        end
    else
        gsoExtra.lastTarget = nil
        gsoState.isMoving = false
        gsoState.isAttacking = false
    end
end





function OnWndMsg(msg, wParam)
    
    if not gsoLoaded or not gsoState.enabledOrb or gsoMyHero.dead then return end
    
    if wParam == HK_TCO then
        gsoTimers.lastAttackSend = gsoGameTimer()
        return
    end
    if msg == WM_LBUTTONDOWN and gsoMenu.ts.selected.enable:Value() and gsoGetTickCount() > gsoLastSelTick + 100 then
        local num = 10000000
        local enemyHeroes = gsoGetEnemyHeroes(10000, gsoMyHero.pos, false, false)
              gsoExtra.selectedTarget = nil
        for i = 1, #enemyHeroes do
            local unit = enemyHeroes[i]
            local distance = gsoDistance(mousePos, unit.pos)
            if distance < 150 and distance < num then
                gsoExtra.selectedTarget = unit
                num = distance
            end
        end
        gsoLastSelTick = gsoGetTickCount()
    end
end































--[[

class "__gsoFarm"

function __gsoFarm:__init()
    self.aaDmg          = gsoMyHero.totalDamage
    self.lastHit        = {}
    self.almostLH       = {}
    self.laneClear      = {}
    self.aAttacks       = {}
    self.shouldWaitT    = 0
    self.shouldWait     = false
end

function __gsoFarm:_tick()
    self.aaDmg   = gsoMyHero.totalDamage + gsoSDK.Vars._bonusDmg()
    if self.shouldWait == true and gsoGameTimer() > self.shouldWaitT + 0.5 then
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
        local distUP  = gsoSDK.Utils:_getDistance(pPos, uPos)
        local distEP  = gsoSDK.Utils:_getDistance(pPos, ePos)
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
    for i = 1, #gsoSDK.OB.allyMinions do
        local aMin = gsoSDK.OB.allyMinions[i]
        local aaData  = aMin.attackData
        local aDmg    = (aMin.totalDamage*(1+aMin.bonusDamagePercent))
        if aaData.target == eMin.handle then
            local endT    = aaData.endTime
            local animT   = aaData.animationTime
            local windUpT = aaData.windUpTime
            local pSpeed  = aaData.projectileSpeed
            local pFlyT   = pSpeed > 0 and gsoSDK.Utils:_getDistance(aMin.pos, eMin.pos) / pSpeed or 0
            local pStartT = endT - animT
            local pEndT   = pStartT + pFlyT + windUpT
            local checkT  = gsoGameTimer()
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
    local mLH = gsoSDK.Load.menu.orb.delays.lhDelay:Value()*0.001
    for i = 1, #gsoSDK.OB.enemyMinions do
        local eMinion = gsoSDK.OB.enemyMinions[i]
        local eMinion_handle	= eMinion.handle
        local distance = gsoSDK.Utils:_getDistance(gsoMyHero.pos, eMinion.pos)
        if distance < gsoMyHero.range + gsoMyHero.boundingRadius + eMinion.boundingRadius then
            local eMinion_health	= eMinion.health
            local gsoMyHero_aaData		= gsoMyHero.attackData
            local gsoMyHero_pFlyTime	= gsoMyHero_aaData.windUpTime + (distance / gsoMyHero_aaData.projectileSpeed) + 0.125 + mLH
            for k1,v1 in pairs(self.aAttacks) do
                for k2,v2 in pairs(self.aAttacks[k1]) do
                    if v2.canceled == false and eMinion_handle == v2.to.handle then
                        local checkT	= gsoGameTimer()
                        local pEndTime	= v2.startTime + v2.pTime
                        if pEndTime > checkT and  pEndTime - checkT < gsoMyHero_pFlyTime - mLH then
                            eMinion_health = eMinion_health - v2.dmg
                        end
                    end
                end
            end
            local gsoMyHero_dmg = self.aaDmg + gsoSDK.Vars._bonusDmgUnit(eMinion)
            if eMinion_health - gsoMyHero_dmg < 0 then
                self.lastHit[#self.lastHit+1] = { eMinion, eMinion_health }
            else
                if eMinion.health - self:_possibleDmg(eMinion, gsoMyHero.attackData.animationTime*3) - gsoMyHero_dmg < 0 then
                    self.shouldWait = true
                    self.shouldWaitT = gsoGameTimer()
                    self.almostLH[#self.almostLH+1] = eMinion
                else
                    self.laneClear[#self.laneClear+1] = eMinion
                end
            end
        end
    end
end
function __gsoSDK:GetHealthPrediction(unit, time)
    for i = 1, #gsoSDK.OB.enemyMinions do
        local eMinion = gsoSDK.OB.enemyMinions[i]
        local eMinion_handle	= eMinion.handle
        local distance = gsoSDK.Utils:_getDistance(gsoMyHero.pos, eMinion.pos)
        if distance < gsoMyHero.range + gsoMyHero.boundingRadius + eMinion.boundingRadius then
            local eMinion_health	= eMinion.health
            local gsoMyHero_aaData		= gsoMyHero.attackData
            local gsoMyHero_pFlyTime	= gsoMyHero_aaData.windUpTime + (distance / gsoMyHero_aaData.projectileSpeed) + 0.125 + mLH
            for k1,v1 in pairs(self.aAttacks) do
                for k2,v2 in pairs(self.aAttacks[k1]) do
                    if v2.canceled == false and eMinion_handle == v2.to.handle then
                        local checkT	= gsoGameTimer()
                        local pEndTime	= v2.startTime + v2.pTime
                        if pEndTime > checkT and  pEndTime - checkT < gsoMyHero_pFlyTime - mLH then
                            eMinion_health = eMinion_health - v2.dmg
                        end
                    end
                end
            end
            local gsoMyHero_dmg = self.aaDmg + gsoSDK.Vars._bonusDmgUnit(eMinion)
            if eMinion_health - gsoMyHero_dmg < 0 then
                self.lastHit[#self.lastHit+1] = { eMinion, eMinion_health }
            else
                if eMinion.health - self:_possibleDmg(eMinion, gsoMyHero.attackData.animationTime*3) - gsoMyHero_dmg < 0 then
                    self.shouldWait = true
                    self.shouldWaitT = gsoGameTimer()
                    self.almostLH[#self.almostLH+1] = eMinion
                else
                    self.laneClear[#self.laneClear+1] = eMinion
                end
            end
        end
    end
end

function __gsoFarm:_setActiveAA()
    for i = 1, #gsoSDK.OB.allyMinions do
        local aMinion = gsoSDK.OB.allyMinions[i]
        local aHandle	= aMinion.handle
        local aAAData	= aMinion.attackData
        if aAAData.endTime > gsoGameTimer() then
            for i = 1, #gsoSDK.OB.enemyMinions do
                local eMinion = gsoSDK.OB.enemyMinions[i]
                local eHandle	= eMinion.handle
                if eHandle == aAAData.target then
                    local checkT		= gsoGameTimer()
                    -- p -> projectile
                    local pSpeed  = aAAData.projectileSpeed
                    local aMPos   = aMinion.pos
                    local eMPos   = eMinion.pos
                    local pFlyT		= pSpeed > 0 and gsoSDK.Utils:_getDistance(aMPos, eMPos) / pSpeed or 0
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
        local checkT	= gsoGameTimer()
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
                    self.aAttacks[k1][k2].pTime = gsoSDK.Utils:_getDistance(v2.fromPos, self:_predPos(v2.speed, v2.pos, v2.to)) / v2.speed
                end
                if checkT > v2.startTime + self.aAttacks[k1][k2].pTime - (gsoGame.Latency()*0.0015) - 0.034 or not v2.to or v2.to.dead then
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







local function gsolastHitT()
    local result  = nil
    local min     = 10000000
    for i = 1, #gsoSDK.Farm.lastHit do
        local eMinionLH = gsoSDK.Farm.lastHit[i]
        local minion	= eMinionLH[1]
        local hp		= eMinionLH[2]
        local checkT = gsoGameTimer() < self.LHTimers[0].tick
        local mHandle = minion.handle
        if (not checkT or (checkT and self.LHTimers[0].id ~= mHandle)) and hp < min then
            min = hp
            result = minion
            self.LHTimers[4].tick = gsoGameTimer() + 0.75
            self.LHTimers[4].id = mHandle
        end
    end
    return result
end

local function gsogetTurret()
    local result = nil
    for i=1, #gsoSDK.OB.enemyTurrets do
        local turret = gsoSDK.OB.enemyTurrets[i]
        local range = gsoMyHero.range + gsoMyHero.boundingRadius + turret.boundingRadius
        if gsoSDK.Utils:_getDistance(gsoMyHero.pos, turret.pos) < range then
            result = turret
            break
        end
    end
    return result
end

local function gsolaneClearT()
    local result	= self:_lastHitT()
    if not result then
        result = self:_comboT()
        if not result and #gsoSDK.Farm.almostLH == 0 and gsoSDK.Farm.shouldWait == false then
            result = self:_getTurret()
            if not result then
                local min = 10000000
                for i = 1, #gsoSDK.Farm.laneClear do
                    local minion = gsoSDK.Farm.laneClear[i]
                    local hp     = minion.health
                    if hp < min then
                        min = hp
                        result = minion
                    end
                end
            end
        end
    end
    return result
end

local function gsoharassT()
    local result = self:_lastHitT()
    return result == nil and self:_comboT() or result
end









]]



--[[

    A P I :

        I. LOAD:
            1. require "GamsteronOrb"                                                         -> Declaration of Library
            2. gsoSDK.Load.Loaded                                                             -> Check if Library is loaded
                Example:
                    if gsoSDK and gsoSDK.Load and gsoSDK.Load.Loaded then
                        ..
                    end

        II. MENU:
            1. gsoSDK.Load.menu.orb.keys.combo:Value()                                        -> Combo Key
            2. gsoSDK.Load.menu.orb.keys.harass:Value()                                       -> Harass Key
            3. gsoSDK.Load.menu.orb.keys.lastHit:Value()                                      -> LastHit Key
            4. gsoSDK.Load.menu.orb.keys.laneClear:Value()                                    -> LaneClear Key

        III. OBJECT LISTS (access from event gsoSDK.Vars:_setOnTick):
            1. gsoSDK.OB.allyMinions                                                          -> Ally Minions
            2. gsoSDK.OB.enemyMinions                                                         -> Enemy Minions
            3. gsoSDK.OB.enegsoMyHeroes                                                          -> Enemy Heroes
            4. gsoSDK.OB.enemyTurrets                                                         -> Enemy Turrets
            5. gsoSDK.Farm.almostLH                                                           -> Almost LastHitable Enemy Minions
            6. gsoSDK.Farm.laneClear                                                          -> LaneClearable Enemy Minions
            7. gsoSDK.Farm.lastHit                                                            -> LastHitable Enemy Minions
                Example for 1, 2, 3, 4, 5, 6:
                    for i = 1, #gsoSDK.OB.allyMinions do
                        local minion = gsoSDK.OB.allyMinions[i]
                    end
                Example for 7:
                    for i = 1, #gsoSDK.Farm.lastHit do
                        local minion = gsoSDK.Farm.lastHit[i][1]
                        local predictedHP = gsoSDK.Farm.lastHit[i][2]
                    end
        IV. IMPORTANT FUNCTIONS FOR SPELLS INTEGRATION:
            1. gsoSDK.Vars._manualSpell(spell)                                                -> use this in onTick event for manual spells ( tristana W, ezreal E, lucian E etc. ) -> this will use spell only if was used recently by user
                Example :
                    function tick()
                        gsoSDK.Vars._castManualSpell(_E)
                    end
            2. gsoSDK.Vars._canUseSpell()                                                     -> check if can use spells ( in this way cursor will always return to previous position )
                                                                                                 only if spell is changing cursorPos (ezreal q etc) - you don't need it for draven q, tristana q etc.
            3. gsoSDK.Vars._afterSpell()                                                      -> Use this after each spell usage ( in this way cursor will always return to previous position 
                Example :                                                                        only if spell is changing cursorPos (ezreal q etc) - you don't need it for draven q, tristana q etc.
                    if qReady and gsoSDK.Vars._canUseSpell() then
                        useQ()
                        gsoSDK.Vars._afterSpell()
                    end
        V. CALLBACKS:
            1. gsoSDK.Vars:_setOnTick(                                                        -> you can declare onTick via my orbwalker ( in this way you will have access to object lists [ look above at III. OBJECT LISTS ] )
                    function()
                        handleTwitchEBuffs()
                    end)  
            2. gsoSDK.Vars:_setOnKeyPress(
                    function(target)                                                          -> on key press - return current orb target (minion, turret, hero) -> can be nil
                        spells(target)
                    end)                                        
            3. gsoSDK.Vars:_setBonusDmg(                                                      -> return number ! - Declaration of gsoMyHero extra dmg [ important for laneclear, lasthit ]
                    function()
                        return caitPassive()
                    end)
            4. gsoSDK.Vars:_setBonusDmgUnit(                                                  -> return number ! - Declaration of gsoMyHero extra dmg [ important for laneclear, lasthit ]
                    function(minion)
                        return ashePassive(minion)
                    end)
            5. gsoSDK.Vars:_setOnAttack(                                                      -> you can disable current attack [ args.Process = false ], it's not recommended for spells like dravenQ -> use spells in beforeAttack event
                    function(args)                                                               onAttack event is good for champions like jhin, graves etc. -> passive buff check
                        args.Process = true
                        args.Target = getTarget()
                    end)
            6. gsoSDK.Vars:_setBeforeAttack(                                                  -> (anim*0.75)-(anim*0.9) before attack send (if anim = 1000 -> 150ms for spells)
                    function(unit)
                        castDravenQ()
                    end)
            7. gsoSDK.Vars:_setAfterAttack(                                                   -> afterMove-(anim*0.75) after/before attack send (if anim = 1000 -> ~550ms for spells) - smooth spells usage between attacks 
                    function(unit)
                        castVayneQ()
                    end)
            8. gsoSDK.Vars:_setOnMove(                                                        -> you can disable current move [ args.Process = false ],
                    function(args)                                                               args.MovePos = nil - will move to mousePos without changing cursorPos (don't setup mousePos via args.MovePos ! )
                        args.Process = true
                        if axe then
                            args.MovePos = DravenAxe()
                        else
                            args.MovePos = nil
                        end
                    end)
            9. gsoSDK.Vars:_setAASpeed(                                                       -> set custom attack speed -> gos ext .attackSpeed is delayed -> you can declare attack speed after ashe q buff ends for 1sec
                    function(unit)                                                               (else ashe can stand longer after q buff ends)
                        if gsoGameTimer() < AsheQBuffEndTime + 1000 then
                            return asBeforeQ
                        end
                    end)
        VI. ADDITIONAL:
            1. gsoSDK.Utils:_checkWall(from, to, distance)                                    -> return true if collide with wall
            2. gsoSDK.Utils.maxPing                                                           -> return seconds (for example 0.001) -> maxPing from last 2.5 sec
            3. gsoSDK.Utils.minPing                                                           -> return seconds (for example 0.001) -> minPing from last 2.5 sec
            4. gsoSDK.Utils:_getDistance(a, b)                                                -> return distance between pos a and b
            5. gsoSDK.Utils:_isImmortal(unit, orb)                                            -> return true if enemy hero has kayle R, taric R etc. orb = true for attacks and ezreal q, else orb = false
                                                                                                 gos ext .isImmortal return true for enemies that have GA item
            6. gsoSDK.Orb.lMovePath                                                           -> return last move position
            7. gsoSDK.TS:_getTarget(range, orb, changeRange)                                  -> range = [number] spell range, orb = [boolean] true for attacks and ezreal q else false, changeRange = [boolean] true if attack range, false for spells range
            8. gsoSDK.Vars._canMove()                                                         -> true/false
]]
