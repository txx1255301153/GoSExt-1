




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
local gsoExtraSetCursor = nil
local gsoShouldWaitT    = 0
local gsoShouldWait     = false





local gsoMenu = MenuElement({name = "Gamsteron Orbwalker", id = "gamsteronorb", type = MENU })
local gsoMode = { isCombo = false, isHarass = false, isLastHit = false, isLaneClear = false }
local gsoTimers = { lastAttackSend = 0, lastMoveSend = 0, millisecondsToAttack = 0, millisecondsToMove = 0, windUpTime = 0, animationTime = 0, endTime = 0, startTime = 0 }
local gsoState = { isAttacking = false, isMoving = false, isEvading = false, isChangingCursorPos = false, isBlindedByTeemo = false, canAttack = true, canMove = true, enabledAttack = true, enabledMove = true, enabledOrb = true }
local gsoExtra = { lastMovePos = myHero.pos, maxLatency = Game.Latency() * 0.001, minLatency = Game.Latency() * 0.001, lastTarget = nil, selectedTarget = nil, allyTeam = myHero.team }
local gsoFarm = { activeAttacks = {}, lastHitable = {}, almostLastHitable = {}, laneClearable = {} }





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
local gsoUnkillableMinion = {}
local function gsoAttackSpeed() return gsoMyHero.attackSpeed end
local function gsoBonusDmg() return 0 end
local function gsoBonusDmgUnit(unit) return 0 end




local function ___utilitiesFunc() end

local function gsoDistance(a, b)
    local x = a.x - b.x
    local z = a.z - b.z
    return gsoMathSqrt(x * x + z * z)
end

local function gsoExtended(p, from, to, s)
    local px, pz = p.x, p.z
    local axbx = to.x - from.x
    local azbz = to.z - from.z
    local num = 1 / gsoMathSqrt(axbx * axbx + azbz * azbz)
    return { x = px + (axbx * num * s), z = pz + (azbz * num * s) }
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

local function gsoPredPos(speed, pPos, unit)
    local unitPath = unit.pathing
    if unitPath.hasMovePath == true then
        local uPos    = unit.pos
        local ePos    = unitPath.endPos
        local distUP  = gsoDistance(pPos, uPos)
        local distEP  = gsoDistance(pPos, ePos)
        local unitMS  = unit.ms
        if distEP > distUP then
            return uPos:Extended(ePos, 50+(unitMS*(distUP / (speed - unitMS))))
        else
            return uPos:Extended(ePos, 50+(unitMS*(distUP / (speed + unitMS))))
        end
    end
    return unit.pos
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
    local moveLenght = gsoMyHero.ms * 1.5 * gsoExtra.maxLatency
    for i = 1, gsoGameHeroCount() do
        local hero = gsoGameHero(i)
        local heroBB = (bb and hero) and hero.boundingRadius or 0
        local heroPos = hero and hero.pos or nil
        local isEnemy = heroPos and hero.team ~= gsoExtra.allyTeam and gsoDistance(heroPos, sourcePos) < range + heroBB
              isEnemy = isEnemy and gsoDistance(heroPos, gsoExtended(sourcePos, sourcePos, gsoExtra.lastMovePos, moveLenght)) < range + heroBB
              isEnemy = isEnemy and gsoValid(hero) and not gsoIsImmortal(hero, jaxE)
        if isEnemy then
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


local function gsoGetLastHitTarget()
    local result, min, sourcePos, meRange
    local lastHitable = gsoFarm.lastHitable
    if #lastHitable > 0 then
        min = 10000000
        sourcePos = gsoMyHero.pos
        meRange = gsoMyHero.range + gsoMyHero.boundingRadius
    end
    for i = 1, #lastHitable do
        local minionData = lastHitable[i]
        local minion = minionData.Minion
        local hp = minionData.Health
        if gsoDistance(sourcePos, minion.pos) < meRange + minion.boundingRadius and hp < min then
            min = hp
            result = minion
        end
    end
    return result
end

local function gsoGetTurretTarget()
    local result = nil
    local turrets = gsoGetEnemyTurrets(gsoMyHero.range + gsoMyHero.boundingRadius, gsoMyHero.pos, true)
    for i = 1, #turrets do
        return turrets[i]
    end
    return result
end

local function gsoGetComboTarget()
    return gsoGetTarget(gsoMyHero.range + gsoMyHero.boundingRadius, gsoMyHero.pos, "ad", true, true)
end

local function gsoGetLaneClearTarget()
    local result = gsoGetLastHitTarget()
    if not result and #gsoFarm.almostLastHitable == 0 and not gsoShouldWait then
        result = gsoGetComboTarget()
        result = not result and gsoGetTurretTarget() or result
        if not result then
            local min = 10000000
            local sourcePos, meRange
            local laneClearable = gsoFarm.laneClearable
            if #laneClearable > 0 then
                sourcePos = gsoMyHero.pos
                meRange = gsoMyHero.range + gsoMyHero.boundingRadius
            end
            for i = 1, #laneClearable do
                local minionData = laneClearable[i]
                local minion = minionData.Minion
                local hp = minionData.Health
                if gsoDistance(sourcePos, minion.pos) < meRange + minion.boundingRadius and hp < min then
                    min = hp
                    result = minion
                end
            end
        end
    end
    return result
end

local function gsoGetHarassTarget()
    local result = gsoGetLastHitTarget()
    return not result and gsoGetComboTarget() or result
end

local function gsoMinionHpPredFast(unit, time)
    local result = unit.health
    local allyMinions = gsoGetAllyMinions(2000, gsoMyHero.pos, false)
    for i = 1, #allyMinions do
        local aMin = allyMinions[i]
        local aaData = aMin.attackData
        local aDmg = ( aMin.totalDamage * ( 1 + aMin.bonusDamagePercent ) )
        if aaData.target == unit.handle then
            local endT    = aaData.endTime
            local animT   = aaData.animationTime
            local windUpT = aaData.windUpTime
            local pSpeed  = aaData.projectileSpeed
            local pFlyT   = pSpeed > 0 and gsoDistance(aMin.pos, unit.pos) / pSpeed or 0
            local pStartT = endT - animT
            local pEndT   = pStartT + pFlyT + windUpT
            local checkT  = gsoGameTimer()
                  pEndT   = pEndT > checkT and pEndT or pEndT + animT + pFlyT
            while pEndT - checkT < time do
                result = result - aDmg
                pEndT = pEndT + animT + pFlyT
            end
        end
    end
    return result
end

local function gsoMinionHpPredAccuracy(unit, time)
    local result = unit.health
    local unitHandle = unit.handle
    for k1,v1 in pairs(gsoFarm.activeAttacks) do
        for k2,v2 in pairs(gsoFarm.activeAttacks[k1]) do
            if v2.canceled == false and unitHandle == v2.to.handle then
                local checkT = gsoGameTimer()
                local pEndTime = v2.startTime + v2.pTime
                if pEndTime > checkT and pEndTime - checkT < time then
                    result = result - v2.dmg
                end
            end
        end
    end
    return result
end



local function ___tickFunc() end

local function championsLoadLogic()
    
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
    
end



local function cursorPosLogic()
    
    if gsoSetCursorPos then
        if gsoSetCursorPos.active and gsoGetTickCount() > gsoSetCursorPos.endTime then
            gsoSetCursorPos.action()
            gsoSetCursorPos.active = false
            gsoExtraSetCursor = nil
        elseif not gsoSetCursorPos.active and gsoGetTickCount() > gsoSetCursorPos.endTime + 25 then
            gsoState.isChangingCursorPos = false
            gsoSetCursorPos = nil
        end
    end
    
    if gsoExtraSetCursor then
        gsoControlSetCursor(gsoExtraSetCursor)
    end
    
end



local function delayedActionsLogic()
    
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
    
end



local function latencyLogic()
    
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
    
end



local function teemoBlindLogic()
    
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
    
end



local function activeAttacksLogic()
    
    local allyMinions = gsoGetAllyMinions(2000, gsoMyHero.pos, false)
    local enemyMinions = gsoGetEnemyMinions(2000, gsoMyHero.pos, false)
    for i = 1, #allyMinions do
        local aMinion = allyMinions[i]
        local aHandle	= aMinion.handle
        local aAAData	= aMinion.attackData
        if aAAData.endTime > gsoGameTimer() then
            for i = 1, #enemyMinions do
                local eMinion = enemyMinions[i]
                local eHandle	= eMinion.handle
                if eHandle == aAAData.target then
                    local checkT		= gsoGameTimer()
                    -- p -> projectile
                    local pSpeed  = aAAData.projectileSpeed
                    local aMPos   = aMinion.pos
                    local eMPos   = eMinion.pos
                    local pFlyT		= pSpeed > 0 and gsoDistance(aMPos, eMPos) / pSpeed or 0
                    local pStartT	= aAAData.endTime - aAAData.windDownTime
                    if not gsoFarm.activeAttacks[aHandle] then
                        gsoFarm.activeAttacks[aHandle] = {}
                    end
                    local aaID = aAAData.endTime
                    if checkT < pStartT + pFlyT then
                        if pSpeed > 0 then
                            if checkT > pStartT then
                                if not gsoFarm.activeAttacks[aHandle][aaID] then
                                    gsoFarm.activeAttacks[aHandle][aaID] = {
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
                              gsoFarm.activeAttacks[aHandle][aaID] = {
                                  canceled  = true,
                                  from      = aMinion
                              }
                            end
                          elseif not gsoFarm.activeAttacks[aHandle][aaID] then
                              gsoFarm.activeAttacks[aHandle][aaID] = {
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
    
    for k1,v1 in pairs(gsoFarm.activeAttacks) do
        local count		= 0
        local checkT	= gsoGameTimer()
        for k2,v2 in pairs(gsoFarm.activeAttacks[k1]) do
            count = count + 1
            if v2.speed == 0 and (not v2.from or v2.from.dead) then
                --print("dead")
                gsoFarm.activeAttacks[k1] = nil
                break
            end
            if v2.canceled == false then
                local ranged = v2.speed > 0
                if ranged == true then
                    gsoFarm.activeAttacks[k1][k2].pTime = gsoDistance(v2.fromPos, gsoPredPos(v2.speed, v2.pos, v2.to)) / v2.speed
                end
                local projectileOnEnemy = gsoExtra.maxLatency + 0.015
                if checkT > v2.startTime + gsoFarm.activeAttacks[k1][k2].pTime - projectileOnEnemy or not v2.to or v2.to.dead then
                    gsoFarm.activeAttacks[k1][k2] = nil
                elseif ranged == true then
                    gsoFarm.activeAttacks[k1][k2].pos = v2.fromPos:Extended(v2.to.pos, (checkT-v2.startTime)*v2.speed)
                end
            end
        end
        if count == 0 then
            --print("no active attacks")
            gsoFarm.activeAttacks[k1] = nil
        end
    end
    
end



local function minionsLogic()
    
    if gsoShouldWait and gsoGameTimer() > gsoShouldWaitT + 0.5 then
        gsoShouldWait = false
    end
    
    local sourcePos, sourceRange, mLH, aaData, windUp, meDmg
    local enemyMinions = gsoGetEnemyMinions(2000, gsoMyHero.pos, false)
    if #enemyMinions > 0 then
        sourcePos = gsoMyHero.pos
        sourceRange = gsoMyHero.range + gsoMyHero.boundingRadius
        mLH = gsoMenu.orb.delays.lhDelay:Value() * 0.001
        aaData = gsoMyHero.attackData
        windUp = aaData.windUpTime + gsoExtra.minLatency + mLH
        meDmg = myHero.totalDamage + gsoBonusDmg()
    end
    
    local lastHitable = {}
    local almostLastHitable = {}
    local laneClearable = {}
    for i = 1, #enemyMinions do
        local minion = enemyMinions[i]
        local flyTime = windUp + ( gsoDistance(sourcePos, minion.pos) / aaData.projectileSpeed )
        local accuracyHpPred = gsoMinionHpPredAccuracy(minion, flyTime)
        local hpPred = gsoMenu.orb.farmmode:Value() == 1 and accuracyHpPred or gsoMinionHpPredFast(minion, flyTime)
        local dmgOnMinion = meDmg + gsoBonusDmgUnit(minion)
        if accuracyHpPred < 0 then
            local args = { Minion = minion }
            for i = 1, #gsoUnkillableMinion do
                local action = gsoUnkillableMinion[i](args)
            end
            --print("unkillable")
        elseif hpPred - dmgOnMinion <= 0 then
            lastHitable[#lastHitable+1] = { Minion = minion, Health = hpPred }
        else
            local fastHpPred = gsoMinionHpPredFast(minion, aaData.animationTime * 3)
            if fastHpPred - dmgOnMinion < 0 then
                gsoShouldWait = true
                gsoShouldWaitT = gsoGameTimer()
                almostLastHitable[#almostLastHitable+1] = { Minion = minion, Health = hpPred }
            else
                laneClearable[#laneClearable+1] = { Minion = minion, Health = hpPred }
            end
        end
    end
    
    gsoFarm.lastHitable = lastHitable
    gsoFarm.laneClearable = laneClearable
    gsoFarm.almostLastHitable = almostLastHitable
    
end


local function orbwalkerTimersLogic()
    
    local aSpell = gsoMyHero.activeSpell
    local aSpellName = aSpell.name:lower()
    if not gsoNoAttacks[aSpellName] and (aSpellName:find("attack") or gsoAttacks[aSpellName]) and aSpell.startTime > gsoServerStart then
        gsoServerStart = aSpell.startTime
        gsoServerWindup = aSpell.windup
        gsoServerAnim = aSpell.animation
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
    local canMove = gsoGameTimer() > gsoTimers.lastAttackSend + gsoTimers.windUpTime + gsoExtra.minLatency + 0.005 + extraWindUp
    gsoState.canAttack = not gsoState.isChangingCursorPos and not gsoState.isBlindedByTeemo and not gsoState.isEvading and gsoState.enabledAttack and gsoTimers.secondsToAttack == 0 and not isChatOpen and canMove
    gsoState.canMove = not gsoState.isChangingCursorPos and not gsoState.isEvading and gsoState.enabledMove and gsoTimers.secondsToMove == 0 and not isChatOpen and canMove
    if aaTarget and gsoState.canAttack then
        local args = { Target = aaTarget }
        for i = 1, #gsoCanAttack do
            local action = gsoCanAttack[i](args)
            if not args.Target or action == false then
                gsoState.isAttacking = false
                gsoState.canAttack = false
            end
        end
    end
    if gsoState.canMove and (not aaTarget or not gsoState.canAttack) then
        local args = { Target = aaTarget }
        for i = 1, #gsoCanMove do
            local action = gsoCanMove[i](args)
            if action == false then
                gsoState.isMoving = false
                gsoState.canMove = false
            end
        end
    end
    
end

local function orbwalkerLogic()
    
    gsoMode = { isCombo = gsoMenu.orb.keys.combo:Value(), isHarass = gsoMenu.orb.keys.harass:Value(), isLastHit = gsoMenu.orb.keys.lastHit:Value(), isLaneClear = gsoMenu.orb.keys.laneClear:Value() }
    local aaTarget = nil
    if gsoMode.isCombo or gsoMode.isHarass or gsoMode.isLastHit or gsoMode.isLaneClear then
        if gsoBaseAASpeed == 0 then gsoBaseAASpeed  = 1 / gsoMyHero.attackData.animationTime / gsoMyHero.attackSpeed end
        if gsoBaseWindUp == 0 then gsoBaseWindUp = gsoMyHero.attackData.windUpTime / gsoMyHero.attackData.animationTime end
        if gsoMode.isCombo then
            aaTarget = gsoGetComboTarget()
        elseif gsoMode.isHarass then
            aaTarget = gsoGetHarassTarget()
        elseif gsoMode.isLastHit then
            aaTarget = gsoGetLastHitTarget()
        elseif gsoMode.isLaneClear then
            aaTarget = gsoGetLaneClearTarget()
        end
    elseif not gsoState.isChangingCursorPos and gsoGetTickCount() < gsoLastKey + 1000 then
        gsoControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
        gsoLastKey = 0
    end
    
    if gsoMode.isCombo or gsoMode.isHarass or gsoMode.isLastHit or gsoMode.isLaneClear then
        if aaTarget and gsoState.canAttack then
            if ExtLibEvade and ExtLibEvade.Evading then
                gsoState.isMoving = true
                gsoState.isAttacking = false
                gsoState.isEvading = true
                return
            end
            local canAttack = true
            local args = { Process = true, Target = aaTarget }
            for i = 1, #gsoOnAttack do
                local action = gsoOnAttack[i](args)
                if not args.Process or not args.Target then
                    gsoState.isMoving = false
                    gsoState.isAttacking = false
                    canAttack = false
                end
            end
            if canAttack then
                local cPos = cursorPos
                local tPos = args.Target.pos
                gsoControlSetCursor(tPos)
                gsoExtraSetCursor = tPos
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
            end
        elseif gsoState.canMove then
            if ExtLibEvade and ExtLibEvade.Evading then
                gsoState.isMoving = true
                gsoState.isAttacking = false
                gsoState.isEvading = true
                return
            end
            local canMove = true
            local args = { Process = true }
            for i = 1, #gsoOnMove do
                local action = gsoOnMove[i](args)
                if not args.Process then
                    gsoState.isMoving = false
                    gsoState.isAttacking = false
                    canMove = false
                end
            end
            if canMove and gsoGameTimer() > gsoTimers.lastMoveSend + ( gsoMenu.orb.delays.humanizer:Value() * 0.001 ) then
                if gsoControlIsKeyDown(2) then gsoLastKey = gsoGetTickCount() end
                gsoExtra.lastMovePos = mousePos
                gsoControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
                gsoControlMouseEvent(MOUSEEVENTF_RIGHTUP)
                gsoTimers.lastMoveSend = gsoGameTimer()
                gsoState.isMoving = true
                gsoState.isAttacking = false
            end
        elseif not gsoState.isChangingCursorPos and not gsoState.isBlindedByTeemo and not gsoState.isEvading and gsoState.enabledAttack and not isChatOpen then
            for i = 1, #gsoOnAttack do
                gsoOnAttack[i]({ Process = true, Target = gsoExtra.lastTarget })
            end
        end
    else
        gsoExtra.lastTarget = nil
        gsoState.isMoving = false
        gsoState.isAttacking = false
    end
    
end


function OnTick()
    
    if not gsoLoaded or not gsoState.enabledOrb or gsoMyHero.dead then return end
    
    championsLoadLogic()
    cursorPosLogic()
    delayedActionsLogic()
    latencyLogic()
    teemoBlindLogic()
    activeAttacksLogic()
    minionsLogic()
    orbwalkerTimersLogic()
    orbwalkerLogic()
    
end








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
        gsoMenu.orb:MenuElement({name = "Farm Mode", id = "farmmode", value = 1, drop = { "accuracy", "fast" }})
        gsoMenu.orb:MenuElement({name = "Delays", id = "delays", type = MENU})
            gsoMenu.orb.delays:MenuElement({name = "Extra Kite Delay", id = "windup", value = 0, min = -50, max = 50, step = 1 })
            gsoMenu.orb.delays:MenuElement({name = "Extra LastHit Delay", id = "lhDelay", value = 0, min = -200, max = 200, step = 1 })
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
    
    
    local lastHitable = gsoFarm.lastHitable
    for i = 1, #lastHitable do
        local minionData = lastHitable[i]
        local minion = minionData.Minion
        gsoDrawCircle(minion.pos, gsoMenu.ts.selected.draw.radius:Value(), gsoMenu.ts.selected.draw.width:Value(), gsoMenu.ts.selected.draw.color:Value())
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









class "__gsoSDK"
    function __gsoSDK:__init()
        self.Menu = gsoMenu
        self.Mode = gsoMode
        self.Timers = gsoTimers
        self.State = gsoState
        self.Extra = gsoExtra
        self.Farm = gsoFarm
    end
    function __gsoSDK:CursorPositionChanged()
        gsoSetCursorPos = { endTime = gsoGetTickCount() + 50, action = function() return 0 end, active = true }
        gsoState.isChangingCursorPos = true
    end
    function __gsoSDK:OnAttack(func)
        gsoOnAttack[#gsoOnAttack+1] = func
    end
    function __gsoSDK:OnMove(func)
        gsoOnMove[#gsoOnMove+1] = func
    end
    function __gsoSDK:OnUnkillableMinion(func)
        gsoUnkillableMinion[#gsoUnkillableMinion+1] = func
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
        gsoTimers.lastAttackSend = 0
        gsoServerStart = 0
    end
    function __gsoSDK:HeroIsValid(unit)
        if gsoValid(unit) and not gsoIsImmortal(unit) then return true end
        return false
    end
gsoSDK = __gsoSDK()
