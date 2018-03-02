
local gsoVersion = "1.6"

 --[[

A P I
 
INITIALIZE:
local gsoOrbwalker = nil
function OnLoad()
    gsoOrbwalker = __gsoOrbwalker()
end

COPY PASTE:
gsoOrbwalker:CanChangeAnimationTime(function() return canChangeAnimationTime() end)
gsoOrbwalker:BonusDamageOnMinion(function() return bonusDamageOnMinion() end)
gsoOrbwalker:BonusDamageOnMinion2(function(args) return bonusDamageOnMinion2(args) end)
gsoOrbwalker:AttackSpeed(function() return attackSpeed() end)
gsoOrbwalker:OnMove(function(args) onMove(args) end)
gsoOrbwalker:OnAttack(function(args) onAttack(args) end)
gsoOrbwalker:CanMove(function(args) canMove(args) end)
gsoOrbwalker:CanAttack(function(args) canAttack(args) end)
gsoOrbwalker:OnIssue(function(issue) print(checkIssue(issue)) end)
gsoOrbwalker:OnEnemyHeroLoad(function(heroName) localMenu.useon:MenuElement({id = heroName, name = heroName, value = true}) end) 
gsoOrbwalker:EnableMove(false)
gsoOrbwalker:EnableAttack(false)
gsoOrbwalker:EnableOrb(false)
gsoOrbwalker:ResetAttack()
gsoOrbwalker:MinionHealthPrediction(minionHealth, minionHandle, time)
gsoOrbwalker:GetTarget(range, sourcePos, customEnemyHeroes, dmgType, bb, jaxE)
gsoOrbwalker:CalculateDamage(unit, spellData)
gsoOrbwalker:HeroIsValid(unit)
gsoOrbwalker:CursorPositionChanged(action, pos)
gsoOrbwalker:GetEnemyHeroes(range, sourcePos, bb, jaxE)
gsoOrbwalker:GetAutoAttackRange(attacker, defender) ( added support for minions and turrets )
gsoOrbwalker:RegisterMenuKey(mode, key)
gsoOrbwalker.Mode.isCombo()
gsoOrbwalker.Mode.isHarass()
gsoOrbwalker.Mode.isLastHit()
gsoOrbwalker.Mode.isLaneClear()
gsoOrbwalker.Timers.lastAttackSend
gsoOrbwalker.Timers.lastMoveSend
gsoOrbwalker.Timers.secondsToAttack
gsoOrbwalker.Timers.secondsToMove
gsoOrbwalker.Timers.windUpTime
gsoOrbwalker.Timers.animationTime
gsoOrbwalker.State.isAttacking
gsoOrbwalker.State.isMoving
gsoOrbwalker.State.isEvading
gsoOrbwalker.State.isChangingCursorPos
gsoOrbwalker.State.isBlindedByTeemo
gsoOrbwalker.State.canAttack
gsoOrbwalker.State.canMove
gsoOrbwalker.State.enabledAttack
gsoOrbwalker.State.enabledMove
gsoOrbwalker.State.enabledOrb
gsoOrbwalker.Extra.lastMovePos
gsoOrbwalker.Extra.maxLatency
gsoOrbwalker.Extra.minLatency
gsoOrbwalker.Extra.lastTarget
gsoOrbwalker.Extra.selectedTarget
gsoOrbwalker.Extra.allyTeam
gsoOrbwalker.Extra.attackSpeed
gsoOrbwalker.Extra.baseAttackSpeed
gsoOrbwalker.Extra.baseWindUp
gsoOrbwalker.Farm.allyActiveAttacks
gsoOrbwalker.Farm.allyActiveAttacks.Canceled
gsoOrbwalker.Farm.allyActiveAttacks.Ally
gsoOrbwalker.Farm.allyActiveAttacks.Ally.Handle
gsoOrbwalker.Farm.allyActiveAttacks.Ally.Minion
gsoOrbwalker.Farm.allyActiveAttacks.Ally.AAData
gsoOrbwalker.Farm.allyActiveAttacks.Ally.Dmg
gsoOrbwalker.Farm.allyActiveAttacks.Ally.Pos
gsoOrbwalker.Farm.allyActiveAttacks.Ally.Path
gsoOrbwalker.Farm.allyActiveAttacks.Speed
gsoOrbwalker.Farm.allyActiveAttacks.StartTime
gsoOrbwalker.Farm.allyActiveAttacks.FlyTime
gsoOrbwalker.Farm.allyActiveAttacks.Pos
gsoOrbwalker.Farm.allyActiveAttacks.Dmg
gsoOrbwalker.Farm.allyActiveAttacks.Enemy
gsoOrbwalker.Farm.allyActiveAttacks.Enemy.Handle
gsoOrbwalker.Farm.allyActiveAttacks.Enemy.Minion
gsoOrbwalker.Farm.allyActiveAttacks.Enemy.Path
gsoOrbwalker.Farm.allyActiveAttacks.Enemy.Pos
gsoOrbwalker.Farm.allyActiveAttacks.Enemy.DmgRed
gsoOrbwalker.Farm.allyActiveAttacks.Enemy.Health
gsoOrbwalker.Farm.lastHitable
gsoOrbwalker.Farm.lastHitable.Minion
gsoOrbwalker.Farm.lastHitable.pos
gsoOrbwalker.Farm.lastHitable.health
gsoOrbwalker.Farm.almostLastHitable
gsoOrbwalker.Farm.almostLastHitable.Minion
gsoOrbwalker.Farm.almostLastHitable.pos
gsoOrbwalker.Farm.almostLastHitable.health
gsoOrbwalker.Farm.laneClearable
gsoOrbwalker.Farm.laneClearable.Minion
gsoOrbwalker.Farm.laneClearable.pos
gsoOrbwalker.Farm.laneClearable.health

DETAILS:
local gsoOrbwalker = nil
function OnLoad()
        gsoOrbwalker = __gsoOrbwalker()
        gsoOrbwalker -> class
            :CanChangeAnimationTime(function() return canChangeAnimationTime() end) -> event ( after spell that increase attack speed. Ashe Q, Tristana Q etc. )
            :BonusDamageOnMinion(function() return bonusDamageOnMinion() end) -> event
            :BonusDamageOnMinion2(function(args) return bonusDamageOnMinion2(args) end) -> event
            :AttackSpeed(function() return attackSpeed() end) -> event ( after buff end time that increase attack speed. Ashe Q, Tristana Q etc. )
            :OnMove(function(args) onMove(args) end) -> event
            :OnAttack(function(args) onAttack(args) end) -> event
            :CanMove(function(args) canMove(args) end) -> event
            :CanAttack(function(args) canAttack(args) end) -> event
            :OnIssue(function(issue) print(checkIssue(issue)) end) -> event (on send key: attack | move)
            :OnEnemyHeroLoad(function(heroName) localMenu.useon:MenuElement({id = heroName, name = heroName, value = true}) end) -> event (don't need 2xF6 works perfect)
            :EnableMove(false) -> function
            :EnableAttack(false) -> function
            :EnableOrb(false) -> function
            :ResetAttack() -> function
            :MinionHealthPrediction(minionHealth, minionHandle, time) -> function, return number, predicted enemy minion health - very accurate, for enemy minions only
            :GetTarget(range, sourcePos, customEnemyHeroes, dmgType, bb, jaxE) -> function, return unit or nil
                  ( dmType -> string "ap" or "ad" )
                  ( bb -> boolean add enemies boundingRadius to range ? )
                  ( jaxE -> boolean, jaxE isImmortal ? )
                  ( customEnemyHeroes -> list with enemy heroes or nil )
            :CalculateDamage(unit, spellData) -> function, return number
                  ( spellData: { dmgType = "ap" or "ad" or "mixed" or "true", dmgTrue = number, dmgAP = number, dmgAD = number } )
            :HeroIsValid(unit, jaxE) -> function, return boolean, included custom isImmortal, for enemy heroes only
                  ( jaxE -> boolean, jaxE isImmortal ? )
            :CursorPositionChanged(action, pos) -> function, void, use after cursor position changed - for example: botrk, ezreal q
                  ( action: { endTime = GetTickCount() + 50, action = function() Control.SetCursorPos(cPos.x, cPos.y) end, active = true }(cPos - cursorPos before spell cast) )
                  ( pos: castpos as Vector )
            :GetEnemyHeroes(range, sourcePos, bb, jaxE) -> function, return list {...}
            :GetAutoAttackRange(attacker, defender) -> function, return number, added support for minions and turrets
            :RegisterMenuKey(mode, key) -> function, void
                  ( mode: "combo" or "harass" or "lasthit" or "laneclear" )
                  ( key: menu.keys.combo, ... )
                  EXAMPLE:
                        gsoMenu.orb.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
                        gsoOrbwalker:RegisterMenuKey("combo", gsoMenu.orb.keys.combo)
            .Mode -> list
                    .isCombo() -> function, return boolean
                    .isHarass() -> function, return boolean
                    .isLastHit() -> function, return boolean
                    .isLaneClear() -> function, return boolean
            .Timers -> list
                    .lastAttackSend -> seconds
                    .lastMoveSend -> seconds
                    .secondsToAttack -> seconds
                    .secondsToMove -> seconds
                    .windUpTime -> seconds
                    .animationTime -> seconds
            .State -> list
                    .isAttacking -> boolean
                    .isMoving -> boolean
                    .isEvading -> boolean
                    .isChangingCursorPos -> boolean : check this before casting spell that change cursor position
                    .isBlindedByTeemo -> boolean
                    .canAttack -> boolean
                    .canMove -> boolean
                    .enabledAttack -> boolean
                    .enabledMove -> boolean
                    .enabledOrb -> boolean
            .Extra -> list
                    .lastMovePos -> Vector
                    .maxLatency -> seconds
                    .minLatency -> seconds
                    .lastTarget -> unit or nil
                    .selectedTarget -> unit or nil
                    .allyTeam -> 100 or 200
                    .attackSpeed -> 2.5 if maximum attack speed
                    .baseAttackSpeed
                    .baseWindUp
            .Farm -> list
                    .allyActiveAttacks -> list
                            .Canceled -> boolean
                            .Ally -> list,
                                    .Handle -> number
                                    .Minion -> unit
                                    .AAData -> list (unit.attackData)
                                    .Dmg -> number
                                    .Pos -> Vector
                                    .Path -> list (unit.pathing)
                            Only if Canceled == false:
                            .Speed -> number
                            .StartTime -> number
                            .FlyTime -> seconds
                            .Pos -> Vector
                            .Dmg -> number
                            .Enemy -> list
                                    .Handle -> number
                                    .Minion -> unit
                                    .Path -> list (unit.pathing)
                                    .Pos -> Vector
                                    .DmgRed -> number
                                    .Health -> number
                    .lastHitable -> list
                            .Minion -> unit
                            .pos -> Vector
                            .health -> predicted health
                    .almostLastHitable -> list
                            .Minion -> unit
                            .pos -> Vector
                            .health -> predicted health
                    .laneClearable -> list
                            .Minion -> unit
                            .pos -> Vector
                            .health -> predicted health
end
]]


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






local gsoLatencies = {}
local gsoDelayedActions = {}
local gsoEnemyHeroesNames = {}
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
local gsoShouldWaitT = 0
local gsoShouldWait = false
local gsoResetAttack = false
local gsoComboKeys = {}
local gsoHarassKeys = {}
local gsoLastHitKeys = {}
local gsoLaneClearKeys = {}





local gsoMenu = MenuElement({name = "Gamsteron Orbwalker", id = "gamsteronorb", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orbbb.png" })
local gsoMode = {
    isCombo = function()
                  for i = 1, #gsoComboKeys do
                      if gsoComboKeys[i]:Value() then
                          return true
                      end
                  end
                  return false
              end,
    isHarass = function()
                  for i = 1, #gsoHarassKeys do
                      if gsoHarassKeys[i]:Value() then
                          return true
                      end
                  end
                  return false
              end,
    isLastHit = function()
                  for i = 1, #gsoLastHitKeys do
                      if gsoLastHitKeys[i]:Value() then
                          return true
                      end
                  end
                  return false
              end,
    isLaneClear = function()
                  for i = 1, #gsoLaneClearKeys do
                      if gsoLaneClearKeys[i]:Value() then
                          return true
                      end
                  end
                  return false
              end
}
local gsoTimers = { lastAttackSend = 0, lastMoveSend = 0, secondsToAttack = 0, secondsToMove = 0, windUpTime = 0, animationTime = 0 }
local gsoState = { isAttacking = false, isMoving = false, isEvading = false, isChangingCursorPos = false, isBlindedByTeemo = false, canAttack = true, canMove = true, enabledAttack = true, enabledMove = true, enabledOrb = true }
local gsoExtra = { lastMovePos = myHero.pos, maxLatency = Game.Latency() * 0.001, minLatency = Game.Latency() * 0.001, lastTarget = nil, selectedTarget = nil, allyTeam = myHero.team, attackSpeed = 0, baseAttackSpeed = 0, baseWindUp = 0 }
local gsoFarm = { allyActiveAttacks = {}, lastHitable = {}, almostLastHitable = {}, laneClearable = {} }





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
local gsoIcons = {
    ["orb"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orb.png",
    ["ts"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ts.png"
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
local gsoCanChangeAnim = {}
local gsoLoadHeroesToMenu = {}
local gsoOnIssue = {}
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

local function gsoPredPos(ms, speed, projectilePos, enemyPos, enemyPath)
    if enemyPath.hasMovePath then
        local pPos    = projectilePos
        local uPos    = enemyPos
        local ePos    = enemyPath.endPos
        local distUP  = gsoDistance(pPos, uPos)
        local distEP  = gsoDistance(pPos, ePos)
        if distEP > distUP then
            return uPos:Extended(ePos, 25+(ms*(distUP / (speed - ms))))
        else
            return uPos:Extended(ePos, 25+(ms*(distUP / (speed + ms))))
        end
    end
    return enemyPos
end

local function gsoHasBuff(unit, bName)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == bName then
            return true
        end
    end
    return false
end

local function gsoGetAttackRange(attacker, defender)
    if not attacker then return -1 end
    local name = attacker.charName:lower()
    if name:find("sruap_turret_") then
        return 900
    else
        local range = 0
        if name:find("sru_") and name:find("minion") then
            if name:find("siege") then
                range = 300
            elseif name:find("ranged") then
                range = 550
            elseif name:find("melee") then
                range = 110
            elseif name:find("super") then
                range = 170
            end
        end
        range = range == 0 and attacker.range or range
        if name == "caitlyn" then
            range = range + (gsoHasBuff(attacker, "caitlynyordletrapinternal") and 650 or 0)
        end
        return range + attacker.boundingRadius + (defender and defender.boundingRadius or 30)
    end
end

local function gsoRegisterMenuKey(mode, key)
    mode = mode:lower()
    if mode == "combo" then
        gsoComboKeys[#gsoComboKeys+1] = key
    elseif mode == "harass" then
        gsoHarassKeys[#gsoHarassKeys+1] = key
    elseif mode == "lasthit" then
        gsoLastHitKeys[#gsoLastHitKeys+1] = key
    elseif mode == "laneclear" then
        gsoLaneClearKeys[#gsoLaneClearKeys+1] = key
    end
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





local function gsoGetTarget(range, sourcePos, customEnemyHeroes, dmgType, bb, jaxE)
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
    local enemyHeroes = customEnemyHeroes and customEnemyHeroes or gsoGetEnemyHeroes(range, sourcePos, bb, jaxE)
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
        local minion = lastHitable[i]
        if gsoDistance(sourcePos, minion.pos) < meRange + 25 and minion.health < min then
            min = minion.health
            result = minion.Minion
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
    return gsoGetTarget(gsoMyHero.range + gsoMyHero.boundingRadius, gsoMyHero.pos, nil, "ad", true, true)
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
                local minion = laneClearable[i]
                if gsoDistance(sourcePos, minion.pos) < meRange + 25 and minion.health < min then
                    min = minion.health
                    result = minion.Minion
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




local function gsoMinionHpPredFast(unitHandle, unitPos, unitHealth, time, allyMinions, enemyHandles)
    for i = 1, #allyMinions do
        local aMin = allyMinions[i]
        local aaData = aMin.AAData
        if aaData.target == unitHandle then
            local allyDmg = aMin.Dmg
            local endT    = aaData.endTime
            local animT   = aaData.animationTime
            local windUpT = aaData.windUpTime
            local pSpeed  = aaData.projectileSpeed
            local pFlyT   = pSpeed > 0 and gsoDistance(aMin.Pos, unitPos) / pSpeed or 0
            local pEndT   = (endT - animT) + pFlyT + windUpT
                  pEndT   = pEndT > gsoGameTimer() and pEndT or pEndT + animT + pFlyT
            while pEndT - gsoGameTimer() < time do
                unitHealth = unitHealth - allyDmg
                pEndT = pEndT + animT + pFlyT
            end
        end
    end
    return unitHealth
end

local function gsoMinionHpPredAccuracy(unitHealth, unitHandle, time)
    for allyID, allyActiveAttacks in pairs(gsoFarm.allyActiveAttacks) do
        for activeAttackID, activeAttack in pairs(gsoFarm.allyActiveAttacks[allyID]) do
            if not activeAttack.Canceled and unitHandle == activeAttack.Enemy.Handle then
                local endTime = activeAttack.StartTime + activeAttack.FlyTime
                if endTime > gsoGameTimer() and endTime - gsoGameTimer() < time then
                    unitHealth = unitHealth - activeAttack.Dmg
                end
            end
        end
    end
    return unitHealth
end



local function ___tickFunc() end

local function championsLoadLogic()
    
    if not gsoLoadedChamps then
        for i = 1, gsoGameHeroCount() do
            local hero = gsoGameHero(i)
            if hero.team ~= gsoExtra.allyTeam then
                local eName = hero.charName
                if eName and #eName > 0 and not gsoMenu.ts.priority[eName] then
                    gsoEnemyHeroesNames[#gsoEnemyHeroesNames+1] = eName
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
            for i = 1, #gsoLoadHeroesToMenu do
                for j = 1, #gsoEnemyHeroesNames do
                    gsoLoadHeroesToMenu[i](gsoEnemyHeroesNames[j])
                end
            end
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


local function minionsLogic()
    
    local allyHandles = {}
    local enemyHandles = {}
    local enemyPaths = {}
    local allyMinionsCache = {}
    local enemyMinionsCache = {}
    local enemyPositions = {}
    local enemyMoveSpeeds = {}
    local allyMinions = gsoGetAllyMinions(2000, gsoMyHero.pos, false)
    local enemyMinions = gsoGetEnemyMinions(2000, gsoMyHero.pos, false)
    
    for i = 1, #allyMinions do
        local minion  = allyMinions[i]
        local handle	= minion.handle
        local aaData	= minion.attackData
        local dmg     = minion.totalDamage * ( 1 + minion.bonusDamagePercent )
        local pos     = minion.pos
        local path    = minion.pathing
        allyHandles[handle] = true
        allyMinionsCache[#allyMinionsCache+1] = { Handle = handle, Minion = minion, AAData = aaData, Dmg = dmg, Pos = pos, Path = path }
    end
    
    for i = 1, #enemyMinions do
        local minion  = enemyMinions[i]
        local handle	= minion.handle
        local path    = minion.pathing
        local pos     = minion.pos
        local dmgRed  = minion.flatDamageReduction
        local ms      = minion.ms
        local health  = minion.health
        enemyHandles[handle] = true
        enemyPaths[handle] = path
        enemyPositions[handle] = pos
        enemyMoveSpeeds[handle] = ms
        enemyMinionsCache[#enemyMinionsCache+1] = { Handle = handle, Minion = minion, Path = path, Pos = pos, DmgRed = dmgRed, Health = health }
    end
    
    for i = 1, #allyMinionsCache do
        local ally = allyMinionsCache[i]
        if ally.AAData.endTime > gsoGameTimer() then
            for j = 1, #enemyMinionsCache do
                local enemy = enemyMinionsCache[j]
                if enemy.Handle == ally.AAData.target then
                    local flyTime = ally.AAData.projectileSpeed > 0 and gsoDistance(ally.Pos, enemy.Pos) / ally.AAData.projectileSpeed or 0
                    if not gsoFarm.allyActiveAttacks[ally.Handle] then gsoFarm.allyActiveAttacks[ally.Handle] = {} end
                    if gsoGameTimer() < (ally.AAData.endTime - ally.AAData.windDownTime) + flyTime then
                        if ally.AAData.projectileSpeed > 0 then
                            if gsoGameTimer() > (ally.AAData.endTime - ally.AAData.windDownTime) then
                                if not gsoFarm.allyActiveAttacks[ally.Handle][ally.AAData.endTime] then
                                    gsoFarm.allyActiveAttacks[ally.Handle][ally.AAData.endTime] = {
                                        Canceled  = false,
                                        Speed     = ally.AAData.projectileSpeed,
                                        StartTime = ally.AAData.endTime - ally.AAData.windDownTime,
                                        FlyTime   = ally.AAData.projectileSpeed > 0 and gsoDistance(ally.Pos, enemy.Pos) / ally.AAData.projectileSpeed or 0,
                                        Pos       = ally.Pos:Extended( enemy.Pos, ally.AAData.projectileSpeed * ( gsoGameTimer() - ( ally.AAData.endTime - ally.AAData.windDownTime ) ) ),
                                        Ally      = ally,
                                        Enemy     = enemy,
                                        Dmg       = ally.Dmg - enemy.DmgRed
                                    }
                                end
                            elseif ally.Path.hasMovePath then
                              gsoFarm.allyActiveAttacks[ally.Handle][ally.AAData.endTime] = {
                                  Canceled  = true,
                                  Ally      = ally
                              }
                            end
                          elseif not gsoFarm.allyActiveAttacks[ally.Handle][ally.AAData.endTime] then
                              gsoFarm.allyActiveAttacks[ally.Handle][ally.AAData.endTime] = {
                                  Canceled  = false,
                                  Speed     = ally.AAData.projectileSpeed,
                                  StartTime = (ally.AAData.endTime - ally.AAData.windDownTime) - ally.AAData.windUpTime,
                                  FlyTime   = ally.AAData.windUpTime,
                                  Pos       = ally.Pos,
                                  Ally      = ally,
                                  Enemy     = enemy,
                                  Dmg       = ally.Dmg - enemy.DmgRed
                              }
                          end
                    end
                    break
                end
            end
        end
    end
    
    for allyID, allyActiveAttacks in pairs(gsoFarm.allyActiveAttacks) do
        local count = 0
        for activeAttackID, activeAttack in pairs(gsoFarm.allyActiveAttacks[allyID]) do
            count = count + 1
            local noAlly = not activeAttack.Ally.Minion or activeAttack.Ally.Minion.dead or not allyHandles[activeAttack.Ally.Handle]
            if activeAttack.Speed == 0 and noAlly then
                gsoFarm.allyActiveAttacks[allyID] = nil
                break
            end
            if not activeAttack.Canceled then
                local canContinue = true
                if not enemyHandles[activeAttack.Enemy.Handle] then
                    gsoFarm.allyActiveAttacks[allyID][activeAttackID] = nil
                    canContinue = false
                end
                if canContinue then
                    local enemyPos, enemyPath, enemyMS
                    local ranged = activeAttack.Speed > 0
                    if ranged then
                        enemyPos = enemyPositions[activeAttack.Enemy.Handle]
                        enemyPath = enemyPaths[activeAttack.Enemy.Handle]
                        enemyMS = enemyMoveSpeeds[activeAttack.Enemy.Handle]
                        gsoFarm.allyActiveAttacks[allyID][activeAttackID].FlyTime = gsoDistance(activeAttack.Ally.Pos, gsoPredPos(enemyMS, activeAttack.Speed, activeAttack.Pos, enemyPos, enemyPath)) / activeAttack.Speed
                    end
                    local projectileOnEnemy = gsoExtra.maxLatency + 0.02
                    local noEnemy = not activeAttack.Enemy.Minion or activeAttack.Enemy.Minion.dead or not enemyHandles[activeAttack.Enemy.Handle]
                    if gsoGameTimer() > activeAttack.StartTime + gsoFarm.allyActiveAttacks[allyID][activeAttackID].FlyTime - projectileOnEnemy or noEnemy then
                        gsoFarm.allyActiveAttacks[allyID][activeAttackID] = nil
                    elseif ranged then
                        local s = ( gsoGameTimer() - activeAttack.StartTime ) * activeAttack.Speed
                        gsoFarm.allyActiveAttacks[allyID][activeAttackID].Pos = activeAttack.Ally.Pos:Extended(enemyPos, s)
                    end
                end
            end
        end
        if count == 0 then
            gsoFarm.allyActiveAttacks[allyID] = nil
        end
    end
    
    
    if gsoShouldWait and gsoGameTimer() > gsoShouldWaitT + 0.5 then
        gsoShouldWait = false
    end
    
    local sourcePos, sourceRange, mLH, aaData, projSpeed, windUp, anim, meDmg
    if #enemyMinions > 0 then
        sourcePos = gsoMyHero.pos
        sourceRange = gsoMyHero.range + gsoMyHero.boundingRadius
        mLH = gsoMenu.orb.delays.lhDelay:Value() * 0.001
        aaData = gsoMyHero.attackData
        projSpeed = aaData.projectileSpeed
        windUp = aaData.windUpTime + gsoExtra.minLatency + 0.05 - mLH
        anim = aaData.animationTime
        meDmg = myHero.totalDamage + gsoBonusDmg()
    end
    
    local lastHitable = {}
    local almostLastHitable = {}
    local laneClearable = {}
    for i = 1, #enemyMinionsCache do
        local enemy = enemyMinionsCache[i]
        local minionHandle = enemy.Handle
        local minionPos = enemy.Pos
        local minionHealth = enemy.Health
        local flyTime = windUp + ( gsoDistance(sourcePos, minionPos) / projSpeed )
        local accuracyHpPred = gsoMinionHpPredAccuracy(minionHealth, minionHandle, flyTime)
        if accuracyHpPred < 0 then
            local args = { Minion = enemy.Minion }
            for i = 1, #gsoUnkillableMinion do
                local action = gsoUnkillableMinion[i](args)
            end
        end
        local dmgOnMinion = meDmg + gsoBonusDmgUnit(enemy.Minion)
        if accuracyHpPred - dmgOnMinion <= 0 then
            lastHitable[#lastHitable+1] = { Minion = enemy.Minion, pos = minionPos, health = accuracyHpPred }
        else
            if gsoMinionHpPredFast(minionHandle, minionPos, minionHealth, anim*3, allyMinionsCache, enemyHandles) - dmgOnMinion < 0 then
                gsoShouldWait = true
                gsoShouldWaitT = gsoGameTimer()
                almostLastHitable[#almostLastHitable+1] = enemy.Minion
            else
                laneClearable[#laneClearable+1] = { Minion = enemy.Minion, pos = minionPos, health = accuracyHpPred }
            end
        end
    end
    
    gsoFarm.lastHitable = lastHitable
    gsoFarm.laneClearable = laneClearable
    gsoFarm.almostLastHitable = almostLastHitable
    
end

local function orbwalkerTimersLogic()
    
    local aSpell = gsoMyHero.activeSpell
    if aSpell and aSpell.valid and aSpell.startTime > gsoServerStart then
        local aSpellName = aSpell.name:lower()
        if not gsoNoAttacks[aSpellName] and (aSpellName:find("attack") or gsoAttacks[aSpellName]) then
            gsoServerStart = aSpell.startTime
            gsoServerWindup = aSpell.windup
            gsoServerAnim = aSpell.animation
        end
    end
    
    local aaSpeed = gsoAttackSpeed() * gsoBaseAASpeed
    local numAS   = aaSpeed >= 2.5 and 2.5 or aaSpeed
    gsoExtra.attackSpeed = numAS
    local animT   = 1 / numAS
    local windUpT = animT * gsoBaseWindUp
    
    gsoServerAnim = aaSpeed >= 2.5 and animT or gsoServerAnim
    gsoServerWindup = aaSpeed >= 2.5 and windUpT or gsoServerWindup
    
    local extraWindUp = math.abs(windUpT-gsoServerWindup) + (gsoMenu.orb.delays.windup:Value() * 0.001)
    local windUpAA = windUpT > gsoServerWindup and gsoServerWindup or windUpT
    
    gsoTimers.windUpTime = windUpT > gsoServerWindup and windUpT or gsoServerWindup
    gsoTimers.animationTime = animT > gsoServerAnim and animT or gsoServerAnim
    for i = 1, #gsoCanChangeAnim do
        if gsoCanChangeAnim[i] then
            gsoTimers.animationTime = animT
            break
        end
    end
    
    local sToAA = ( ( gsoServerStart - windUpAA ) + ( gsoTimers.animationTime - ( gsoExtra.minLatency - 0.05 ) ) ) - gsoGameTimer()
    local sToMove = ( ( gsoServerStart + extraWindUp ) - ( gsoExtra.minLatency * 0.5 ) ) - gsoGameTimer()
    local isChatOpen = gsoGameIsChatOpen()
    gsoTimers.secondsToAttack = sToAA > 0 and sToAA or 0
    gsoTimers.secondsToMove = sToMove > 0 and sToMove or 0
    gsoState.isEvading = ExtLibEvade and ExtLibEvade.Evading
    local canMove = gsoGameTimer() > gsoTimers.lastAttackSend + gsoTimers.windUpTime + gsoExtra.minLatency + 0.005 + extraWindUp
    gsoState.canAttack = not gsoState.isChangingCursorPos and not gsoState.isBlindedByTeemo and not gsoState.isEvading and gsoState.enabledAttack and (gsoTimers.secondsToAttack == 0 or gsoResetAttack) and not isChatOpen and canMove
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
    
    local aaTarget = nil
    if gsoMode.isCombo() or gsoMode.isHarass() or gsoMode.isLastHit() or gsoMode.isLaneClear() then
        if gsoBaseAASpeed == 0 then
            gsoBaseAASpeed  = 1 / gsoMyHero.attackData.animationTime / gsoMyHero.attackSpeed
            gsoExtra.baseAttackSpeed = gsoBaseAASpeed
        end
        if gsoBaseWindUp == 0 then
            gsoBaseWindUp = gsoMyHero.attackData.windUpTime / gsoMyHero.attackData.animationTime
            gsoExtra.baseWindUp = gsoBaseWindUp
        end
        if gsoMode.isCombo() then
            aaTarget = gsoGetComboTarget()
        elseif gsoMode.isHarass() then
            aaTarget = gsoGetHarassTarget()
        elseif gsoMode.isLastHit() then
            aaTarget = gsoGetLastHitTarget()
        elseif gsoMode.isLaneClear() then
            aaTarget = gsoGetLaneClearTarget()
        end
    elseif not gsoState.isChangingCursorPos and gsoGetTickCount() < gsoLastKey + 1000 then
        gsoControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
        gsoLastKey = 0
    end
    
    if gsoMode.isCombo() or gsoMode.isHarass() or gsoMode.isLastHit() or gsoMode.isLaneClear() then
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
                tPos = Vector({x=tPos.x,z=tPos.z,y=tPos.y+40})
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
                gsoResetAttack = false
                for i = 1, #gsoOnIssue do
                    gsoOnIssue[i]({move=false,attack=true})
                end
            end
        elseif gsoState.canMove then
            if ExtLibEvade and ExtLibEvade.Evading then
                gsoState.isMoving = true
                gsoState.isAttacking = false
                gsoState.isEvading = true
                return
            end
            local canMove = true
            local args = { Process = true, Target = aaTarget }
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
                for i = 1, #gsoOnIssue do
                    gsoOnIssue[i]({move=true,attack=false})
                end
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
    
    if not gsoState.enabledOrb or gsoMyHero.dead then return end
    
    championsLoadLogic()
    cursorPosLogic()
    delayedActionsLogic()
    latencyLogic()
    teemoBlindLogic()
    minionsLogic()
    orbwalkerTimersLogic()
    orbwalkerLogic()
    
end








function OnLoad()
    gsoMenu:MenuElement({name = "Target Selector", id = "ts", type = MENU, leftIcon = gsoIcons["ts"] })
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
    gsoMenu:MenuElement({name = "Orbwalker", id = "orb", type = MENU, leftIcon = gsoIcons["orb"] })
        gsoMenu.orb:MenuElement({name = "Delays", id = "delays", type = MENU})
            gsoMenu.orb.delays:MenuElement({name = "Extra Kite Delay", id = "windup", value = 0, min = 0, max = 25, step = 1 })
            gsoMenu.orb.delays:MenuElement({name = "Extra LastHit Delay", id = "lhDelay", value = 0, min = 0, max = 50, step = 1 })
            gsoMenu.orb.delays:MenuElement({name = "Extra Move Delay", id = "humanizer", value = 200, min = 120, max = 300, step = 10 })
        gsoMenu.orb:MenuElement({name = "Keys", id = "keys", type = MENU})
            gsoMenu.orb.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
            gsoRegisterMenuKey("combo", gsoMenu.orb.keys.combo)
            gsoMenu.orb.keys:MenuElement({name = "Harass Key", id = "harass", key = string.byte("C")})
            gsoRegisterMenuKey("harass", gsoMenu.orb.keys.harass)
            gsoMenu.orb.keys:MenuElement({name = "LastHit Key", id = "lasthit", key = string.byte("X")})
            gsoRegisterMenuKey("lasthit", gsoMenu.orb.keys.lasthit)
            gsoMenu.orb.keys:MenuElement({name = "LaneClear Key", id = "laneclear", key = string.byte("V")})
            gsoRegisterMenuKey("laneclear", gsoMenu.orb.keys.laneclear)
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
    print("Gamsteron Orb "..gsoVersion.." | loaded!")
end





function OnDraw()
    if not gsoMenu.orb.draw.enable:Value() or not gsoState.enabledOrb or gsoMyHero.dead then return end
    
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
        local minion = lastHitable[i]
        gsoDrawCircle(minion.pos, 50, 3, gsoDrawColor(150, 255, 255, 255))
    end
    
    local almostLastHitable = gsoFarm.almostLastHitable
    for i = 1, #almostLastHitable do
        local minion = almostLastHitable[i]
        gsoDrawCircle(minion.pos, 50, 3, gsoDrawColor(150, 239, 159, 55))
    end
    
end











function OnWndMsg(msg, wParam)
    
    if not gsoState.enabledOrb or gsoMyHero.dead then return end
    
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









class "__gsoOrbwalker"
    function __gsoOrbwalker:__init()
        self.Menu = gsoMenu
        self.Mode = gsoMode
        self.Timers = gsoTimers
        self.State = gsoState
        self.Extra = gsoExtra
        self.Farm = gsoFarm
        Callback.Add('Tick', function() self:tick() end)
    end
    function __gsoOrbwalker:tick()
        self.Timers = gsoTimers
        self.State = gsoState
        self.Extra = gsoExtra
        self.Farm = gsoFarm
    end
    function __gsoOrbwalker:CanChangeAnimationTime(func)
        gsoCanChangeAnim[#gsoCanChangeAnim+1] = func
    end
    function __gsoOrbwalker:BonusDamageOnMinion(func)
        gsoBonusDmg = func
    end
    function __gsoOrbwalker:BonusDamageOnMinion2(func)
        gsoBonusDmgUnit = func
    end
    function __gsoOrbwalker:AttackSpeed(func)
        gsoAttackSpeed = func
    end
    function __gsoOrbwalker:OnMove(func)
        gsoOnMove[#gsoOnMove+1] = func
    end
    function __gsoOrbwalker:OnAttack(func)
        gsoOnAttack[#gsoOnAttack+1] = func
    end
    function __gsoOrbwalker:CanMove(func)
        gsoCanMove[#gsoCanMove+1] = func
    end
    function __gsoOrbwalker:CanAttack(func)
        gsoCanAttack[#gsoCanAttack+1] = func
    end
    function __gsoOrbwalker:OnIssue(func)
        gsoOnIssue[#gsoOnIssue+1] = func
    end
    function __gsoOrbwalker:OnEnemyHeroLoad(func)
        gsoLoadHeroesToMenu[#gsoLoadHeroesToMenu+1] = func
    end
    function __gsoOrbwalker:EnableMove(boolean)
        gsoState.enabledMove = boolean
    end
    function __gsoOrbwalker:EnableAttack(boolean)
        gsoState.enabledAttack = boolean
    end
    function __gsoOrbwalker:EnableOrb(boolean)
        gsoState.enabledOrb = boolean
    end
    function __gsoOrbwalker:ResetAttack()
        gsoResetAttack = true
    end
    function __gsoOrbwalker:MinionHealthPrediction(unitHealth, unitHandle, time)
        return gsoMinionHpPredAccuracy(unitHealth, unitHandle, time)
    end
    function __gsoOrbwalker:GetTarget(range, sourcePos, customEnemyHeroes, dmgType, bb, jaxE)
        return gsoGetTarget(range, sourcePos, customEnemyHeroes, dmgType, bb, jaxE)
    end
    function __gsoOrbwalker:CalculateDamage(unit, spellData)
        return gsoCalculateDmg(unit, spellData)
    end
    function __gsoOrbwalker:HeroIsValid(unit, jaxE)
        return gsoValid(unit) and not gsoIsImmortal(unit, jaxE)
    end
    function __gsoOrbwalker:CursorPositionChanged(action, pos)
        gsoSetCursorPos = action
        gsoState.isChangingCursorPos = true
        gsoExtraSetCursor = pos
    end
    function __gsoOrbwalker:GetEnemyHeroes(range, sourcePos, bb, jaxE)
        return gsoGetEnemyHeroes(range, sourcePos, bb, jaxE)
    end
    function __gsoOrbwalker:GetAutoAttackRange(attacker, defender)
        return gsoGetAttackRange(attacker, defender)
    end
    function __gsoOrbwalker:RegisterMenuKey(mode, key)
        gsoRegisterMenuKey(mode, key)
    end
    function __gsoOrbwalker:OnUnkillableMinion(func)
        gsoUnkillableMinion[#gsoUnkillableMinion+1] = func
    end
