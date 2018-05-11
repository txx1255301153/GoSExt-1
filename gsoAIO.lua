--[[
▒█░░░ ▒█▀▀▀█ ▒█▀▀█ ░█▀▀█ ▒█░░░ ▒█▀▀▀█ 
▒█░░░ ▒█░░▒█ ▒█░░░ ▒█▄▄█ ▒█░░░ ░▀▀▀▄▄ 
▒█▄▄█ ▒█▄▄▄█ ▒█▄▄█ ▒█░▒█ ▒█▄▄█ ▒█▄▄▄█ 
]]
local gsoSDK = {
      ChampTick = function() end,
      ChampDraw = function() end,
      ChampWndMsg = function(msg, wParam) end,
      Menu = nil,
      Spell = nil,
      Utilities = nil,
      Cursor = nil,
      ObjectManager = nil,
      Farm = nil,
      TS = nil,
      Orbwalker = nil
}
local myHero = myHero
local GetTickCount = GetTickCount
local MathSqrt = math.sqrt
local DrawText = Draw.Text
local GameTimer = Game.Timer
local DrawColor = Draw.Color
local DrawCircle = Draw.Circle
local ControlKeyUp = Control.KeyUp
local ControlKeyDown = Control.KeyDown
local ControlIsKeyDown = Control.IsKeyDown
local ControlMouseEvent = Control.mouse_event
local ControlSetCursorPos = Control.SetCursorPos
local GameCanUseSpell = Game.CanUseSpell
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameMinionCount = Game.MinionCount
local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
local GameIsChatOpen = Game.IsChatOpen
local GameLatency = Game.Latency
--[[
▒█▀▀█ █░░█ █▀▀█ █▀▀ █▀▀█ █▀▀█ 
▒█░░░ █░░█ █▄▄▀ ▀▀█ █░░█ █▄▄▀ 
▒█▄▄█ ░▀▀▀ ▀░▀▀ ▀▀▀ ▀▀▀▀ ▀░▀▀ 
]]
class "__gsoCursor"
      function __gsoCursor:__init()
            self.CursorReady = true
            self.ExtraSetCursor = nil
            self.SetCursorPos = nil
      end
      function __gsoCursor:IsCursorReady()
            if self.CursorReady and not self.SetCursorPos and not self.ExtraSetCursor then
                  return true
            end
            return false
      end
      function __gsoCursor:CreateDrawMenu(menu)
            gsoSDK.Menu.gsodraw:MenuElement({name = "Cursor Pos",  id = "cursor", type = MENU})
                  gsoSDK.Menu.gsodraw.cursor:MenuElement({name = "Enabled",  id = "enabled", value = true})
                  gsoSDK.Menu.gsodraw.cursor:MenuElement({name = "Color",  id = "color", color = DrawColor(255, 153, 0, 76)})
                  gsoSDK.Menu.gsodraw.cursor:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
                  gsoSDK.Menu.gsodraw.cursor:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
      end
      function __gsoCursor:SetCursor(cPos, castPos, delay)
            self.ExtraSetCursor = castPos
            self.CursorReady = false
            self.SetCursorPos = { EndTime = GameTimer() + delay, Action = function() ControlSetCursorPos(cPos.x, cPos.y) end, Active = true }
      end
      function __gsoCursor:Tick()
            if self.SetCursorPos then
                  if self.SetCursorPos.Active and GameTimer() > self.SetCursorPos.EndTime then
                        self.SetCursorPos.Action()
                        self.SetCursorPos.Active = false
                        self.ExtraSetCursor = nil
                  elseif not self.SetCursorPos.Active and GameTimer() > self.SetCursorPos.EndTime + 0.025 then
                        self.CursorReady = true
                        self.SetCursorPos = nil
                  end
            end
            if self.ExtraSetCursor then
                  ControlSetCursorPos(self.ExtraSetCursor)
            end
      end
      function __gsoCursor:Draw()
            if gsoSDK.Menu.gsodraw.cursor.enabled:Value() then
                  DrawCircle(mousePos, gsoSDK.Menu.gsodraw.cursor.radius:Value(), gsoSDK.Menu.gsodraw.cursor.width:Value(), gsoSDK.Menu.gsodraw.cursor.color:Value())
            end
      end
--[[
▒█▀▀▀ █▀▀█ █▀▀█ █▀▄▀█ 
▒█▀▀▀ █▄▄█ █▄▄▀ █░▀░█ 
▒█░░░ ▀░░▀ ▀░▀▀ ▀░░░▀ 
]]
class "__gsoFarm"
      function __gsoFarm:__init()
            self.ActiveAttacks = {}
            self.ShouldWait = false
            self.ShouldWaitTime = 0
            self.IsLastHitable = false
      end
      function __gsoFarm:PredPos(speed, pPos, unit)
            if unit.pathing.hasMovePath then
                  local uPos = unit.pos
                  local ePos = unit.pathing.endPos
                  local distUP = pPos:DistanceTo(uPos)
                  local distEP = pPos:DistanceTo(ePos)
                  local unitMS = unit.ms
                  if distEP > distUP then
                        return uPos:Extended(ePos, 25+(unitMS*(distUP / (speed - unitMS))))
                  else
                        return uPos:Extended(ePos, 25+(unitMS*(distUP / (speed + unitMS))))
                  end
            end
            return unit.pos
      end
      function __gsoFarm:UpdateActiveAttacks()
            for k1, v1 in pairs(self.ActiveAttacks) do
                  local count = 0
                  for k2, v2 in pairs(self.ActiveAttacks[k1]) do
                        count = count + 1
                        if v2.Speed == 0 and (not v2.Ally or v2.Ally.dead) then
                              self.ActiveAttacks[k1] = nil
                              break
                        end
                        if not v2.Canceled then
                              local ranged = v2.Speed > 0
                              if ranged then
                                    self.ActiveAttacks[k1][k2].FlyTime = v2.Ally.pos:DistanceTo(self:PredPos(v2.Speed, v2.Pos, v2.Enemy)) / v2.Speed
                              end
                              local projectileOnEnemy = 0.025 + gsoSDK.Utilities:GetMaxLatency()
                              if GameTimer() > v2.StartTime + self.ActiveAttacks[k1][k2].FlyTime - projectileOnEnemy or not v2.Enemy or v2.Enemy.dead then
                                    self.ActiveAttacks[k1][k2] = nil
                              elseif ranged then
                                    self.ActiveAttacks[k1][k2].Pos = v2.Ally.pos:Extended(v2.Enemy.pos, ( GameTimer() - v2.StartTime ) * v2.Speed)
                              end
                        end
                  end
                  if count == 0 then
                        self.ActiveAttacks[k1] = nil
                  end
            end
      end
      function __gsoFarm:SetLastHitable(enemyMinion, time, damage, mode, allyMinions)
            if mode == "fast" then
                  local hpPred = self:MinionHpPredFast(enemyMinion, allyMinions, time)
                  local lastHitable = hpPred - damage < 0
                  if lastHitable then self.IsLastHitable = true end
                  local almostLastHitable = lastHitable and false or self:MinionHpPredFast(enemyMinion, allyMinions, myHero.attackData.animationTime * 3) - damage < 0
                  if almostLastHitable then
                        self.ShouldWait = true
                        self.ShouldWaitTime = GameTimer()
                  end
                  return { LastHitable =  lastHitable, Unkillable = hpPred < 0, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = enemyMinion }
            elseif mode == "accuracy" then
                  local hpPred = self:MinionHpPredAccuracy(enemyMinion, time)
                  local lastHitable = hpPred - damage < 0
                  if lastHitable then self.IsLastHitable = true end
                  local almostLastHitable = lastHitable and false or self:MinionHpPredFast(enemyMinion, allyMinions, myHero.attackData.animationTime * 3) - damage < 0
                  if almostLastHitable then
                        self.ShouldWait = true
                        self.ShouldWaitTime = GameTimer()
                  end
                  return { LastHitable =  lastHitable, Unkillable = hpPred < 0, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = enemyMinion }
            end
      end
      function __gsoFarm:CanLastHit()
            return self.IsLastHitable
      end
      function __gsoFarm:CanLaneClear()
            return not self.ShouldWait
      end
      function __gsoFarm:CanLaneClearTime()
            local shouldWait = gsoSDK.Menu.ts.shouldwaittime:Value() * 0.001
            return GameTimer() > self.ShouldWaitTime + shouldWait
      end
      function __gsoFarm:MinionHpPredFast(unit, allyMinions, time)
            local unitHandle, unitPos, unitHealth = unit.handle, unit.pos, unit.health
            for i = 1, #allyMinions do
                  local allyMinion = allyMinions[i]
                  if allyMinion.attackData.target == unitHandle then
                        local minionDmg = (allyMinion.totalDamage*(1+allyMinion.bonusDamagePercent))-unit.flatDamageReduction
                        local flyTime = allyMinion.attackData.projectileSpeed > 0 and allyMinion.pos:DistanceTo(unitPos) / allyMinion.attackData.projectileSpeed or 0
                        local endTime = (allyMinion.attackData.endTime - allyMinion.attackData.animationTime) + flyTime + allyMinion.attackData.windUpTime
                        endTime = endTime > GameTimer() and endTime or endTime + allyMinion.attackData.animationTime + flyTime
                        while endTime - GameTimer() < time do
                              unitHealth = unitHealth - minionDmg
                              endTime = endTime + allyMinion.attackData.animationTime + flyTime
                        end
                  end
            end
            return unitHealth
      end
      function __gsoFarm:MinionHpPredAccuracy(unit, time)
            local unitHealth, unitHandle = unit.health, unit.handle
            for allyID, allyActiveAttacks in pairs(self.ActiveAttacks) do
                  for activeAttackID, activeAttack in pairs(self.ActiveAttacks[allyID]) do
                        if not activeAttack.Canceled and unitHandle == activeAttack.Enemy.handle then
                              local endTime = activeAttack.StartTime + activeAttack.FlyTime
                              if endTime > GameTimer() and endTime - GameTimer() < time then
                                    unitHealth = unitHealth - activeAttack.Dmg
                              end
                        end
                  end
            end
            return unitHealth
      end
      function __gsoFarm:Tick(allyMinions, enemyMinions)
            for i = 1, #allyMinions do
                  local allyMinion = allyMinions[i]
                  if allyMinion.attackData.endTime > GameTimer() then
                        for j = 1, #enemyMinions do
                              local enemyMinion = enemyMinions[j]
                              if enemyMinion.handle == allyMinion.attackData.target then
                                    local flyTime = allyMinion.attackData.projectileSpeed > 0 and allyMinion.pos:DistanceTo(enemyMinion.pos) / allyMinion.attackData.projectileSpeed or 0
                                    if not self.ActiveAttacks[allyMinion.handle] then
                                          self.ActiveAttacks[allyMinion.handle] = {}
                                    end
                                    if GameTimer() < (allyMinion.attackData.endTime - allyMinion.attackData.windDownTime) + flyTime then
                                          if allyMinion.attackData.projectileSpeed > 0 then
                                                if GameTimer() > allyMinion.attackData.endTime - allyMinion.attackData.windDownTime then
                                                      if not self.ActiveAttacks[allyMinion.handle][allyMinion.attackData.endTime] then
                                                            self.ActiveAttacks[allyMinion.handle][allyMinion.attackData.endTime] = {
                                                                  Canceled = false,
                                                                  Speed = allyMinion.attackData.projectileSpeed,
                                                                  StartTime = allyMinion.attackData.endTime - allyMinion.attackData.windDownTime,
                                                                  FlyTime = flyTime,
                                                                  Pos = allyMinion.pos:Extended(enemyMinion.pos, allyMinion.attackData.projectileSpeed * ( GameTimer() - ( allyMinion.attackData.endTime - allyMinion.attackData.windDownTime ) ) ),
                                                                  Ally = allyMinion,
                                                                  Enemy = enemyMinion,
                                                                  Dmg = (allyMinion.totalDamage*(1+allyMinion.bonusDamagePercent))-enemyMinion.flatDamageReduction
                                                            }
                                                      end
                                                elseif allyMinion.pathing.hasMovePath then
                                                      self.ActiveAttacks[allyMinion.handle][allyMinion.attackData.endTime] = {
                                                            Canceled = true,
                                                            Ally = allyMinion
                                                      }
                                                end
                                          elseif not self.ActiveAttacks[allyMinion.handle][allyMinion.attackData.endTime] then
                                                self.ActiveAttacks[allyMinion.handle][allyMinion.attackData.endTime] = {
                                                      Canceled = false,
                                                      Speed = allyMinion.attackData.projectileSpeed,
                                                      StartTime = (allyMinion.attackData.endTime - allyMinion.attackData.windDownTime) - allyMinion.attackData.windUpTime,
                                                      FlyTime = allyMinion.attackData.windUpTime,
                                                      Pos = allyMinion.pos,
                                                      Ally = allyMinion,
                                                      Enemy = enemyMinion,
                                                      Dmg = (allyMinion.totalDamage*(1+allyMinion.bonusDamagePercent))-enemyMinion.flatDamageReduction
                                                }
                                          end
                                    end
                                    break
                              end
                        end
                  end
            end
            self:UpdateActiveAttacks()
            self.IsLastHitable = false
            self.ShouldWait = false
      end
--[[
▒█▀▀▀█ █▀▀▄ ░░▀ █▀▀ █▀▀ ▀▀█▀▀ 　 ▒█▀▄▀█ █▀▀█ █▀▀▄ █▀▀█ █▀▀▀ █▀▀ █▀▀█ 
▒█░░▒█ █▀▀▄ ░░█ █▀▀ █░░ ░░█░░ 　 ▒█▒█▒█ █▄▄█ █░░█ █▄▄█ █░▀█ █▀▀ █▄▄▀ 
▒█▄▄▄█ ▀▀▀░ █▄█ ▀▀▀ ▀▀▀ ░░▀░░ 　 ▒█░░▒█ ▀░░▀ ▀░░▀ ▀░░▀ ▀▀▀▀ ▀▀▀ ▀░▀▀ 
]]
class "__gsoOB"
      function __gsoOB:__init()
            self.LastFound = -99999
            self.LoadedChamps = false
            self.AllyHeroes = {}
            self.EnemyHeroes = {}
            self.AllyHeroLoad = {}
            self.EnemyHeroLoad = {}
            self.Units = { EnemyMinions = {} }
            self.UndyingBuffs = { ["zhonyasringshield"] = true }
      end
      function __gsoOB:OnAllyHeroLoad(func)
            self.AllyHeroLoad[#self.AllyHeroLoad+1] = func
      end
      function __gsoOB:OnEnemyHeroLoad(func)
            self.EnemyHeroLoad[#self.EnemyHeroLoad+1] = func
      end
      function __gsoOB:IsUnitValid(unit, range, bb)
            local extraRange = bb and unit.boundingRadius or 0
            if  unit.pos:DistanceTo(myHero.pos) < range + extraRange and not unit.dead and unit.isTargetable and unit.valid and unit.visible then
                  return true
            end
            return false
      end
      function __gsoOB:IsUnitValid_invisible(unit, range, bb)
            local extraRange = bb and unit.boundingRadius or 0
            if  unit.pos:DistanceTo(myHero.pos) < range + extraRange and not unit.dead and unit.isTargetable and unit.valid then
                  return true
            end
            return false
      end
      function __gsoOB:IsHeroImmortal(unit, jaxE)
            local hp = 100 * ( unit.health / unit.maxHealth )
            if self.UndyingBuffs["JaxCounterStrike"] ~= nil then self.UndyingBuffs["JaxCounterStrike"] = jaxE end
            if self.UndyingBuffs["kindredrnodeathbuff"] ~= nil then self.UndyingBuffs["kindredrnodeathbuff"] = hp < 10 end
            if self.UndyingBuffs["UndyingRage"] ~= nil then self.UndyingBuffs["UndyingRage"] = hp < 15 end
            if self.UndyingBuffs["ChronoShift"] ~= nil then self.UndyingBuffs["ChronoShift"] = hp < 15; self.UndyingBuffs["chronorevive"] = hp < 15 end
            for i = 0, unit.buffCount do
                  local buff = unit:GetBuff(i)
                  if buff and buff.count > 0 and self.UndyingBuffs[buff.name] then
                        return true
                  end
            end
            return false
      end
      function __gsoOB:GetAllyHeroes(range, bb)
            local result = {}
            for i = 1, GameHeroCount() do
                  local hero = GameHero(i)
                  if hero and hero.team == myHero.team and self:IsUnitValid(hero, range, bb) then
                        result[#result+1] = hero
                  end
            end
            return result
      end
      function __gsoOB:GetEnemyHeroes(range, bb, state)
            local result = {}
            if state == "spell" then
                  for i = 1, GameHeroCount() do
                        local hero = GameHero(i)
                        if hero and hero.team ~= myHero.team and self:IsUnitValid(hero, range, bb) and not self:IsHeroImmortal(hero, false) then
                              result[#result+1] = hero
                        end
                  end
            elseif state == "attack" then
                  for i = 1, GameHeroCount() do
                        local hero = GameHero(i)
                        if hero and hero.team ~= myHero.team and self:IsUnitValid(hero, range, bb) and not self:IsHeroImmortal(hero, true) then
                              result[#result+1] = hero
                        end
                  end
            elseif state == "immortal" then
                  for i = 1, GameHeroCount() do
                        local hero = GameHero(i)
                        if hero and hero.team ~= myHero.team and self:IsUnitValid(hero, range, bb) then
                              result[#result+1] = hero
                        end
                  end
            elseif state == "spell_invisible" then
                  for i = 1, GameHeroCount() do
                        local hero = GameHero(i)
                        if hero and hero.team ~= myHero.team and self:IsUnitValid_invisible(hero, range, bb) then
                              result[#result+1] = hero
                        end
                  end
            end
            return result
      end
      function __gsoOB:GetAllyTurrets(range, bb)
            local result = {}
            for i = 1, GameTurretCount() do
                  local turret = GameTurret(i)
                  if turret and turret.team == myHero.team and self:IsUnitValid(turret, range, bb)  then
                        result[#result+1] = turret
                  end
            end
            return result
      end
      function __gsoOB:GetEnemyTurrets(range, bb)
            local result = {}
            for i = 1, GameTurretCount() do
                  local turret = GameTurret(i)
                  if turret and turret.team ~= myHero.team and self:IsUnitValid(turret, range, bb) and not turret.isImmortal then
                        result[#result+1] = turret
                  end
            end
            return result
      end
      function __gsoOB:GetAllyMinions(range, bb)
            local result = {}
            for i = 1, GameMinionCount() do
                  local minion = GameMinion(i)
                  if minion and minion.team == myHero.team and self:IsUnitValid(minion, range, bb) then
                        result[#result+1] = minion
                  end
            end
            return result
      end
      function __gsoOB:GetEnemyMinions(range, bb)
            local result = {}
            for i = 1, GameMinionCount() do
                  local minion = GameMinion(i)
                  if minion and minion.team ~= myHero.team and self:IsUnitValid(minion, range, bb) and not minion.isImmortal then
                        result[#result+1] = minion
                  end
            end
            return result
      end
      function __gsoOB:Tick()
            for i = 1, GameHeroCount() do end
            for i = 1, GameTurretCount() do end
            for i = 1, GameMinionCount() do end
            self.Units.EnemyMinions = self:GetEnemyMinions(2000, false)
            if self.LoadedChamps then return end
            for i = 1, GameHeroCount() do
                  local hero = GameHero(i)
                  local eName = hero.charName
                  if eName and #eName > 0 then
                        local isNewHero = true
                        if hero.team ~= myHero.team then
                              for j = 1, #self.EnemyHeroes do
                                    if hero == self.EnemyHeroes[j] then
                                          isNewHero = false
                                          break
                                    end
                              end
                              if isNewHero then
                                    self.EnemyHeroes[#self.EnemyHeroes+1] = hero
                                    self.LastFound = GameTimer()
                                    if eName == "Kayle" then self.UndyingBuffs["JudicatorIntervention"] = true
                                    elseif eName == "Taric" then self.UndyingBuffs["TaricR"] = true
                                    elseif eName == "Kindred" then self.UndyingBuffs["kindredrnodeathbuff"] = true
                                    elseif eName == "Zilean" then self.UndyingBuffs["ChronoShift"] = true; self.UndyingBuffs["chronorevive"] = true
                                    elseif eName == "Tryndamere" then self.UndyingBuffs["UndyingRage"] = true
                                    elseif eName == "Jax" then self.UndyingBuffs["JaxCounterStrike"] = true; gsoIsJax = true
                                    elseif eName == "Fiora" then self.UndyingBuffs["FioraW"] = true
                                    elseif eName == "Aatrox" then self.UndyingBuffs["aatroxpassivedeath"] = true
                                    elseif eName == "Vladimir" then self.UndyingBuffs["VladimirSanguinePool"] = true
                                    elseif eName == "KogMaw" then self.UndyingBuffs["KogMawIcathianSurprise"] = true
                                    elseif eName == "Karthus" then self.UndyingBuffs["KarthusDeathDefiedBuff"] = true
                                    end
                              end
                        else
                              for j = 1, #self.AllyHeroes do
                                    if hero == self.AllyHeroes[j] then
                                          isNewHero = false
                                          break
                                    end
                              end
                              if isNewHero then
                                    self.AllyHeroes[#self.EnemyHeroes+1] = hero
                              end
                        end
                  end
            end
            if GameTimer() > self.LastFound + 2.5 and GameTimer() < self.LastFound + 5 then
                  self.LoadedChamps = true
                  for i = 1, #self.AllyHeroes do
                        for j = 1, #self.AllyHeroLoad do
                              self.AllyHeroLoad[j](self.AllyHeroes[i])
                        end
                  end
                  for i = 1, #self.EnemyHeroes do
                        for j = 1, #self.EnemyHeroLoad do
                              self.EnemyHeroLoad[j](self.EnemyHeroes[i])
                        end
                  end
            end
      end
--[[
▒█▀▀▀█ █▀▀█ █▀▀▄ █░░░█ █▀▀█ █░░ █░█ █▀▀ █▀▀█ 
▒█░░▒█ █▄▄▀ █▀▀▄ █▄█▄█ █▄▄█ █░░ █▀▄ █▀▀ █▄▄▀ 
▒█▄▄▄█ ▀░▀▀ ▀▀▀░ ░▀░▀░ ▀░░▀ ▀▀▀ ▀░▀ ▀▀▀ ▀░▀▀ 
]]
class "__gsoOrbwalker"
      function __gsoOrbwalker:__init()
            self.LoadTime = GameTimer()
            self.IsTeemo = false
            self.IsBlindedByTeemo = false
            self.LastAttackLocal = 0
            self.LastAttackServer = 0
            self.LastMoveLocal = 0
            self.LastMoveTime = 0
            self.LastMouseDown = 0
            self.LastMovePos = myHero.pos
            self.ResetAttack = false
            self.LastTarget = nil
            self.TestCount = 0
            self.TestStartTime = 0
            self.LastAttackDiff = 0
            self.BaseAASpeed = 1 / myHero.attackData.animationTime / myHero.attackSpeed
            self.BaseWindUp = myHero.attackData.windUpTime / myHero.attackData.animationTime
            self.AttackEndTime = myHero.attackData.endTime + 0.1
            self.WindUpTime = myHero.attackData.windUpTime
            self.AnimTime = myHero.attackData.animationTime
            self.OnPreAttackC = {}
            self.OnPostAttackC = {}
            self.OnAttackC = {}
            self.OnPreMoveC = {}
            self.PostAttackBool = false
            self.AttackEnabled = true
            self.MovementEnabled = true
            self.Loaded = false
            self.SpellMoveDelays = { q = 0, w = 0, e = 0, r = 0 }
            self.SpellAttackDelays = { q = 0, w = 0, e = 0, r = 0 }
            gsoSDK.ObjectManager:OnEnemyHeroLoad(function(hero) if hero.charName == "Teemo" then self.IsTeemo = true end end)
            self.CanAttackC = function() return true end
            self.CanMoveC = function() return true end
      end
      function __gsoOrbwalker:CreateMenu()
            gsoSDK.Menu:MenuElement({name = "Orbwalker", id = "orb", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orb.png" })
                  gsoSDK.Menu.orb:MenuElement({name = "Enabled",  id = "enabledorb", tooltip = "Enabled Gamsteron's OnTick and OnDraw - Attack, Move, Draw Attack Range etc.", value = true})
                  gsoSDK.Menu.orb:MenuElement({name = "Keys", id = "keys", type = MENU})
                  gsoSDK.Menu.orb.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
                  gsoSDK.Menu.orb.keys:MenuElement({name = "Harass Key", id = "harass", key = string.byte("C")})
                  gsoSDK.Menu.orb.keys:MenuElement({name = "LastHit Key", id = "lasthit", key = string.byte("X")})
                  gsoSDK.Menu.orb.keys:MenuElement({name = "LaneClear Key", id = "laneclear", key = string.byte("V")})
                  gsoSDK.Menu.orb.keys:MenuElement({name = "Flee Key", id = "flee", key = string.byte("A")})
                  gsoSDK.Menu.orb:MenuElement({name = "Extra WindUp Delay", tooltip = "Less Value = Better KITE", id = "windupdelay", value = 25, min = 0, max = 150, step = 5 })
                  gsoSDK.Menu.orb:MenuElement({name = "Extra Anim Delay", tooltip = "Less Value = Better DPS [ for me 80 is ideal ] - lower value than 80 cause slow KITE ! Maybe for your PC ideal value is 0 ? You need test it in debug mode.", id = "animdelay", value = 80, min = 0, max = 150, step = 10 })
                  gsoSDK.Menu.orb:MenuElement({name = "Extra LastHit Delay", tooltip = "Less Value = Faster Last Hit Reaction", id = "lhDelay", value = 0, min = 0, max = 50, step = 1 })
                  gsoSDK.Menu.orb:MenuElement({name = "Extra Move Delay", tooltip = "Less Value = More Movement Clicks Per Sec", id = "humanizer", value = 200, min = 120, max = 300, step = 10 })
                  gsoSDK.Menu.orb:MenuElement({name = "Debug Mode", tooltip = "Will Print Some Data", id = "enabled", value = false})
      end
      function __gsoOrbwalker:CreateDrawMenu(menu)
            gsoSDK.Menu.gsodraw:MenuElement({name = "MyHero Attack Range", id = "me", type = MENU})
                  gsoSDK.Menu.gsodraw.me:MenuElement({name = "Enabled",  id = "enabled", value = true})
                  gsoSDK.Menu.gsodraw.me:MenuElement({name = "Color",  id = "color", color = DrawColor(150, 49, 210, 0)})
                  gsoSDK.Menu.gsodraw.me:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
            gsoSDK.Menu.gsodraw:MenuElement({name = "Enemy Attack Range", id = "he", type = MENU})
                  gsoSDK.Menu.gsodraw.he:MenuElement({name = "Enabled",  id = "enabled", value = true})
                  gsoSDK.Menu.gsodraw.he:MenuElement({name = "Color",  id = "color", color = DrawColor(150, 255, 0, 0)})
                  gsoSDK.Menu.gsodraw.he:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
      end
      function __gsoOrbwalker:GetAttackSpeed()
            return myHero.attackSpeed
      end
      function __gsoOrbwalker:GetAvgLatency()
            local currentLatency = GameLatency() * 0.001
            local latency = gsoSDK.Utilities:GetMinLatency() + gsoSDK.Utilities:GetMaxLatency() + currentLatency
            return latency / 3
      end
      function __gsoOrbwalker:SetAttackTimers()
            self.BaseAASpeed = 1 / myHero.attackData.animationTime / myHero.attackSpeed
            self.BaseWindUp = myHero.attackData.windUpTime / myHero.attackData.animationTime
            local aaSpeed = self:GetAttackSpeed() * self.BaseAASpeed
            local animT = 1 / aaSpeed
            local windUpT = animT * self.BaseWindUp
            self.AnimTime = animT > myHero.attackData.animationTime and animT or myHero.attackData.animationTime
            self.WindUpTime = windUpT > myHero.attackData.windUpTime and windUpT or myHero.attackData.windUpTime
      end
      function __gsoOrbwalker:CheckTeemoBlind()
            for i = 0, myHero.buffCount do
                  local buff = myHero:GetBuff(i)
                  if buff and buff.count > 0 and buff.name:lower() == "blindingdart" and buff.duration > 0 then
                        return true
                  end
            end
            return false
      end
      function __gsoOrbwalker:IsBeforeAttack(multipier)
            if GameTimer() > self.LastAttackLocal + multipier * self.AnimTime then
                  return true
            else
                  return false
            end
      end
      function __gsoOrbwalker:SetSpellMoveDelays(delays)
            self.SpellMoveDelays = delays
      end
      function __gsoOrbwalker:SetSpellAttackDelays(delays)
            self.SpellAttackDelays = delays
      end
      function __gsoOrbwalker:GetLastMovePos()
            return self.LastMovePos
      end
      function __gsoOrbwalker:ResetMove()
            self.LastMoveLocal = 0
      end
      function __gsoOrbwalker:ResetAttack()
            self.ResetAttack = true
      end
      function __gsoOrbwalker:GetLastTarget()
            return self.LastTarget
      end
      function __gsoOrbwalker:EnableGosOrb()
            if not _G.Orbwalker.Enabled:Value() then _G.Orbwalker.Enabled:Value(true) end
            _G.Orbwalker:Hide(false)
      end
      function __gsoOrbwalker:DisableGosOrb()
            if _G.Orbwalker.Enabled:Value() then _G.Orbwalker.Enabled:Value(false) end
            _G.Orbwalker:Hide(true)
      end
      function __gsoOrbwalker:EnableIcOrb()
            if _G.SDK and _G.SDK.Orbwalker and _G.SDK.Orbwalker.Loaded then
                  if not _G.SDK.Orbwalker.Menu.Enabled:Value() then _G.SDK.Orbwalker.Menu.Enabled:Value(true) end
                  _G.SDK.Orbwalker.Menu:Hide(false)
            end
      end
      function __gsoOrbwalker:DisableIcOrb()
            if _G.SDK and _G.SDK.Orbwalker and _G.SDK.Orbwalker.Loaded then
                  if _G.SDK.Orbwalker.Menu.Enabled:Value() then _G.SDK.Orbwalker.Menu.Enabled:Value(false) end
                  _G.SDK.Orbwalker.Menu:Hide(true)
            end
      end
      function __gsoOrbwalker:ResetAttack()
            self.ResetAttack = true
      end
      function __gsoOrbwalker:SetMovement(boolean)
            self.MovementEnabled = boolean
      end
      function __gsoOrbwalker:SetAttack(boolean)
            self.AttackEnabled = boolean
      end
      function __gsoOrbwalker:OnPreAttack(func)
            self.OnPreAttackC[#self.OnPreAttackC+1] = func
      end
      function __gsoOrbwalker:OnPostAttack(func)
            self.OnPostAttackC[#self.OnPostAttackC+1] = func
      end
      function __gsoOrbwalker:OnAttack(func)
            self.OnAttackC[#self.OnAttackC+1] = func
      end
      function __gsoOrbwalker:OnPreMovement(func)
            self.OnPreMoveC[#self.OnPreMoveC+1] = func
      end
      function __gsoOrbwalker:GetMode()
            if gsoSDK.Menu.orb.keys.combo:Value() then
                  return "Combo"
            elseif gsoSDK.Menu.orb.keys.harass:Value() then
                  return "Harass"
            elseif gsoSDK.Menu.orb.keys.lasthit:Value() then
                  return "Lasthit"
            elseif gsoSDK.Menu.orb.keys.laneclear:Value() then
                  return "Clear"
            elseif gsoSDK.Menu.orb.keys.flee:Value() then
                  return "Flee"
            else
                  return "None"
            end
      end
      function __gsoOrbwalker:WndMsg(msg, wParam)
            if wParam == HK_TCO then
                  self.LastAttackLocal = GameTimer()
            end
      end
      function __gsoOrbwalker:Draw()
            if not gsoSDK.Menu.orb.enabledorb:Value() then return end
            if gsoSDK.Menu.gsodraw.me.enabled:Value() and myHero.pos:ToScreen().onScreen then
                  DrawCircle(myHero.pos, myHero.range + myHero.boundingRadius + 35, gsoSDK.Menu.gsodraw.me.width:Value(), gsoSDK.Menu.gsodraw.me.color:Value())
            end
            if gsoSDK.Menu.gsodraw.he.enabled:Value() then
                  local enemyHeroes = gsoSDK.ObjectManager:GetEnemyHeroes(99999999, false, "immortal")
                  for i = 1, #enemyHeroes do
                        local enemy = enemyHeroes[i]
                        if enemy.pos:ToScreen().onScreen then
                              DrawCircle(enemy.pos, enemy.range + enemy.boundingRadius + 35, gsoSDK.Menu.gsodraw.he.width:Value(), gsoSDK.Menu.gsodraw.he.color:Value())
                        end
                  end
            end
      end
      function __gsoOrbwalker:CanAttackEvent(func)
            self.CanAttackC = func
      end
      function __gsoOrbwalker:CanMoveEvent(func)
            self.CanMoveC = func
      end
      function __gsoOrbwalker:Attack(unit)
            self.ResetAttack = false
            gsoSDK.Cursor:SetCursor(cursorPos, unit.pos, 0.06)
            ControlSetCursorPos(unit.pos)
            ControlKeyDown(HK_TCO)
            ControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
            ControlMouseEvent(MOUSEEVENTF_RIGHTUP)
            ControlKeyUp(HK_TCO)
            self.LastMoveLocal = 0
            self.LastAttackLocal  = GameTimer()
            self.LastTarget = unit
      end
      function __gsoOrbwalker:Move()
            if ControlIsKeyDown(2) then self.LastMouseDown = GameTimer() end
            self.LastMovePos = mousePos
            ControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
            ControlMouseEvent(MOUSEEVENTF_RIGHTUP)
            self.LastMoveLocal = GameTimer() + gsoSDK.Menu.orb.humanizer:Value() * 0.001
            self.LastMoveTime = GameTimer()
      end
      function __gsoOrbwalker:MoveToPos(pos)
            if ControlIsKeyDown(2) then self.LastMouseDown = GameTimer() end
            gsoSDK.Cursor:SetCursor(cursorPos, pos, 0.06)
            ControlSetCursorPos(pos)
            ControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
            ControlMouseEvent(MOUSEEVENTF_RIGHTUP)
            self.LastMoveLocal = GameTimer() + gsoSDK.Menu.orb.humanizer:Value() * 0.001
            self.LastMoveTime = GameTimer()
      end
      function __gsoOrbwalker:CanAttack()
            if not self.CanAttackC() then return false end
            if not gsoSDK.Spell:CheckSpellDelays(self.SpellAttackDelays) then return false end
            if self.IsBlindedByTeemo then
                  return false
            end
            if self.ResetAttack then
                  return true
            end
            local animDelay = gsoSDK.Menu.orb.animdelay:Value() * 0.001
            if GameTimer() < self.LastAttackLocal + self.AnimTime + self.LastAttackDiff + animDelay - 0.15 - self:GetAvgLatency() then
                  return false
            end
            return true
      end
      function __gsoOrbwalker:CanMove()
            if not self.CanMoveC() then return false end
            if not gsoSDK.Spell:CheckSpellDelays(self.SpellMoveDelays) then return false end
            local latency = math.min(gsoSDK.Utilities:GetMinLatency(), GameLatency() * 0.001) * 0.75
            latency = math.min(latency, gsoSDK.Utilities:GetUserLatency())
            local windUpDelay = gsoSDK.Menu.orb.windupdelay:Value() * 0.001
            if GameTimer() < self.LastAttackLocal + self.WindUpTime + self.LastAttackDiff - latency - 0.025 + windUpDelay then
                  return false
            end
            if self.LastAttackLocal > self.LastAttackServer and GameTimer() < self.LastAttackLocal + self.WindUpTime + self.LastAttackDiff - latency + 0.025 + windUpDelay then return false end
            return true
      end
      function __gsoOrbwalker:AttackMove(unit)
            self.LastTarget = nil
            if self.AttackEnabled and unit and unit.pos:ToScreen().onScreen and self:CanAttack() then
                  local args = { Target = unit, Process = true }
                  for i = 1, #self.OnPreAttackC do
                        self.OnPreAttackC[i](args)
                  end
                  if args.Process and args.Target and not args.Target.dead and args.Target.isTargetable and args.Target.valid then
                        self:Attack(args.Target)
                        self.PostAttackBool = true
                  end
            elseif self.MovementEnabled and self:CanMove() then
                  if self.PostAttackBool then
                        for i = 1, #self.OnPostAttackC do
                              self.OnPostAttackC[i]()
                        end
                        self.PostAttackBool = false
                  end
                  if GameTimer() > self.LastMoveLocal then
                        local args = { Target = nil, Process = true }
                        for i = 1, #self.OnPreMoveC do
                              self.OnPreMoveC[i](args)
                        end
                        if args.Process then
                              if not args.Target then
                                    self:Move()
                              elseif args.Target.x then
                                    self:MoveToPos(args.Target)
                              elseif args.Target.pos then
                                    self:MoveToPos(args.Target.pos)
                              else
                                    assert(false, "Gamsteron OnPreMovement Event: expected Vector !")
                              end
                        end
                  end
            end
      end
      function __gsoOrbwalker:Tick()
            if not self.Loaded and GameTimer() > self.LoadTime + 2.5 then
                  self.Loaded = true
            end
            if not self.Loaded then return end
            self:DisableIcOrb()
            self:DisableGosOrb()
            if not gsoSDK.Menu.orb.enabledorb:Value() then return end
            if self.IsTeemo then self.IsBlindedByTeemo = self:CheckTeemoBlind() end
            -- SERVER ATTACK START TIME
            if myHero.attackData.endTime > self.AttackEndTime then
                  for i = 1, #self.OnAttackC do
                        self.OnAttackC[i]()
                  end
                  local serverStart = myHero.attackData.endTime - myHero.attackData.animationTime
                  self.LastAttackDiff = serverStart - self.LastAttackLocal
                  self.LastAttackServer = GameTimer()
                  self.AttackEndTime = myHero.attackData.endTime
                  if gsoSDK.Menu.orb.enabled:Value() then
                        if self.TestCount == 0 then
                              self.TestStartTime = GameTimer()
                        end
                        self.TestCount = self.TestCount + 1
                        if self.TestCount == 5 then
                              print("5 attacks in time: " .. tostring(GameTimer() - self.TestStartTime) .. "[sec]")
                              self.TestCount = 0
                              self.TestStartTime = 0
                        end
                  end
            end
            -- RESET ATTACK
            if self.LastAttackLocal > self.LastAttackServer and GameTimer() > self.LastAttackLocal + 0.15 + gsoSDK.Utilities:GetMaxLatency() then
                  if gsoSDK.Menu.orb.enabled:Value() then
                        print("reset attack1")
                  end
                  self.LastAttackLocal = 0
            elseif self.LastAttackLocal < self.LastAttackServer and GameTimer() < self.LastAttackLocal + myHero.attackData.windUpTime and myHero.pathing.hasMovePath then
                  if gsoSDK.Menu.orb.enabled:Value() then
                        print("reset attack2")
                  end
                  self.LastAttackLocal = 0
            end
            -- ATTACK TIMERS
            self:SetAttackTimers()
            -- CHECK IF CAN ORBWALK
            local isEvading = ExtLibEvade and ExtLibEvade.Evading
            if not gsoSDK.Cursor:IsCursorReady() or GameIsChatOpen() or isEvading then
                  return
            end
            -- ORBWALKER MODE
            if gsoSDK.Menu.orb.keys.combo:Value() then
                  self:AttackMove(gsoSDK.TS:GetComboTarget())
            elseif gsoSDK.Menu.orb.keys.harass:Value() then
                  if gsoSDK.Farm:CanLastHit() then
                        self:AttackMove(gsoSDK.TS:GetLastHitTarget())
                  else
                        self:AttackMove(gsoSDK.TS:GetComboTarget())
                  end
            elseif gsoSDK.Menu.orb.keys.lasthit:Value() then
                  self:AttackMove(gsoSDK.TS:GetLastHitTarget())
            elseif gsoSDK.Menu.orb.keys.laneclear:Value() then
                  if gsoSDK.Farm:CanLastHit() then
                        self:AttackMove(gsoSDK.TS:GetLastHitTarget())
                  elseif gsoSDK.Farm:CanLaneClear() then
                        self:AttackMove(gsoSDK.TS:GetLaneClearTarget())
                  else
                        self:AttackMove()
                  end
            elseif gsoSDK.Menu.orb.keys.flee:Value() then
                  if self.MovementEnabled and GameTimer() > self.LastMoveLocal and self:CanMove() then
                        self:Move()
                  end
            elseif GameTimer() < self.LastMouseDown + 1 then
                  ControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
                  self.LastMouseDown = 0
            end
      end
--[[
▒█▀▀▀█ █▀▀█ █▀▀ █░░ █░░ 
░▀▀▀▄▄ █░░█ █▀▀ █░░ █░░ 
▒█▄▄▄█ █▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ 
]]
class "__gsoSpell"
      function __gsoSpell:__init()
            --[[ test dashSpell:
                  local cc= 0
                  if myHero.activeSpell and myHero.activeSpell.valid then cc = cc + 1; print('ok '..cc); print(myHero.activeSpell.name) end
                  if myHero.pathing.isDashing then print(cc.. " dash") end
            ]]
            self.dashSpell = {
                  ["sionr"] = true,
                  ["warwickr"] = true,
                  ["vir"] = true,
                  ["tristanaw"] = true,
                  ["shyvanatransformleap"] = true,
                  ["powerball"] = true,
                  ["leonazenithblade"] = true,
                  ["galioe"] = true,
                  ["galior"] = true,
                  ["blindmonkqone"] = true,
                  ["alphastrike"] = true,
                  ["nautilusanchordragmissile"] = true,
                  ["caitlynentrapment"] = true,
                  ["bandagetoss"] = true,
                  ["ekkoeattack"] = true,
                  ["ekkor"] = true,
                  ["evelynne"] = true,
                  ["evelynne2"] = true,
                  ["evelynnr"] = true,
                  ["ezrealarcaneshift"] = true,
                  ["crowstorm"] = true,
                  ["tahmkenchnewr"] = true,
                  ["shenr"] = true,
                  ["graveschargeshot"] = true,
                  ["jarvanivdragonstrike"] = true,
                  ["hecarimrampattack"] = true,
                  ["illaoiwattack"] = true,
                  ["riftwalk"] = true,
                  ["katarinae"] = true,
                  ["pantheonrjump"] = true
                  -- taliyahr
                  -- reksair
                  -- kled ?
                  -- rakanq, rakanr
                  -- sejuaniq ?
                  -- zace
                  -- zoe ?
                  -- kalistaq
                  -- eliseq ?
                  -- aurelionsol ?
            }
            self.Waypoints = {}
            self.LastQ = 0
            self.LastQk = 0
            self.LastW = 0
            self.LastWk = 0
            self.LastE = 0
            self.LastEk = 0
            self.LastR = 0
            self.LastRk = 0
            self.DelayedSpell = {}
            self.spellDraw = { q = false, w = false, e = false, r = false }
            if myHero.charName == "Aatrox" then
                  self.spellDraw = { q = true, qr = 650, e = true, er = 1000, r = true, rr = 550 }
            elseif myHero.charName == "Ahri" then
                  self.spellDraw = { q = true, qr = 880, w = true, wr = 700, e = true, er = 975, r = true, rr = 450 }
            elseif myHero.charName == "Akali" then
                  self.spellDraw = { q = true, qr = 600 + 120, w = true, wr = 475, e = true, er = 300, r = true, rr = 700 + 120 }
            elseif myHero.charName == "Alistar" then
                  self.spellDraw = { q = true, qr = 365, w = true, wr = 650 + 120, e = true, er = 350 }
            elseif myHero.charName == "Amumu" then
                  self.spellDraw = { q = true, qr = 1100, w = true, wr = 300, e = true, er = 350, r = true, rr = 550 }
            elseif myHero.charName == "Anivia" then
                  self.spellDraw = { q = true, qr = 1075, w = true, wr = 1000, e = true, er = 650 + 120, r = true, rr = 750 }
            elseif myHero.charName == "Annie" then
                  self.spellDraw = { q = true, qr = 625 + 120, w = true, wr = 625, r = true, rr = 600 }
            elseif myHero.charName == "Ashe" then
                  self.spellDraw = { w = true, wr = 1200 }
            elseif myHero.charName == "AurelionSol" then
                  self.spellDraw = { q = true, qr = 1075, w = true, wr = 600, e = true, ef = function() local eLvl = myHero:GetSpellData(_E).level; if eLvl == 0 then return 3000 else return 2000 + 1000 * eLvl end end, r = true, rr = 1500 }
            elseif myHero.charName == "Azir" then
                  self.spellDraw = { q = true, qr = 740, w = true, wr = 500, e = true, er = 1100, r = true, rr = 250 }
            elseif myHero.charName == "Bard" then
                  self.spellDraw = { q = true, qr = 950, w = true, wr = 800, e = true, er = 900, r = true, rr = 3400 }
            elseif myHero.charName == "Blitzcrank" then
                  self.spellDraw = { q = true, qr = 925, e = true, er = 300, r = true, rr = 600 }
            elseif myHero.charName == "Brand" then
                  self.spellDraw = { q = true, qr = 1050, w = true, wr = 900, e = true, er = 625 + 120, r = true, rr = 750 + 120 }
            elseif myHero.charName == "Braum" then
                  self.spellDraw = { q = true, qr = 1000, w = true, wr = 650 + 120, r = true, rr = 1250 }
            elseif myHero.charName == "Caitlyn" then
                  self.spellDraw = { q = true, qr = 1250, w = true, wr = 800, e = true, er = 750, r = true, rf = function() local rLvl = myHero:GetSpellData(_R).level; if rLvl == 0 then return 2000 else return 1500 + 500 * rLvl end end }
            elseif myHero.charName == "Camille" then
                  self.spellDraw = { q = true, qr = 325, w = true, wr = 610, e = true, er = 800, r = true, rr = 475 }
            elseif myHero.charName == "Cassiopeia" then
                  self.spellDraw = { q = true, qr = 850, w = true, wr = 800, e = true, er = 700, r = true, rr = 825 }
            elseif myHero.charName == "Chogath" then
                  self.spellDraw = { q = true, qr = 950, w = true, wr = 650, e = true, er = 500, r = true, rr = 175 + 120 }
            elseif myHero.charName == "Corki" then
                  self.spellDraw = { q = true, qr = 825, w = true, wr = 600, r = true, rr = 1225 }
            elseif myHero.charName == "Darius" then
                  self.spellDraw = { q = true, qr = 425, w = true, wr = 300, e = true, er = 535, r = true, rr = 460 + 120 }
            elseif myHero.charName == "Diana" then
                  self.spellDraw = { q = true, qr = 900, w = true, wr = 200, e = true, er = 450, r = true, rr = 825 }
            elseif myHero.charName == "DrMundo" then
                  self.spellDraw = { q = true, qr = 975, w = true, wr = 325 }
            elseif myHero.charName == "Draven" then
                  self.spellDraw = { e = true, er = 1050 }
            elseif myHero.charName == "Ekko" then
                  self.spellDraw = { q = true, qr = 1075, w = true, wr = 1600, e = true, er = 325 }
            elseif myHero.charName == "Elise" then
                  -- self.spellDraw = { need check form buff qHuman = 625, qSpider = 475, wHuman = 950, wSpider = math.huge(none), eHuman = 1075, eSpider = 750 }
            elseif myHero.charName == "Evelynn" then
                  self.spellDraw = { q = true, qr = 800, w = true, wf = function() local wLvl = myHero:GetSpellData(_W).level; if wLvl == 0 then return 1200 else return 1100 + 100 * wLvl end end, e = true, er = 210, r = true, rr = 450 }
            elseif myHero.charName == "Ezreal" then
                  self.spellDraw = { q = true, qr = 1150, w = true, wr = 1000, e = true, er = 475 }
            elseif myHero.charName == "Fiddlesticks" then
                  self.spellDraw = { q = true, qr = 575 + 120, w = true, wr = 650, e = true, er = 750 + 120, r = true, rr = 800 }
            elseif myHero.charName == "Fiora" then
                  self.spellDraw = { q = true, qr = 400, w = true, wr = 750, r = true, rr = 500 + 120 }
            elseif myHero.charName == "Fizz" then
                  self.spellDraw = { q = true, qr = 550 + 120, e = true, er = 400, r = true, rr = 1300 }
            elseif myHero.charName == "Galio" then
                  self.spellDraw = { q = true, qr = 825, w = true, wr = 350, e = true, er = 650, r = true, rf = function() local rLvl = myHero:GetSpellData(_R).level; if rLvl == 0 then return 4000 else return 3250 + 750 * rLvl end end }
            elseif myHero.charName == "Gangplank" then
                  self.spellDraw = { q = true, qr = 625 + 120, w = true, wr = 650, e = true, er = 1000 }
            elseif myHero.charName == "Garen" then
                  self.spellDraw = { e = true, er = 325, r = true, rr = 400 + 120 }
            elseif myHero.charName == "Gnar" then
                  self.spellDraw = { q = true, qr = 1100, r = true, rr = 475, w = false, e = false } -- wr (mega gnar) = 550, er (mini gnar) = 475, er (mega gnar) = 600
            elseif myHero.charName == "Gragas" then
                  self.spellDraw = { q = true, qr = 850, e = true, er = 600, r = true, rr = 1000 }
            elseif myHero.charName == "Graves" then
                  self.spellDraw = { q = true, qr = 925, w = true, wr = 950, e = true, er = 475, r = true, rr = 1000 }
            elseif myHero.charName == "Hecarim" then
                  self.spellDraw = { q = true, qr = 350, w = true, wr = 575 + 120, r = true, rr = 1000 }
            elseif myHero.charName == "Heimerdinger" then
                  self.spellDraw = { q = false, w = true, wr = 1325, e = true, er = 970 } --  qr (noR) = 350, wr (R) = 450
            elseif myHero.charName == "Illaoi" then
                  self.spellDraw = { q = true, qr = 850, w = true, wr = 350 + 120, e = true, er = 900, r = true, rr = 450 }
            elseif myHero.charName == "Irelia" then
                  self.spellDraw = { q = true, qr = 625 + 120, w = true, wr = 825, e = true, er = 900, r = true, rr = 1000 }
            elseif myHero.charName == "Ivern" then
                  self.spellDraw = { q = true, qr = 1075, w = true, wr = 1000, e = true, er = 750 + 120 }
            elseif myHero.charName == "Janna" then
                  self.spellDraw = { q = true, qf = function() local qt = GameTimer() - self.LastQk;if qt > 3 then return 1000 end local qrange = qt * 250;if qrange > 1750 then return 1750 end return qrange end, w = true, wr = 550 + 120, e = true, er = 800 + 120, r = true, rr = 725 }
            elseif myHero.charName == "JarvanIV" then
                  self.spellDraw = { q = true, qr = 770, w = true, wr = 625, e = true, er = 860, r = true, rr = 650 + 120 }
            elseif myHero.charName == "Jax" then
                  self.spellDraw = { q = true, qr = 700 + 120, e = true, er = 300 }
            elseif myHero.charName == "Jayce" then
                  --self.spellDraw = { q = true, qr = 700 + 120, e = true, er = 300, r = true }  (Mercury Hammer: q=600+120, w=285, e=240+120; Mercury Cannon: q=1050/1470, w=active, e=650
            elseif myHero.charName == "Jhin" then
                  self.spellDraw = { q = true, qr = 550 + 120, w = true, wr = 3000, e = true, er = 750, r = true, rr = 3500 }
            elseif myHero.charName == "Jinx" then
                  self.spellDraw = { q = true, qf = function() if self:HasBuff(myHero, "jinxq") then return 525 + myHero.boundingRadius + 35 else local qExtra = 25 * myHero:GetSpellData(_Q).level; return 575 + qExtra + myHero.boundingRadius + 35 end end, w = true, wr = 1450, e = true, er = 900 }
            elseif myHero.charName == "KogMaw" then
                  self.spellDraw = { q = true, qr = 1175, e = true, er = 1280, r = true, rf = function() local rlvl = myHero:GetSpellData(_R).level; if rlvl == 0 then return 1200 else return 900 + 300 * rlvl end end }
            elseif myHero.charName == "Lucian" then
                  self.spellDraw = { q = true, qr = 500+120, w = true, wr = 900+350, e = true, er = 425, r = true, rr = 1200 }
            elseif myHero.charName == "Nami" then
                  self.spellDraw = { q = true, qr = 875, w = true, wr = 725, e = true, er = 800, r = true, rr = 2750 }
            elseif myHero.charName == "Sivir" then
                  self.spellDraw = { q = true, qr = 1250, r = true, rr = 1000 }
            elseif myHero.charName == "Teemo" then
                  self.spellDraw = { q = true, qr = 680, r = true, rf = function() local rLvl = myHero:GetSpellData(_R).level; if rLvl == 0 then rLvl = 1 end return 150 + ( 250 * rLvl ) end }
            elseif myHero.charName == "Twitch" then
                  self.spellDraw = { w = true, wr = 950, e = true, er = 1200, r = true, rf = function() return myHero.range + 300 + ( myHero.boundingRadius * 2 ) end }
            elseif myHero.charName == "Tristana" then
                  self.spellDraw = { w = true, wr = 900 }
            elseif myHero.charName == "Varus" then
                  self.spellDraw = { q = true, qr = 1650, e = true, er = 950, r = true, rr = 1075 }
            elseif myHero.charName == "Vayne" then
                  self.spellDraw = { q = true, qr = 300, e = true, er = 550 }
            elseif myHero.charName == "Viktor" then
                  self.spellDraw = { q = true, qr = 600 + 2 * myHero.boundingRadius, w = true, wr = 700, e = true, er = 550 }
            elseif myHero.charName == "Xayah" then
                  self.spellDraw = { q = true, qr = 1100 }
            end
      end
      function __gsoSpell:ReducedDmg(unit, dmg, isAP)
            local def = isAP and unit.magicResist - myHero.magicPen or unit.armor - myHero.armorPen
            if def > 0 then def = isAP and myHero.magicPenPercent * def or myHero.bonusArmorPenPercent * def end
            return def > 0 and dmg * ( 100 / ( 100 + def ) ) or dmg * ( 2 - ( 100 / ( 100 - def ) ) )
      end
      function __gsoSpell:CalculateDmg(unit, spellData)
            local dmgType = spellData.dmgType and spellData.dmgType or ""
            if not unit then assert(false, "[234] CalculateDmg: unit is nil !") end
            if dmgType == "ad" and spellData.dmgAD then
                  local dmgAD = spellData.dmgAD - unit.shieldAD
                  return dmgAD < 0 and 0 or self:ReducedDmg(unit, dmgAD, false) 
            elseif dmgType == "ap" and spellData.dmgAP then
                  local dmgAP = spellData.dmgAP - unit.shieldAD - unit.shieldAP
                  return dmgAP < 0 and 0 or self:ReducedDmg(unit, dmgAP, true) 
            elseif dmgType == "true" and spellData.dmgTrue then
                  return spellData.dmgTrue - unit.shieldAD
            elseif dmgType == "mixed" and spellData.dmgAD and spellData.dmgAP then
                  local dmgAD = spellData.dmgAD - unit.shieldAD
                  local shieldAD = dmgAD < 0 and (-1) * dmgAD or 0
                  dmgAD = dmgAD < 0 and 0 or self:ReducedDmg(unit, dmgAD, false)
                  local dmgAP = spellData.dmgAP - shieldAD - unit.shieldAP
                  dmgAP = dmgAP < 0 and 0 or self:ReducedDmg(unit, dmgAP, true)
                  return dmgAD + dmgAP
            end
            assert(false, "[234] CalculateDmg: spellData - expected array { dmgType = string(ap or ad or mixed or true), dmgAP = number or dmgAD = number or ( dmgAP = number and dmgAD = number ) or dmgTrue = number } !")
      end
      function __gsoSpell:GetLastSpellTimers()
            return self.LastQ, self.LastQk, self.LastW, self.LastWk, self.LastE, self.LastEk, self.LastR, self.LastRk
      end
      function __gsoSpell:HasBuff(unit, bName)
            bName = bName:lower()
            for i = 0, unit.buffCount do
                  local buff = unit:GetBuff(i)
                  if buff and buff.count > 0 and buff.name:lower() == bName then
                        return true
                  end
            end
            return false
      end
      function __gsoSpell:GetBuffDuration(unit, bName)
            bName = bName:lower()
            for i = 0, unit.buffCount do
                  local buff = unit:GetBuff(i)
                  if buff and buff.count > 0 and buff.name:lower() == bName then
                        return buff.duration
                  end
            end
            return 0
      end
      function __gsoSpell:GetBuffCount(unit, bName)
            bName = bName:lower()
            for i = 0, unit.buffCount do
                  local buff = unit:GetBuff(i)
                  if buff and buff.count > 0 and buff.name:lower() == bName then
                        return buff.count
                  end
            end
            return 0
      end
      function __gsoSpell:GetBuffStacks(unit, bName)
            bName = bName:lower()
            for i = 0, unit.buffCount do
                  local buff = unit:GetBuff(i)
                  if buff and buff.count > 0 and buff.name:lower() == bName then
                        return buff.stacks
                  end
            end
            return 0
      end
      function __gsoSpell:GetDamage(unit, spellData)
            return self:CalculateDmg(unit, spellData)
      end
      function __gsoSpell:CheckSpellDelays(delays)
            if GameTimer() < self.LastQ + delays.q or GameTimer() < self.LastQk + delays.q then return false end
            if GameTimer() < self.LastW + delays.w or GameTimer() < self.LastWk + delays.w then return false end
            if GameTimer() < self.LastE + delays.e or GameTimer() < self.LastEk + delays.e then return false end
            if GameTimer() < self.LastR + delays.r or GameTimer() < self.LastRk + delays.r then return false end
            return true
      end
      function __gsoSpell:CustomIsReady(spell, cd)
            local passT
            if spell == _Q then
                  passT = GameTimer() - self.LastQk
            elseif spell == _W then
                  passT = GameTimer() - self.LastWk
            elseif spell == _E then
                  passT = GameTimer() - self.LastEk
            elseif spell == _R then
                  passT = GameTimer() - self.LastRk
            end
            local cdr = 1 - myHero.cdr
            cd = cd * cdr
            if passT - gsoSDK.Utilities:GetMaxLatency() - 0.15 > cd then
                  return true
            end
            return false
      end
      function __gsoSpell:IsReady(spell, delays)
            return gsoSDK.Cursor:IsCursorReady() and self:CheckSpellDelays(delays) and GameCanUseSpell(spell) == 0
      end
      function __gsoSpell:GetWaypoints(unit)
            local path = unit.pathing
            if path.hasMovePath then
                  local result = {}
                  local pathCount = path.pathCount
                  for i = 0, pathCount do
                        result[#result+1] = unit:GetPath(i)
                  end
                  return { IsMoving = true, Path = result, Tick = GameTimer() }
            else
                  return { IsMoving = false, Path = unit.pos, Tick = GameTimer() }
            end
      end
      function __gsoSpell:SaveWaypoints(enemyList)
            for i = 1, #enemyList do
                  local unit = enemyList[i]
                  local unitID = unit.networkID
                  if not self.Waypoints[unitID] then self.Waypoints[unitID] = {} end
                  if not self.Waypoints[unitID].current then
                        self.Waypoints[unitID].current = self:GetWaypoints(unit)
                  else
                        local currentWaypoints = self:GetWaypoints(unit)
                        local currentWaypointsT = self.Waypoints[unitID].current
                        if currentWaypointsT.IsMoving == currentWaypoints.IsMoving then
                              if not currentWaypointsT.IsMoving then
                                    if currentWaypointsT.Path == currentWaypoints.Path then return end
                              else
                                    local count = #currentWaypoints.Path
                                    local countT = #currentWaypointsT.Path
                                    if count == countT then
                                          local canReturn = true
                                          for i = 1, countT do
                                                if currentWaypointsT.Path[i] ~= currentWaypoints.Path[i] then
                                                      canReturn = false
                                                      break
                                                end
                                          end
                                          if canReturn then
                                                return
                                          end
                                    end
                              end
                        end
                        self.Waypoints[unitID].current = currentWaypoints
                  end
            end
      end
      function __gsoSpell:CanMove(unit, delay)
            for i = 1, unit.buffCount do
                  local buff = unit:GetBuff(i);
                  if buff.count > 0 and buff.duration >= delay then
                        if (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11) then
                              return false
                        end
                  end
            end
            return true
      end
      function __gsoSpell:IsImmobile(unit, delay, radius, speed, from, spelltype)
            local ExtraDelay = from:DistanceTo(unit.pos) / speed
            if not self:CanMove(unit, delay + ExtraDelay) then
                  return true
            end
            return false
      end
      function __gsoSpell:isSlowed(unit, delay, speed, from)
            for i = 1, unit.buffCount do
                  local buff = unit:GetBuff(i)
                  if from and buff.count > 0 and buff.type == 10 and buff.duration >= delay + from:DistanceTo(unit.pos) / speed then
                        return true
                  end
            end
            return false
      end
      function __gsoSpell:ClosestPointOnLineSegment(p, p1, p2)
            --local px,pz,py = p.x, p.z, p.y
            --local ax,az,ay = p1.x, p1.z, p1.y
            --local bx,bz,by = p2.x, p2.z, p2.y
            local px,pz = p.x, p.z
            local ax,az = p1.x, p1.z
            local bx,bz = p2.x, p2.z
            local bxax = bx - ax
            local bzaz = bz - az
            --local byay = by - by
            --local t = ((px - ax) * bxax + (pz - az) * bzaz + (py - ay) * byay) / (bxax * bxax + bzaz * bzaz + byay * byay)
            local t = ((px - ax) * bxax + (pz - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
            if t < 0 then
                  return p1, false
            elseif t > 1 then
                  return p2, false
            else
                  return { x = ax + t * bxax, z = az + t * bzaz }, true
                  --return Vector({ x = ax + t * bxax, z = az + t * bzaz, y = ay + t * byay }), true
            end
      end
      function __gsoSpell:IsMinionCollision(unit, spellData, prediction)
            local width = spellData.radius * 0.77
            local enemyMinions = gsoSDK.ObjectManager.Units.EnemyMinions
            for i = 1, #enemyMinions do
                  local minion = enemyMinions[i]
                  if minion ~= unit then
                        local minionPos = minion.pos
                        local point,onLineSegment = self:ClosestPointOnLineSegment(minionPos, prediction and unit:GetPrediction(spellData.speed,spellData.delay) or unit.pos, myHero.pos)
                        local distanceToPoint = minionPos:DistanceTo(Vector(point))
                        local bbox = minion.boundingRadius
                        if distanceToPoint < width +  bbox then
                              return true
                        end
                  end
            end
            return false
      end
      function __gsoSpell:IsCollision(unit, spellData)
            if unit:GetCollision(spellData.radius, spellData.speed, spellData.delay) > 0 or gsoSDK.Spell:IsMinionCollision(unit, spellData) or gsoSDK.Spell:IsMinionCollision(unit, spellData, true) then
                  return true
            end
            return false
      end
      function __gsoSpell:CastSpell(spell, unit, from, spellData, HitChance)
            local result = false
            if not unit then
                  ControlKeyDown(spell)
                  ControlKeyUp(spell)
                  result = true
            else
                  if GameTimer() < gsoSDK.Orbwalker.LastMoveTime + 0.05 then
                        return false
                  end
                  local CastPos
                  if from and spellData and HitChance then
                        local range = spellData.range
                        local radius = spellData.radius
                        local speed = spellData.speed
                        local delay = spellData.delay
                        local sType = spellData.sType
                        local collision = spellData.collision
                        if sType == "line" then
                              range = range - (radius * 0.5)
                        end
                        if collision and self:IsCollision(unit, spellData) then
                              return false
                        end
                        local hitChance = 1
                        if not self.Waypoints[unit.networkID] or not self.Waypoints[unit.networkID].current then return false end
                        local lastWP = GameTimer() - self.Waypoints[unit.networkID].current.Tick
                        local longWP = lastWP > 1.5 and lastWP < 5
                        local isCastingSpell = unit.activeSpell and unit.activeSpell.valid
                        if unit.pathing.isDashing then
                              return false
                        end
                        if isCastingSpell and self.dashSpell[unit.activeSpell.name:lower()] then
                              return false
                        end
                        if lastWP < 0.2 or longWP then
                              hitChance = 2
                        end
                        if self:IsImmobile(unit, delay, radius, speed, from, sType) or self:isSlowed(unit, delay, speed, from) or isCastingSpell then
                              hitChance = 2
                              CastPos = unit.pos
                        elseif unit.pathing.hasMovePath then
                              CastPos = unit:GetPrediction(speed,delay):Extended(unit.pos, radius * 0.5)
                              local angletemp = from:AngleBetween(unit.pos, CastPos)
                              if angletemp < 33 then
                                    hitChance = 2
                              end
                        end
                        if not CastPos or not CastPos:ToScreen().onScreen then
                              return false
                        end
                        if from:DistanceTo(CastPos) > range - 25 then
                              return false
                        end
                        if unit.pos:DistanceTo(CastPos) > 250 then
                              hitChance = 1
                        end
                        if hitChance >= HitChance then
                              gsoSDK.Cursor:SetCursor(cursorPos, CastPos, 0.06)
                              ControlSetCursorPos(CastPos)
                              ControlKeyDown(spell)
                              ControlKeyUp(spell)
                              gsoSDK.Orbwalker:ResetMove()
                              result = true
                        end
                  else
                        CastPos = unit.pos
                        gsoSDK.Cursor:SetCursor(cursorPos, CastPos, 0.06)
                        ControlSetCursorPos(CastPos)
                        ControlKeyDown(spell)
                        ControlKeyUp(spell)
                        gsoSDK.Orbwalker:ResetMove()
                        result = true
                  end
            end
            if result then
                  if spell == HK_Q then
                        self.LastQ = GameTimer()
                  elseif spell == HK_W then
                        self.LastW = GameTimer()
                  elseif spell == HK_E then
                        self.LastE = GameTimer()
                  elseif spell == HK_R then
                        self.LastR = GameTimer()
                  end
            end
            return result
      end
      function __gsoSpell:ImmobileTime(unit)
            local iT = 0
            for i = 0, unit.buffCount do
                  local buff = unit:GetBuff(i)
                  if buff and buff.count > 0 then
                        local bType = buff.type
                        if bType == 5 or bType == 11 or bType == 29 or bType == 24 or buff.name == "recall" then
                              local bDuration = buff.duration
                              if bDuration > iT then
                                    iT = bDuration
                              end
                        end
                  end
            end
            return iT
      end
      function __gsoSpell:CastManualSpell(spell, delays)
            local kNum = 0
            if spell == _W then
                  kNum = 1
            elseif spell == _E then
                  kNum = 2
            elseif spell == _R then
                  kNum = 3
            end
            if GameCanUseSpell(spell) == 0 then
                  for k,v in pairs(self.DelayedSpell) do
                        if k == kNum then
                              if gsoSDK.Cursor:IsCursorReady() and self:CheckSpellDelays(delays) then
                                    v[1]()
                                    gsoSDK.Cursor:SetCursor(cursorPos, nil, 0.06)
                                    if k == 0 then
                                          self.LastQ = GameTimer()
                                    elseif k == 1 then
                                          self.LastW = GameTimer()
                                    elseif k == 2 then
                                          self.LastE = GameTimer()
                                    elseif k == 3 then
                                          self.LastR = GameTimer()
                                    end
                                    self.DelayedSpell[k] = nil
                                    break
                              end
                              if GameTimer() - v[2] > 0.125 then
                                    self.DelayedSpell[k] = nil
                              end
                              break
                        end
                  end
            end
      end
      function __gsoSpell:WndMsg(msg, wParam)
            local manualNum = -1
            if wParam == HK_Q and GameTimer() > self.LastQk + 1 and GameCanUseSpell(_Q) == 0 then
                  self.LastQk = GameTimer()
                  manualNum = 0
            elseif wParam == HK_W and GameTimer() > self.LastWk + 1 and GameCanUseSpell(_W) == 0 then
                  self.LastWk = GameTimer()
                  manualNum = 1
            elseif wParam == HK_E and GameTimer() > self.LastEk + 1 and GameCanUseSpell(_E) == 0 then
                  self.LastEk = GameTimer()
                  manualNum = 2
            elseif wParam == HK_R and GameTimer() > self.LastRk + 1 and GameCanUseSpell(_R) == 0 then
                  self.LastRk = GameTimer()
                  manualNum = 3
            end
            if manualNum > -1 and not self.DelayedSpell[manualNum] then
                  if gsoSDK.Menu.orb.keys.combo:Value() or gsoSDK.Menu.orb.keys.harass:Value() or gsoSDK.Menu.orb.keys.lasthit:Value() or gsoSDK.Menu.orb.keys.laneclear:Value() or gsoSDK.Menu.orb.keys.flee:Value() then
                        self.DelayedSpell[manualNum] = {
                              function()
                                    ControlKeyDown(wParam)
                                    ControlKeyUp(wParam)
                                    ControlKeyDown(wParam)
                                    ControlKeyUp(wParam)
                                    ControlKeyDown(wParam)
                                    ControlKeyUp(wParam)
                              end,
                              GameTimer()
                        }
                  end
            end
      end
      function __gsoSpell:CreateDrawMenu()
            gsoSDK.Menu.gsodraw:MenuElement({name = "Spell Ranges", id = "circle1", type = MENU,
                  onclick = function()
                        if self.spellDraw.q then
                              gsoSDK.Menu.gsodraw.circle1.qrange:Hide(true)
                              gsoSDK.Menu.gsodraw.circle1.qrangecolor:Hide(true)
                              gsoSDK.Menu.gsodraw.circle1.qrangewidth:Hide(true)
                        end
                        if self.spellDraw.w then
                              gsoSDK.Menu.gsodraw.circle1.wrange:Hide(true)
                              gsoSDK.Menu.gsodraw.circle1.wrangecolor:Hide(true)
                              gsoSDK.Menu.gsodraw.circle1.wrangewidth:Hide(true)
                        end
                        if self.spellDraw.e then
                              gsoSDK.Menu.gsodraw.circle1.erange:Hide(true)
                              gsoSDK.Menu.gsodraw.circle1.erangecolor:Hide(true)
                              gsoSDK.Menu.gsodraw.circle1.erangewidth:Hide(true)
                        end
                        if self.spellDraw.r then
                              gsoSDK.Menu.gsodraw.circle1.rrange:Hide(true)
                              gsoSDK.Menu.gsodraw.circle1.rrangecolor:Hide(true)
                              gsoSDK.Menu.gsodraw.circle1.rrangewidth:Hide(true)
                        end
                  end
            })
            if self.spellDraw.q then
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({name = "Q Range", id = "note5", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
                        onclick = function()
                              gsoSDK.Menu.gsodraw.circle1.qrange:Hide()
                              gsoSDK.Menu.gsodraw.circle1.qrangecolor:Hide()
                              gsoSDK.Menu.gsodraw.circle1.qrangewidth:Hide()
                        end
                  })
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "qrange", name = "        Enabled", value = true})
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "qrangecolor", name = "        Color", color = DrawColor(255, 66, 134, 244)})
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "qrangewidth", name = "        Width", value = 1, min = 1, max = 10})
            end
            if self.spellDraw.w then
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({name = "W Range", id = "note6", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
                        onclick = function()
                              gsoSDK.Menu.gsodraw.circle1.wrange:Hide()
                              gsoSDK.Menu.gsodraw.circle1.wrangecolor:Hide()
                              gsoSDK.Menu.gsodraw.circle1.wrangewidth:Hide()
                        end
                  })
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "wrange", name = "        Enabled", value = true})
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "wrangecolor", name = "        Color", color = DrawColor(255, 92, 66, 244)})
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "wrangewidth", name = "        Width", value = 1, min = 1, max = 10})
            end
            if self.spellDraw.e then
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({name = "E Range", id = "note7", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
                        onclick = function()
                              gsoSDK.Menu.gsodraw.circle1.erange:Hide()
                              gsoSDK.Menu.gsodraw.circle1.erangecolor:Hide()
                              gsoSDK.Menu.gsodraw.circle1.erangewidth:Hide()
                        end
                  })
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "erange", name = "        Enabled", value = true})
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "erangecolor", name = "        Color", color = DrawColor(255, 66, 244, 149)})
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "erangewidth", name = "        Width", value = 1, min = 1, max = 10})
            end
            if self.spellDraw.r then
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({name = "R Range", id = "note8", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
                        onclick = function()
                              gsoSDK.Menu.gsodraw.circle1.rrange:Hide()
                              gsoSDK.Menu.gsodraw.circle1.rrangecolor:Hide()
                              gsoSDK.Menu.gsodraw.circle1.rrangewidth:Hide()
                        end
                  })
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "rrange", name = "        Enabled", value = true})
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "rrangecolor", name = "        Color", color = DrawColor(255, 244, 182, 66)})
                  gsoSDK.Menu.gsodraw.circle1:MenuElement({id = "rrangewidth", name = "        Width", value = 1, min = 1, max = 10})
            end
      end
      function __gsoSpell:Draw()
            local drawMenu = gsoSDK.Menu.gsodraw.circle1
            if self.spellDraw.q and drawMenu.qrange:Value() then
                  local qrange = self.spellDraw.qf and self.spellDraw.qf() or self.spellDraw.qr
                  DrawCircle(myHero.pos, qrange, drawMenu.qrangewidth:Value(), drawMenu.qrangecolor:Value())
            end
            if self.spellDraw.w and drawMenu.wrange:Value() then
                  local wrange = self.spellDraw.wf and self.spellDraw.wf() or self.spellDraw.wr
                  DrawCircle(myHero.pos, wrange, drawMenu.wrangewidth:Value(), drawMenu.wrangecolor:Value())
            end
            if self.spellDraw.e and drawMenu.erange:Value() then
                  local erange = self.spellDraw.ef and self.spellDraw.ef() or self.spellDraw.er
                  DrawCircle(myHero.pos, erange, drawMenu.erangewidth:Value(), drawMenu.erangecolor:Value())
            end
            if self.spellDraw.r and drawMenu.rrange:Value() then
                  local rrange = self.spellDraw.rf and self.spellDraw.rf() or self.spellDraw.rr
                  DrawCircle(myHero.pos, rrange, drawMenu.rrangewidth:Value(), drawMenu.rrangecolor:Value())
            end
      end
--[[
▀▀█▀▀ █▀▀█ █▀▀█ █▀▀▀ █▀▀ ▀▀█▀▀ 　 ▒█▀▀▀█ █▀▀ █░░ █▀▀ █▀▀ ▀▀█▀▀ █▀▀█ █▀▀█ 
░▒█░░ █▄▄█ █▄▄▀ █░▀█ █▀▀ ░░█░░ 　 ░▀▀▀▄▄ █▀▀ █░░ █▀▀ █░░ ░░█░░ █░░█ █▄▄▀ 
░▒█░░ ▀░░▀ ▀░▀▀ ▀▀▀▀ ▀▀▀ ░░▀░░ 　 ▒█▄▄▄█ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ░░▀░░ ▀▀▀▀ ▀░▀▀ 
]]
class "__gsoTS"
      function __gsoTS:__init()
            -- Last LastHit Minion
            self.LastHandle = 0
            -- Last LaneClear Minion
            self.LastLCHandle = 0
            self.SelectedTarget = nil
            self.LastSelTick = 0
            self.LastHeroTarget = nil
            self.FarmMinions = {}
            self.Priorities = {
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
            self.PriorityMultiplier = {
                  [1] = 1,
                  [2] = 1.15,
                  [3] = 1.3,
                  [4] = 1.45,
                  [5] = 1.6,
                  [6] = 1.75
            }
      end
      function __gsoTS:GetSelectedTarget()
            return self.SelectedTarget
      end
      function __gsoTS:CreatePriorityMenu(charName)
            local priority = self.Priorities[charName] ~= nil and self.Priorities[charName] or 5
            gsoSDK.Menu.ts.priority:MenuElement({ id = charName, name = charName, value = priority, min = 1, max = 5, step = 1 })
      end
      function __gsoTS:CreateMenu(menu)
            gsoSDK.Menu:MenuElement({name = "Target Selector", id = "ts", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ts.png" })
                  gsoSDK.Menu.ts:MenuElement({ id = "Mode", name = "Mode", value = 1, drop = { "Auto", "Closest", "Least Health", "Least Priority" } })
                  gsoSDK.Menu.ts:MenuElement({ id = "priority", name = "Priorities", type = MENU })
                        gsoSDK.ObjectManager:OnEnemyHeroLoad(function(hero) self:CreatePriorityMenu(hero.charName) end)
                  gsoSDK.Menu.ts:MenuElement({ id = "selected", name = "Selected Target", type = MENU })
                        gsoSDK.Menu.ts.selected:MenuElement({ id = "enable", name = "Enable", value = true })
                  gsoSDK.Menu.ts:MenuElement({name = "LastHit Mode", id = "lasthitmode", value = 1, drop = { "Accuracy", "Fast" } })
                  gsoSDK.Menu.ts:MenuElement({name = "LaneClear Should Wait Time", id = "shouldwaittime", value = 200, min = 0, max = 1000, step = 50, tooltip = "Less Value = Faster LaneClear" })
                  gsoSDK.Menu.ts:MenuElement({name = "LaneClear Harass", id = "laneset", value = true })
      end
      function __gsoTS:CreateDrawMenu(menu)
            gsoSDK.Menu.gsodraw:MenuElement({name = "Selected Target",  id = "selected", type = MENU})
                  gsoSDK.Menu.gsodraw.selected:MenuElement({name = "Enabled",  id = "enabled", value = true})
                  gsoSDK.Menu.gsodraw.selected:MenuElement({name = "Color",  id = "color", color = DrawColor(255, 204, 0, 0)})
                  gsoSDK.Menu.gsodraw.selected:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
                  gsoSDK.Menu.gsodraw.selected:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
            gsoSDK.Menu.gsodraw:MenuElement({name = "LastHitable Minion",  id = "lasthit", type = MENU})
                  gsoSDK.Menu.gsodraw.lasthit:MenuElement({name = "Enabled",  id = "enabled", value = true})
                  gsoSDK.Menu.gsodraw.lasthit:MenuElement({name = "Color",  id = "color", color = DrawColor(150, 255, 255, 255)})
                  gsoSDK.Menu.gsodraw.lasthit:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
                  gsoSDK.Menu.gsodraw.lasthit:MenuElement({name = "Radius",  id = "radius", value = 50, min = 1, max = 100})
            gsoSDK.Menu.gsodraw:MenuElement({name = "Almost LastHitable Minion",  id = "almostlasthit", type = MENU})
                  gsoSDK.Menu.gsodraw.almostlasthit:MenuElement({name = "Enabled",  id = "enabled", value = true})
                  gsoSDK.Menu.gsodraw.almostlasthit:MenuElement({name = "Color",  id = "color", color = DrawColor(150, 239, 159, 55)})
                  gsoSDK.Menu.gsodraw.almostlasthit:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
                  gsoSDK.Menu.gsodraw.almostlasthit:MenuElement({name = "Radius",  id = "radius", value = 50, min = 1, max = 100})
      end
      function __gsoTS:GetTarget(enemyHeroes, dmgAP)
            local selectedID
            if gsoSDK.Menu.ts.selected.enable:Value() and self.SelectedTarget then
                  selectedID = self.SelectedTarget.networkID
            end
            local result = nil
            local num = 10000000
            local mode = gsoSDK.Menu.ts.Mode:Value()
            for i = 1, #enemyHeroes do
                  local x
                  local unit = enemyHeroes[i]
                  if selectedID and unit.networkID == selectedID then
                        return self.SelectedTarget
                  elseif mode == 1 then
                        local unitName = unit.charName
                        local multiplier = self.PriorityMultiplier[gsoSDK.Menu.ts.priority[unitName] and gsoSDK.Menu.ts.priority[unitName]:Value() or 6]
                        local def = dmgAP and multiplier * (unit.magicResist - myHero.magicPen) or multiplier * (unit.armor - myHero.armorPen)
                        if def > 0 then
                              def = dmgAP and myHero.magicPenPercent * def or myHero.bonusArmorPenPercent * def
                        end
                        x = ( ( unit.health * multiplier * ( ( 100 + def ) / 100 ) ) - ( unit.totalDamage * unit.attackSpeed * 2 ) ) - unit.ap
                  elseif mode == 2 then
                        x = unit.pos:DistanceTo(myHero.pos)
                  elseif mode == 3 then
                        x = unit.health
                  elseif mode == 4 then
                        local unitName = unit.charName
                        x = gsoSDK.Menu.ts.priority[unitName] and gsoSDK.Menu.ts.priority[unitName]:Value() or 6
                  end
                  if x < num then
                        num = x
                        result = unit
                  end
            end
            return result
      end
      function __gsoTS:GetLastHeroTarget()
            return self.LastHeroTarget
      end
      function __gsoTS:GetFarmMinions()
            return self.FarmMinions
      end
      function __gsoTS:GetComboTarget()
            local comboT = self:GetTarget(gsoSDK.ObjectManager:GetEnemyHeroes(myHero.range+myHero.boundingRadius - 35, true, "attack"), false)
            if comboT ~= nil then
                  self.LastHeroTarget = comboT
            end
            return comboT
      end
      function __gsoTS:GetLastHitTarget()
            local min = 10000000
            local result = nil
            for i = 1, #self.FarmMinions do
                  local enemyMinion = self.FarmMinions[i]
                  if enemyMinion.LastHitable and enemyMinion.PredictedHP < min then
                        min = enemyMinion.PredictedHP
                        result = enemyMinion.Minion
                  end
            end
            if result ~= nil then
                  self.LastHandle = result.handle
            end
            return result
      end
      function __gsoTS:GetLaneClearTarget()
            local enemyTurrets = gsoSDK.ObjectManager:GetEnemyTurrets(myHero.range+myHero.boundingRadius - 35, true)
            for i = 1, #enemyTurrets do
                  return enemyTurrets[i]
            end
            if gsoSDK.Menu.ts.laneset:Value() then
                  local result = self:GetComboTarget()
                  if result then return result end
            end
            local result = nil
            if gsoSDK.Farm:CanLaneClearTime() then
                  local min = 10000000
                  for i = 1, #self.FarmMinions do
                        local enemyMinion = self.FarmMinions[i]
                        if enemyMinion.PredictedHP < min then
                              min = enemyMinion.PredictedHP
                              result = enemyMinion.Minion
                        end
                  end
            end
            if result ~= nil then
                  self.LastLCHandle = result.handle
            end
            return result
      end
      function __gsoTS:GetClosestEnemy(enemyList, maxDistance)
            local result = nil
            for i = 1, #enemyList do
                  local hero = enemyList[i]
                  local distance = myHero.pos:DistanceTo(hero.pos)
                  if distance < maxDistance then
                        maxDistance = distance
                        result = hero
                  end
            end
            return result
      end
      function __gsoTS:GetImmobileEnemy(enemyList, maxDistance)
            local result = nil
            local num = 0
            for i = 1, #enemyList do
                  local hero = enemyList[i]
                  local distance = myHero.pos:DistanceTo(hero.pos)
                  local iT = gsoSDK.Spell:ImmobileTime(hero)
                  if distance < maxDistance and iT > num then
                        num = iT
                        result = hero
                  end
            end
            return result
      end
      function __gsoTS:Tick()
            local enemyMinions = gsoSDK.ObjectManager:GetEnemyMinions(myHero.range + myHero.boundingRadius - 35, true)
            local allyMinions = gsoSDK.ObjectManager:GetAllyMinions(1500, false)
            local lastHitMode = gsoSDK.Menu.ts.lasthitmode:Value() == 1 and "accuracy" or "fast"
            local cacheFarmMinions = {}
            for i = 1, #enemyMinions do
                  local enemyMinion = enemyMinions[i]
                  local FlyTime = myHero.attackData.windUpTime + ( myHero.pos:DistanceTo(enemyMinion.pos) / myHero.attackData.projectileSpeed )
                  cacheFarmMinions[#cacheFarmMinions+1] = gsoSDK.Farm:SetLastHitable(enemyMinion, FlyTime, myHero.totalDamage, lastHitMode, allyMinions)
            end
            self.FarmMinions = cacheFarmMinions
      end
      function __gsoTS:WndMsg(msg, wParam)
            if msg == WM_LBUTTONDOWN and gsoSDK.Menu.ts.selected.enable:Value() and GetTickCount() > self.LastSelTick + 100 then
                  self.SelectedTarget = nil
                  local num = 10000000
                  local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(99999999, false, "immortal")
                  for i = 1, #enemyList do
                        local unit = enemyList[i]
                        local distance = mousePos:DistanceTo(unit.pos)
                        if distance < 150 and distance < num then
                              self.SelectedTarget = unit
                              num = distance
                        end
                  end
                  self.LastSelTick = GetTickCount()
            end
      end
      function __gsoTS:Draw()
            if gsoSDK.Menu.gsodraw.selected.enabled:Value() then
                  if self.SelectedTarget and not self.SelectedTarget.dead and self.SelectedTarget.isTargetable and self.SelectedTarget.visible and self.SelectedTarget.valid then
                        DrawCircle(self.SelectedTarget.pos, gsoSDK.Menu.gsodraw.selected.radius:Value(), gsoSDK.Menu.gsodraw.selected.width:Value(), gsoSDK.Menu.gsodraw.selected.color:Value())
                  end
            end
            if gsoSDK.Menu.gsodraw.lasthit.enabled:Value() or gsoSDK.Menu.gsodraw.almostlasthit.enabled:Value() then
                  for i = 1, #self.FarmMinions do
                        local minion = self.FarmMinions[i]
                        if minion.LastHitable and gsoSDK.Menu.gsodraw.lasthit.enabled:Value() then
                              DrawCircle(minion.Minion.pos, gsoSDK.Menu.gsodraw.lasthit.radius:Value(), gsoSDK.Menu.gsodraw.lasthit.width:Value(), gsoSDK.Menu.gsodraw.lasthit.color:Value())
                        elseif minion.AlmostLastHitable and gsoSDK.Menu.gsodraw.almostlasthit.enabled:Value() then
                              DrawCircle(minion.Minion.pos, gsoSDK.Menu.gsodraw.almostlasthit.radius:Value(), gsoSDK.Menu.gsodraw.almostlasthit.width:Value(), gsoSDK.Menu.gsodraw.almostlasthit.color:Value())
                        end
                  end
            end
      end
--[[
▒█░▒█ ▀▀█▀▀ ▀█▀ ▒█░░░ ▀█▀ ▀▀█▀▀ ▀█▀ ▒█▀▀▀ ▒█▀▀▀█ 
▒█░▒█ ░▒█░░ ▒█░ ▒█░░░ ▒█░ ░▒█░░ ▒█░ ▒█▀▀▀ ░▀▀▀▄▄ 
░▀▄▄▀ ░▒█░░ ▄█▄ ▒█▄▄█ ▄█▄ ░▒█░░ ▄█▄ ▒█▄▄▄ ▒█▄▄▄█ 
]]
class "__gsoUtilities"
      function __gsoUtilities:__init()
            self.MinLatency = GameLatency() * 0.001
            self.MaxLatency = GameLatency() * 0.001
            self.Min = GameLatency() * 0.001
            self.LAT = {}
            self.DA = {}
      end
      function __gsoUtilities:DelayedActions()
            local cacheDA = {}
            for i = 1, #self.DA do
                  local t = self.DA[i]
                  if GameTimer() > t.StartTime + t.Delay then
                        t.Func()
                  else
                        cacheDA[#cacheDA+1] = t
                  end
            end
            self.DA = cacheDA
      end
      function __gsoUtilities:Latencies()
            local lat1 = 0
            local lat2 = 50
            local latency = GameLatency() * 0.001
            if latency < self.Min then
                  self.Min = latency
            end
            self.LAT[#self.LAT+1] = { endTime = GameTimer() + 1.5, Latency = latency }
            local cacheLatencies = {}
            for i = 1, #self.LAT do
                  local t = self.LAT[i]
                  if GameTimer() < t.endTime then
                        cacheLatencies[#cacheLatencies+1] = t
                        if t.Latency > lat1 then
                              lat1 = t.Latency
                              self.MaxLatency = lat1
                        end
                        if t.Latency < lat2 then
                              lat2 = t.Latency
                              self.MinLatency = lat2
                        end
                  end
            end
            self.LAT = cacheLatencies
      end
      function __gsoUtilities:Tick()
            self:DelayedActions()
            self:Latencies()
      end
      function __gsoUtilities:AddAction(func, delay)
            self.DA[#self.DA+1] = { StartTime = GameTimer(), Func = func, Delay = delay }
      end
      function __gsoUtilities:GetMaxLatency()
            return self.MaxLatency
      end
      function __gsoUtilities:GetMinLatency()
            return self.MinLatency
      end
      function __gsoUtilities:GetUserLatency()
            return self.Min
      end
--[[
▒█░░░ ▒█▀▀▀█ ░█▀▀█ ▒█▀▀▄ ▒█▀▀▀ ▒█▀▀█ 
▒█░░░ ▒█░░▒█ ▒█▄▄█ ▒█░▒█ ▒█▀▀▀ ▒█▄▄▀ 
▒█▄▄█ ▒█▄▄▄█ ▒█░▒█ ▒█▄▄▀ ▒█▄▄▄ ▒█░▒█ 
]]
class "__gsoLoader"
      function __gsoLoader:__init()
            -- LOAD LIBS
            gsoSDK.Spell = __gsoSpell()
            gsoSDK.Utilities = __gsoUtilities()
            gsoSDK.Cursor = __gsoCursor()
            gsoSDK.ObjectManager = __gsoOB()
            gsoSDK.Farm = __gsoFarm()
            gsoSDK.TS = __gsoTS()
            gsoSDK.Orbwalker = __gsoOrbwalker()
            -----------------------------------------------------------
            gsoSDK.TS:CreateMenu()
            gsoSDK.Orbwalker:CreateMenu()
            gsoSDK.Menu:MenuElement({name = "Drawings", id = "gsodraw", leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/circles.png", type = MENU })
            gsoSDK.Menu.gsodraw:MenuElement({name = "Enabled",  id = "enabled", value = true})
            gsoSDK.Spell:CreateDrawMenu()
            gsoSDK.TS:CreateDrawMenu()
            gsoSDK.Cursor:CreateDrawMenu()
            gsoSDK.Orbwalker:CreateDrawMenu()
            Callback.Add('Tick', function()
                  gsoSDK.ObjectManager:Tick()
                  gsoSDK.Spell:SaveWaypoints(gsoSDK.ObjectManager:GetEnemyHeroes(10000, false, "spell"))
                  gsoSDK.Utilities:Tick()
                  gsoSDK.Cursor:Tick()
                  local enemyMinions = gsoSDK.ObjectManager:GetEnemyMinions(1500, false)
                  local allyMinions = gsoSDK.ObjectManager:GetAllyMinions(1500, false)
                  gsoSDK.Farm:Tick(allyMinions, enemyMinions)
                  gsoSDK.TS:Tick()
                  gsoSDK.Orbwalker:Tick()
                  gsoSDK.ChampTick()
            end)
            Callback.Add('WndMsg', function(msg, wParam)
                  gsoSDK.TS:WndMsg(msg, wParam)
                  gsoSDK.Orbwalker:WndMsg(msg, wParam)
                  gsoSDK.Spell:WndMsg(msg, wParam)
                  gsoSDK.ChampWndMsg(msg, wParam)
            end)
            Callback.Add('Draw', function()
                  if not gsoSDK.Menu.gsodraw.enabled:Value() then return end
                  gsoSDK.TS:Draw()
                  gsoSDK.Cursor:Draw()
                  gsoSDK.Spell:Draw()
                  gsoSDK.Orbwalker:Draw()
                  gsoSDK.ChampDraw()
            end)
            Callback.Add('GameEnd', function()
                  gsoSDK.Orbwalker:EnableGosOrb()
                  gsoSDK.Orbwalker:EnableIcOrb()
            end)
            Callback.Add('UnLoad', function()
                  gsoSDK.Orbwalker:EnableGosOrb()
                  gsoSDK.Orbwalker:EnableIcOrb()
            end)
      end
--[[
▀▀█▀▀ ▒█░░▒█ ▀█▀ ▀▀█▀▀ ▒█▀▀█ ▒█░▒█ 
░▒█░░ ▒█▒█▒█ ▒█░ ░▒█░░ ▒█░░░ ▒█▀▀█ 
░▒█░░ ▒█▄▀▄█ ▄█▄ ░▒█░░ ▒█▄▄█ ▒█░▒█ 
]]
class "__gsoTwitch"
      function __gsoTwitch:__init()
            gsoSDK.Menu = MenuElement({name = "Gamsteron Twitch", id = "gsotwitch", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/twitch.png" })
            __gsoLoader()
            self.HasQBuff = false
            self.QBuffDuration = 0
            self.HasQASBuff = false
            self.QASBuffDuration = 0
            self.Recall = true
            self.EBuffs = {}
            gsoSDK.Orbwalker:SetSpellMoveDelays( { q = 0, w = 0.2, e = 0.2, r = 0 } )
            gsoSDK.Orbwalker:SetSpellAttackDelays( { q = 0, w = 0.33, e = 0.33, r = 0 } )
            self:SetSpellData()
            self:CreateMenu()
            self:CreateDrawMenu()
            self:AddDrawEvent()
            self:AddTickEvent()
      end
      function __gsoTwitch:SetSpellData()
            self.wData = { delay = 0.25, radius = 150, range = 950, speed = 1400, collision = false, sType = "circular" }
      end
      function __gsoTwitch:CreateMenu()
            gsoSDK.Menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
                  gsoSDK.Menu.qset:MenuElement({id = "combo", name = "Use Q Combo", value = false})
                  gsoSDK.Menu.qset:MenuElement({id = "harass", name = "Use Q Harass", value = false})
                  gsoSDK.Menu.qset:MenuElement({id = "recallkey", name = "Invisible Recall Key", key = string.byte("T"), value = false, toggle = true})
                  gsoSDK.Menu.qset.recallkey:Value(false)
                  gsoSDK.Menu.qset:MenuElement({id = "note1", name = "Note: Key should be diffrent than recall key", type = SPACE})
            gsoSDK.Menu:MenuElement({name = "W settings", id = "wset", type = MENU })
                  gsoSDK.Menu.wset:MenuElement({id = "stopq", name = "Stop if Q invisible", value = true})
                  gsoSDK.Menu.wset:MenuElement({id = "stopwult", name = "Stop if R", value = false})
                  gsoSDK.Menu.wset:MenuElement({id = "combo", name = "Use W Combo", value = true})
                  gsoSDK.Menu.wset:MenuElement({id = "harass", name = "Use W Harass", value = false})
                  gsoSDK.Menu.wset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gsoSDK.Menu:MenuElement({name = "E settings", id = "eset", type = MENU })
                  gsoSDK.Menu.eset:MenuElement({id = "combo", name = "Use E Combo", value = true})
                  gsoSDK.Menu.eset:MenuElement({id = "harass", name = "Use E Harass", value = false})
                  gsoSDK.Menu.eset:MenuElement({id = "killsteal", name = "Use E KS", value = true})
                  gsoSDK.Menu.eset:MenuElement({id = "stacks", name = "X stacks", value = 6, min = 1, max = 6, step = 1 })
                  gsoSDK.Menu.eset:MenuElement({id = "enemies", name = "X enemies", value = 1, min = 1, max = 5, step = 1 })
      end
      function __gsoTwitch:CreateDrawMenu()
            gsoSDK.Menu.gsodraw:MenuElement({name = "Q Timer",  id = "qtimer", type = MENU})
                  gsoSDK.Menu.gsodraw.qtimer:MenuElement({id = "enabled", name = "Enabled", value = true})
                  gsoSDK.Menu.gsodraw.qtimer:MenuElement({id = "color", name = "Color ", color = Draw.Color(200, 65, 255, 100)})
            gsoSDK.Menu.gsodraw:MenuElement({name = "Q Invisible Range",  id = "qinvisible", type = MENU})
                  gsoSDK.Menu.gsodraw.qinvisible:MenuElement({id = "enabled", name = "Enabled", value = true})
                  gsoSDK.Menu.gsodraw.qinvisible:MenuElement({id = "color", name = "Color ", color = Draw.Color(200, 255, 0, 0)})
            gsoSDK.Menu.gsodraw:MenuElement({name = "Q Notification Range",  id = "qnotification", type = MENU})
                  gsoSDK.Menu.gsodraw.qnotification:MenuElement({id = "enabled", name = "Enabled", value = true})
                  gsoSDK.Menu.gsodraw.qnotification:MenuElement({id = "color", name = "Color ", color = Draw.Color(200, 188, 77, 26)})
      end
      --[[
      gsoOrbwalker:AttackSpeed(function()
            local num = gsoGameTimer() - champInfo.QASEndTime + gsoExtra.maxLatency
            if num > -champInfo.windUpNoQ and num < 2 then
                  return champInfo.asNoQ
            end
            return gsoMyHero.attackSpeed
      end)
      --]]
      function __gsoTwitch:AddDrawEvent()
            gsoSDK.ChampDraw = function()
                  local lastQ, lastQk, lastW, lastWk, lastE, lastEk, lastR, lastRk = gsoSDK.Spell:GetLastSpellTimers()
                  if Game.Timer() < lastQk + 16 then
                        local pos2D = myHero.pos:To2D()
                        local posX = pos2D.x - 50
                        local posY = pos2D.y
                        local num1 = 1.35-(Game.Timer()-lastQk)
                        local timerEnabled = gsoSDK.Menu.gsodraw.qtimer.enabled:Value()
                        local timerColor = gsoSDK.Menu.gsodraw.qtimer.color:Value()
                        if num1 > 0.001 then
                              if timerEnabled then
                                    local str1 = tostring(math.floor(num1*1000))
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
                        elseif self.HasQBuff then
                              local num2 = math.floor(1000*(self.QBuffDuration-Game.Timer()))
                              if num2 > 1 then
                                    if gsoSDK.Menu.gsodraw.qinvisible.enabled:Value() then
                                          Draw.Circle(myHero.pos, 500, 1, gsoSDK.Menu.gsodraw.qinvisible.color:Value())
                                    end
                                    if gsoSDK.Menu.gsodraw.qnotification.enabled:Value() then
                                          Draw.Circle(myHero.pos, 800, 1, gsoSDK.Menu.gsodraw.qnotification.color:Value())
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
      end
      function __gsoTwitch:AddTickEvent()
            gsoSDK.ChampTick = function()
                  --[[q buff best orbwalker dps
                  if gsoGetTickCount() - gsoSpellTimers.lqk < 500 and gsoGetTickCount() > champInfo.lastASCheck + 1000 then
                  champInfo.asNoQ = gsoMyHero.attackSpeed
                  champInfo.windUpNoQ = gsoTimers.windUpTime
                  champInfo.lastASCheck = gsoGetTickCount()
                  end--]]
                  --[[disable attack
                  local num = 1150 - (gsoGetTickCount() - (gsoSpellTimers.lqk + (gsoExtra.maxLatency*1000)))
                  if num < (gsoTimers.windUpTime*1000)+50 and num > - 50 then
                  return false
                  end--]]
                  --qrecall
                  local lastQ, lastQk, lastW, lastWk, lastE, lastEk, lastR, lastRk = gsoSDK.Spell:GetLastSpellTimers()
                  if gsoSDK.Menu.qset.recallkey:Value() == self.Recall then
                        Control.KeyDown(HK_Q)
                        Control.KeyUp(HK_Q)
                        Control.KeyDown(string.byte("B"))
                        Control.KeyUp(string.byte("B"))
                        self.Recall = not self.Recall
                  end
                  --qbuff
                  local qDuration = gsoSDK.Spell:GetBuffDuration(myHero, "globalcamouflage")--twitchhideinshadows
                  self.HasQBuff = qDuration > 0
                  self.QBuffDuration = qDuration > 0 and Game.Timer() + qDuration or 0
                  --qasbuff
                  local qasDuration = gsoSDK.Spell:GetBuffDuration(myHero, "twitchhideinshadowsbuff")
                  self.HasQASBuff = qasDuration > 0
                  self.QASBuffDuration = qasDuration > 0 and Game.Timer() + qasDuration or 0
                  --handle e buffs
                  local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1200, false, "spell")
                  for i = 1, #enemyList do
                        local hero  = enemyList[i]
                        local nID   = hero.networkID
                        if not self.EBuffs[nID] then
                              self.EBuffs[nID] = { count = 0, durT = 0 }
                        end
                        if not hero.dead then
                              local hasB = false
                              local cB = self.EBuffs[nID].count
                              local dB = self.EBuffs[nID].durT
                              for i = 0, hero.buffCount do
                                    local buff = hero:GetBuff(i)
                                    if buff and buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
                                          hasB = true
                                          if cB < 6 and buff.duration > dB then
                                                self.EBuffs[nID].count = cB + 1
                                                self.EBuffs[nID].durT = buff.duration
                                          else
                                                self.EBuffs[nID].durT = buff.duration
                                          end
                                          break
                                    end
                              end
                              if not hasB then
                                    self.EBuffs[nID].count = 0
                                    self.EBuffs[nID].durT = 0
                              end
                        end
                  end
                  -- Combo / Harass
                  if not gsoSDK.Orbwalker:CanMove() then
                        return
                  end
                  --EKS
                  if gsoSDK.Menu.eset.killsteal:Value() and gsoSDK.Spell:IsReady(_E, { q = 0, w = 0.25, e = 0.5, r = 0 } ) then
                        for i = 1, #enemyList do
                              local hero = enemyList[i]
                              local buffCount = self.EBuffs[hero.networkID] and self.EBuffs[hero.networkID].count or 0
                              if buffCount > 0 and myHero.pos:DistanceTo(hero.pos) < 1200 - 35 then
                                    local elvl = myHero:GetSpellData(_E).level
                                    local basedmg = 10 + ( elvl * 10 )
                                    local perstack = ( 10 + (5*elvl) ) * buffCount
                                    local bonusAD = myHero.bonusDamage * 0.25 * buffCount
                                    local bonusAP = myHero.ap * 0.2 * buffCount
                                    local edmg = basedmg + perstack + bonusAD + bonusAP
                                    if gsoSDK.Spell:GetDamage(hero, { dmgType = "ad", dmgAD = edmg }) >= hero.health + (1.5*hero.hpRegen) and gsoSDK.Spell:CastSpell(HK_E) then
                                          break
                                    end
                              end
                        end
                  end
                  local isCombo = gsoSDK.Menu.orb.keys.combo:Value()
                  local isHarass = gsoSDK.Menu.orb.keys.harass:Value()
                  if isCombo or isHarass then
                        local target = gsoSDK.TS:GetComboTarget()
                        if target and gsoSDK.Orbwalker:CanAttack() then
                              return
                        end
                        -- Q
                        local isComboQ = isCombo and gsoSDK.Menu.qset.combo:Value()
                        local isHarassQ = isHarass and gsoSDK.Menu.qset.harass:Value()
                        if isComboQ or isHarassQ then
                              if target and gsoSDK.Spell:IsReady(_Q, { q = 0.5, w = 0.33, e = 0.33, r = 0.1 } ) and gsoSDK.Spell:CastSpell(HK_Q) then
                                    return
                              end
                        end
                        --W
                        local isComboW = gsoSDK.Menu.orb.keys.combo:Value() and gsoSDK.Menu.wset.combo:Value()
                        local isHarassW = gsoSDK.Menu.orb.keys.harass:Value() and gsoSDK.Menu.wset.harass:Value()
                        local isKeyW = isComboW or isHarassW
                        local stopWIfR = gsoSDK.Menu.wset.stopwult:Value() and Game.Timer() < lastRk + 5.45
                        local stopWIfQ = gsoSDK.Menu.wset.stopq:Value() and self.HasQBuff
                        if isKeyW and not stopWIfR and not stopWIfQ and gsoSDK.Spell:IsReady(_W, { q = 0, w = 0.5, e = 0.25, r = 0 } ) then
                              if target then
                                    WTarget = target
                              else
                                    WTarget = gsoSDK.TS:GetTarget(gsoSDK.ObjectManager:GetEnemyHeroes(950, false, "spell"), false)
                              end
                              if WTarget and gsoSDK.Spell:CastSpell(HK_W, WTarget, myHero.pos, self.wData, gsoSDK.Menu.wset.hitchance:Value()) then
                                    return
                              end
                        end
                        --E
                        local isComboE = gsoSDK.Menu.orb.keys.combo:Value() and gsoSDK.Menu.eset.combo:Value()
                        local isHarassE = gsoSDK.Menu.orb.keys.harass:Value() and gsoSDK.Menu.eset.harass:Value()
                        local isKeyE = isComboE or isHarassE
                        if isKeyE and gsoSDK.Spell:IsReady(_E, { q = 0, w = 0.25, e = 0.5, r = 0 } ) then
                              local countE = 0
                              local xStacks = gsoSDK.Menu.eset.stacks:Value()
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1200, false, "spell")
                              for i = 1, #enemyList do
                                    local hero = enemyList[i]
                                    local buffCount = self.EBuffs[hero.networkID] and self.EBuffs[hero.networkID].count or 0
                                    if hero and myHero.pos:DistanceTo(hero.pos) < 1200 - 35 and buffCount >= xStacks then
                                          countE = countE + 1
                                    end
                              end
                              if countE >= gsoSDK.Menu.eset.enemies:Value() and gsoSDK.Spell:CastSpell(HK_E) then
                                    return
                              end
                        end
                  end
            end
      end
--[[
▒█▀▀▀ ▒█▀▀▀█ ▒█▀▀█ ▒█▀▀▀ ░█▀▀█ ▒█░░░ 
▒█▀▀▀ ░▄▄▄▀▀ ▒█▄▄▀ ▒█▀▀▀ ▒█▄▄█ ▒█░░░ 
▒█▄▄▄ ▒█▄▄▄█ ▒█░▒█ ▒█▄▄▄ ▒█░▒█ ▒█▄▄█ 
]]
class "__gsoEzreal"
      function __gsoEzreal:__init()
            self.FarmTimer = 0
            self.ShouldWaitTime = 0
            self.ShouldWait = false
            self.FarmMinions = {}
            gsoSDK.Menu = MenuElement({name = "Gamsteron Ezreal", id = "gsoezreal", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ezreal.png" })
            __gsoLoader()
            self.res = Game.Resolution()
            self.resX = self.res.x
            self.resY = self.res.y
            gsoSDK.Orbwalker:SetSpellMoveDelays( { q = 0.2, w = 0.2, e = 0.2, r = 1 } )
            gsoSDK.Orbwalker:SetSpellAttackDelays( { q = 0.33, w = 0.33, e = 0.33, r = 1.13 } )
            self:SetSpellData()
            self:CreateMenu()
            self:CreateDrawMenu()
            self:AddDrawEvent()
            self:AddTickEvent()
      end
      function __gsoEzreal:SetSpellData()
            self.qData = { delay = 0.25, radius = 60, range = 1150, speed = 2000, collision = true, sType = "line" }
            self.wData = { delay = 0.25, radius = 80, range = 1150, speed = 1550, collision = false, sType = "line" }
      end
      function __gsoEzreal:CreateMenu()
            gsoSDK.Menu:MenuElement({name = "Auto Q", id = "autoq", type = MENU })
                  gsoSDK.Menu.autoq:MenuElement({id = "enable", name = "Enable", value = true, key = string.byte("T"), toggle = true})
                  gsoSDK.Menu.autoq:MenuElement({id = "mana", name = "Q Auto min. mana percent", value = 50, min = 0, max = 100, step = 1 })
                  gsoSDK.Menu.autoq:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gsoSDK.Menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
                  gsoSDK.Menu.qset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
                  gsoSDK.Menu.qset:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.qset:MenuElement({id = "harass", name = "Harass", value = false})
                  gsoSDK.Menu.qset:MenuElement({id = "laneclear", name = "LaneClear", value = false})
                  gsoSDK.Menu.qset:MenuElement({id = "lasthit", name = "LastHit", value = true})
                  gsoSDK.Menu.qset:MenuElement({id = "qlh", name = "Q LastHit min. mana percent", value = 10, min = 0, max = 100, step = 1 })
                  gsoSDK.Menu.qset:MenuElement({id = "qlc", name = "Q LaneClear min. mana percent", value = 50, min = 0, max = 100, step = 1 })
            gsoSDK.Menu:MenuElement({name = "W settings", id = "wset", type = MENU })
                  gsoSDK.Menu.wset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
                  gsoSDK.Menu.wset:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.wset:MenuElement({id = "harass", name = "Harass", value = false})
      end
      function __gsoEzreal:CreateDrawMenu()
            gsoSDK.Menu.gsodraw:MenuElement({name = "Auto Q", id = "autoq", type = MENU })
                  gsoSDK.Menu.gsodraw.autoq:MenuElement({id = "enabled", name = "Enabled", value = true})
                  gsoSDK.Menu.gsodraw.autoq:MenuElement({id = "size", name = "Text Size", value = 25, min = 1, max = 64, step = 1 })
                  gsoSDK.Menu.gsodraw.autoq:MenuElement({id = "custom", name = "Custom Position", value = false})
                  gsoSDK.Menu.gsodraw.autoq:MenuElement({id = "posX", name = "Text Position Width", value = self.resX * 0.5 - 150, min = 1, max = self.resX, step = 1 })
                  gsoSDK.Menu.gsodraw.autoq:MenuElement({id = "posY", name = "Text Position Height", value = self.resY * 0.5, min = 1, max = self.resY, step = 1 })
      end
      function __gsoEzreal:AddDrawEvent()
            gsoSDK.ChampDraw = function()
                  if gsoSDK.Menu.gsodraw.autoq.enabled:Value() then
                        local mePos = myHero.pos:To2D()
                        local isCustom = gsoSDK.Menu.gsodraw.autoq.custom:Value()
                        local posX = isCustom and gsoSDK.Menu.gsodraw.autoq.posX:Value() or mePos.x - 50
                        local posY = isCustom and gsoSDK.Menu.gsodraw.autoq.posY:Value() or mePos.y
                        if gsoSDK.Menu.autoq.enable:Value() then
                              DrawText("Auto Q Enabled", gsoSDK.Menu.gsodraw.autoq.size:Value(), posX, posY, DrawColor(255, 000, 255, 000)) 
                        else
                              DrawText("Auto Q Disabled", gsoSDK.Menu.gsodraw.autoq.size:Value(), posX, posY, DrawColor(255, 255, 000, 000)) 
                        end
                  end
            end
      end
      function __gsoEzreal:AddTickEvent()
            gsoSDK.ChampTick = function()
                  -- Q Farm Tick
                  if gsoSDK.Menu.qset.lasthit:Value() or gsoSDK.Menu.qset.laneclear:Value() then
                        self:QFarmTick()
                  end
                  -- Enable Attack
                  if not gsoSDK.Orbwalker.AttackEnabled and GameTimer() > self.FarmTimer + 0.77 then
                        gsoSDK.Orbwalker.AttackEnabled = true
                  end
                  -- E manual
                  gsoSDK.Spell:CastManualSpell(_E, { q = 0.33, w = 0.33, e = 0.5, r = 1.13 })
                  -- Is Attacking
                  if not gsoSDK.Orbwalker:CanMove() then
                        return
                  end
                  -- Get Mode
                  local mode = gsoSDK.Orbwalker:GetMode()
                  -- Can Attack
                  local AATarget = gsoSDK.TS:GetComboTarget()
                  if AATarget and mode ~= "None" and gsoSDK.Orbwalker:CanAttack() then
                        return
                  end
                  -- Q
                  if gsoSDK.Spell:IsReady(_Q, { q = 0.5, w = 0.33, e = 0.33, r = 1.13 } ) then
                        -- Get Mana Percent
                        local manaPercent = 100 * myHero.mana / myHero.maxMana
                        -- Auto
                        if mode == "None" and gsoSDK.Menu.autoq.enable:Value() and manaPercent > gsoSDK.Menu.autoq.mana:Value() then
                              local enemyHeroes = gsoSDK.ObjectManager:GetEnemyHeroes(1150, false, "spell")
                              for i = 1, #enemyHeroes do
                                    local unit = enemyHeroes[i]
                                    if unit and gsoSDK.Spell:CastSpell(HK_Q, unit, myHero.pos, self.qData, gsoSDK.Menu.autoq.hitchance:Value()) then
                                          return
                                    end
                              end
                        end
                        -- Combo / Harass
                        if (mode == "Combo" and gsoSDK.Menu.qset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.qset.harass:Value()) then
                              local QTarget
                              if AATarget then
                                    QTarget = AATarget
                              else
                                    QTarget = gsoSDK.TS:GetTarget(gsoSDK.ObjectManager:GetEnemyHeroes(1150, false, "spell"), false)
                              end
                              if QTarget and gsoSDK.Spell:CastSpell(HK_Q, QTarget, myHero.pos, self.qData, gsoSDK.Menu.qset.hitchance:Value()) then
                                    return
                              end
                        end
                        -- Lasthit / LaneClear
                        if self:QFarm(mode, manaPercent) then
                              return
                        end
                  end
                  -- W
                  if gsoSDK.Spell:IsReady(_W, { q = 0.33, w = 0.5, e = 0.33, r = 1.13 } ) then
                        if (mode == "Combo" and gsoSDK.Menu.wset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.wset.harass:Value()) then
                              local WTarget
                              if AATarget then
                                    WTarget = AATarget
                              else
                                    WTarget = gsoSDK.TS:GetTarget(gsoSDK.ObjectManager:GetEnemyHeroes(1000, false, "spell"), false)
                              end
                              if WTarget and gsoSDK.Spell:CastSpell(HK_W, WTarget, myHero.pos, self.wData, gsoSDK.Menu.wset.hitchance:Value()) then
                                    return
                              end
                        end
                  end
            end
      end
      -- START -> farm
      function __gsoEzreal:SetLastHitable(enemyMinion, time, damage, mode, allyMinions)
            if mode == "fast" then
                  local hpPred = gsoSDK.Farm:MinionHpPredFast(enemyMinion, allyMinions, time)
                  local lastHitable = hpPred - damage < 0
                  if lastHitable then self.IsLastHitable = true end
                  local almostLastHitable = lastHitable and false or gsoSDK.Farm:MinionHpPredFast(enemyMinion, allyMinions, myHero.attackData.animationTime * 3) - damage < 0
                  if almostLastHitable then
                        self.ShouldWait = true
                        self.ShouldWaitTime = GameTimer()
                  end
                  return { LastHitable =  lastHitable, Unkillable = hpPred < 0, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = enemyMinion }
            elseif mode == "accuracy" then
                  local hpPred = gsoSDK.Farm:MinionHpPredAccuracy(enemyMinion, time)
                  local lastHitable = hpPred - damage < 0
                  if lastHitable then self.IsLastHitable = true end
                  local almostLastHitable = lastHitable and false or gsoSDK.Farm:MinionHpPredFast(enemyMinion, allyMinions, myHero.attackData.animationTime * 3) - damage < 0
                  if almostLastHitable then
                        self.ShouldWait = true
                        self.ShouldWaitTime = GameTimer()
                  end
                  return { LastHitable =  lastHitable, Unkillable = hpPred < 0, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = enemyMinion }
            end
      end
      function __gsoEzreal:QFarmTick()
            if self.ShouldWait and GameTimer() > self.ShouldWaitTime + 0.25 then self.ShouldWait = false end
            local QDmg = ((25 * myHero:GetSpellData(_Q).level) - 10) + (1.1 * myHero.totalDamage) + (0.4 * myHero.ap)
            local enemyMinions = gsoSDK.ObjectManager:GetEnemyMinions(1120, false)
            local allyMinions = gsoSDK.ObjectManager:GetAllyMinions(1500, false)
            local lastHitMode = gsoSDK.Menu.ts.lasthitmode:Value() == 1 and "accuracy" or "fast"
            local FarmMinionsCache = {}
            for i = 1, #enemyMinions do
                  local enemyMinion = enemyMinions[i]
                  local FlyTime = myHero.pos:DistanceTo(enemyMinion.pos) / 2000
                  FarmMinionsCache[#FarmMinionsCache+1] = self:SetLastHitable(enemyMinion, FlyTime, QDmg, lastHitMode, allyMinions)
            end
            self.FarmMinions = FarmMinionsCache
      end
      function __gsoEzreal:QFarm(mode, manaPercent)
            local isLH = gsoSDK.Menu.qset.lasthit:Value() and mode == "Lasthit"
            local isLC = gsoSDK.Menu.qset.laneclear:Value() and mode == "Clear"
            local lastHit = isLH or isLC
            if lastHit and manaPercent > gsoSDK.Menu.qset.qlh:Value() then
                  for i = 1, #self.FarmMinions do
                        local enemyMinion = self.FarmMinions[i]
                        if enemyMinion.LastHitable then
                              local unit = enemyMinion.Minion
                              if unit.handle ~= gsoSDK.TS.LastHandle and not unit.pathing.hasMovePath and not gsoSDK.Spell:IsMinionCollision(unit, self.qData) and not unit.dead and gsoSDK.Spell:CastSpell(HK_Q, unit) then
                                    gsoSDK.Orbwalker.AttackEnabled = false
                                    self.FarmTimer = GameTimer()
                                    return true
                              end
                        end
                  end
            end
            if isLC and not self.ShouldWait and manaPercent > gsoSDK.Menu.qset.qlc:Value() then
                  -- Enemy Heroes
                  local enemyHeroes = gsoSDK.ObjectManager:GetEnemyHeroes(1150, false, "spell")
                  for i = 1, #enemyHeroes do
                        local unit = enemyHeroes[i]
                        if unit and gsoSDK.Spell:CastSpell(HK_Q, unit, myHero.pos, self.qData, gsoSDK.Menu.qset.hitchance:Value()) then
                              return true
                        end
                  end
                  -- LaneClear
                  for i = 1, #self.FarmMinions do
                        local enemyMinion = self.FarmMinions[i]
                        local unit = enemyMinion.Minion
                        if unit.handle ~= gsoSDK.TS.LastLCHandle and not unit.pathing.hasMovePath and not gsoSDK.Spell:IsMinionCollision(unit, self.qData) and not unit.dead and gsoSDK.Spell:CastSpell(HK_Q, unit) then
                              gsoSDK.Orbwalker.AttackEnabled = false
                              self.FarmTimer = GameTimer()
                              return true
                        end
                  end
            end
            return false
      end
      -- END -> farm
--[[
▒█░▄▀ ▒█▀▀▀█ ▒█▀▀█ 　 ▒█▀▄▀█ ░█▀▀█ ▒█░░▒█ 
▒█▀▄░ ▒█░░▒█ ▒█░▄▄ 　 ▒█▒█▒█ ▒█▄▄█ ▒█▒█▒█ 
▒█░▒█ ▒█▄▄▄█ ▒█▄▄█ 　 ▒█░░▒█ ▒█░▒█ ▒█▄▀▄█ 
]]
class "__gsoKogMaw"
      function __gsoKogMaw:__init()
            self.HasWBuff = false
            gsoSDK.Menu = MenuElement({name = "Gamsteron KogMaw", id = "gsokogmaw", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kog.png" })
            __gsoLoader()
            gsoSDK.Orbwalker:SetSpellMoveDelays( { q = 0.2, w = 0, e = 0.2, r = 0.2 } )
            gsoSDK.Orbwalker:SetSpellAttackDelays( { q = 0.33, w = 0, e = 0.33, r = 0.33 } )
            self:SetSpellData()
            self:CreateMenu()
            self:AddTickEvent()
            gsoSDK.Orbwalker:OnPreAttack(function(args)
                  local mode = gsoSDK.Orbwalker:GetMode()
                  local canW = (mode == "Combo" and gsoSDK.Menu.wset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.wset.harass:Value())
                  if canW and gsoSDK.Spell:IsReady(_W, { q = 0.33, w = 0.5, e = 0.33, r = 0.33 } ) then
                        local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(610 + ( 20 * myHero:GetSpellData(_W).level ) + myHero.boundingRadius - 35, true, "attack")
                        if #enemyList > 0 and gsoSDK.Spell:CastSpell(HK_W) then
                              args.Process = false
                              return
                        end
                  end
            end)
      end
      function __gsoKogMaw:SetSpellData()
            self.qData = { delay = 0.25, radius = 70, range = 1175, speed = 1650, collision = true, sType = "line" }
            self.eData = { delay = 0.25, radius = 120, range = 1280, speed = 1350, collision = false, sType = "line" }
            self.rData = { delay = 1.2, radius = 225, range = 0, speed = math.huge, collision = false, sType = "circular" }
      end
      function __gsoKogMaw:CreateMenu()
            gsoSDK.Menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
                  gsoSDK.Menu.qset:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.qset:MenuElement({id = "harass", name = "Harass", value = false})
                  gsoSDK.Menu.qset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gsoSDK.Menu:MenuElement({name = "W settings", id = "wset", type = MENU })
                  gsoSDK.Menu.wset:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.wset:MenuElement({id = "harass", name = "Harass", value = false})
                  gsoSDK.Menu.wset:MenuElement({id = "stopq", name = "Stop Q if has W buff", value = false})
                  gsoSDK.Menu.wset:MenuElement({id = "stope", name = "Stop E if has W buff", value = false})
                  gsoSDK.Menu.wset:MenuElement({id = "stopr", name = "Stop R if has W buff", value = false})
            gsoSDK.Menu:MenuElement({name = "E settings", id = "eset", type = MENU })
                  gsoSDK.Menu.eset:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.eset:MenuElement({id = "harass", name = "Harass", value = false})
                  gsoSDK.Menu.eset:MenuElement({id = "emana", name = "Minimum Mana %", value = 20, min = 1, max = 100, step = 1 })
                  gsoSDK.Menu.eset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gsoSDK.Menu:MenuElement({name = "R settings", id = "rset", type = MENU })
                  gsoSDK.Menu.rset:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.rset:MenuElement({id = "harass", name = "Harass", value = false})
                  gsoSDK.Menu.rset:MenuElement({id = "onlylow", name = "Only 0-40 % HP enemies", value = true})
                  gsoSDK.Menu.rset:MenuElement({id = "stack", name = "Stop at x stacks", value = 3, min = 1, max = 9, step = 1 })
                  gsoSDK.Menu.rset:MenuElement({id = "rmana", name = "Minimum Mana %", value = 20, min = 1, max = 100, step = 1 })
                  gsoSDK.Menu.rset:MenuElement({name = "KS", id = "ksmenu", type = MENU })
                        gsoSDK.Menu.rset.ksmenu:MenuElement({id = "ksr", name = "KS - Enabled", value = true})
                        gsoSDK.Menu.rset.ksmenu:MenuElement({id = "csksr", name = "KS -> Check R stacks", value = false})
                  gsoSDK.Menu.rset:MenuElement({name = "Semi Manual", id = "semirkog", type = MENU })
                        gsoSDK.Menu.rset.semirkog:MenuElement({name = "Semi-Manual Key", id = "semir", key = string.byte("T")})
                        gsoSDK.Menu.rset.semirkog:MenuElement({name = "Check R stacks", id = "semistacks", value = false})
                        gsoSDK.Menu.rset.semirkog:MenuElement({name = "Only 0-40 % HP enemies", id = "semilow",  value = false})
                        gsoSDK.Menu.rset.semirkog:MenuElement({name = "Use on:", id = "useon", type = MENU })
                              gsoSDK.ObjectManager:OnEnemyHeroLoad(function(hero) gsoSDK.Menu.rset.semirkog.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
                  gsoSDK.Menu.rset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
      end
      function __gsoKogMaw:AddTickEvent()
            gsoSDK.ChampTick = function()
                  -- Is Attacking
                  if not gsoSDK.Orbwalker:CanMove() then
                        return
                  end
                  -- Get Mode
                  local mode = gsoSDK.Orbwalker:GetMode()
                  -- Can Attack
                  local AATarget = gsoSDK.TS:GetComboTarget()
                  if AATarget and mode ~= "None" and gsoSDK.Orbwalker:CanAttack() then
                        return
                  end
                  -- W
                  local canW = (mode == "Combo" and gsoSDK.Menu.wset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.wset.harass:Value())
                  if canW and gsoSDK.Orbwalker:IsBeforeAttack(0.55) and gsoSDK.Spell:IsReady(_W, { q = 0.33, w = 0.5, e = 0.33, r = 0.33 } ) then
                        local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(610 + ( 20 * myHero:GetSpellData(_W).level ) + myHero.boundingRadius - 35, true, "attack")
                        if #enemyList > 0 and gsoSDK.Spell:CastSpell(HK_W) then
                              return
                        end
                  end
                  -- Check W Buff
                  local HasWBuff = false
                  for i = 0, myHero.buffCount do
                        local buff = myHero:GetBuff(i)
                        if buff and buff.count > 0 and buff.duration > 0 and buff.name == "KogMawBioArcaneBarrage" then
                              HasWBuff = true
                              break
                        end
                  end
                  self.HasWBuff = HasWBuff
                  -- Get Mana Percent
                  local manaPercent = 100 * myHero.mana / myHero.maxMana
                  -- Save Mana
                  local wMana = 40 - ( myHero:GetSpellData(_W).currentCd * myHero.mpRegen )
                  local meMana = myHero.mana - wMana
                  if not AATarget then
                        if GameTimer() < gsoSDK.Spell.LastW + 0.3 or GameTimer() < gsoSDK.Spell.LastWk + 0.3 then
                              return
                        end
                  end
                  -- R
                  if meMana > myHero:GetSpellData(_R).mana and gsoSDK.Spell:IsReady(_R, { q = 0.33, w = 0.15, e = 0.33, r = 0.5 } ) then
                        self.rData.range = 900 + 300 * myHero:GetSpellData(_R).level
                        local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(self.rData.range, false, "spell")
                        local rStacks = gsoSDK.Spell:GetBuffCount(myHero, "kogmawlivingartillerycost") < gsoSDK.Menu.rset.stack:Value()
                        local checkRStacksKS = gsoSDK.Menu.rset.ksmenu.csksr:Value()
                        -- KS
                        if gsoSDK.Menu.rset.ksmenu.ksr:Value() and ( not checkRStacksKS or rStacks ) then
                              local rTargets = {}
                              for i = 1, #enemyList do
                                    local hero = enemyList[i]
                                    local baseRDmg = 60 + ( 40 * myHero:GetSpellData(_R).level ) + ( myHero.bonusDamage * 0.65 ) + ( myHero.ap * 0.25 )
                                    local rMultipier = math.floor(100 - ( ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth ))
                                    local rDmg = rMultipier > 60 and baseRDmg * 2 or baseRDmg * ( 1 + ( rMultipier * 0.00833 ) )
                                    rDmg = gsoSDK.Spell:CalculateDmg(hero, { dmgAP = rDmg, dmgType = "ap" } )
                                    local unitKillable = rDmg > hero.health + (hero.hpRegen * 2)
                                    if unitKillable then
                                          rTargets[#rTargets+1] = hero
                                    end
                              end
                              local t = gsoSDK.TS:GetTarget(rTargets, true)
                              if t and gsoSDK.Spell:CastSpell(HK_R, t, myHero.pos, self.rData, gsoSDK.Menu.rset.hitchance:Value()) then
                                    return
                              end
                        end
                        -- SEMI MANUAL
                        local checkRStacksSemi = gsoSDK.Menu.rset.semirkog.semistacks:Value()
                        if gsoSDK.Menu.rset.semirkog.semir:Value() and ( not checkRStacksSemi or rStacks ) then
                              local onlyLowR = gsoSDK.Menu.rset.semirkog.semilow:Value()
                              local rTargets = {}
                              if onlyLowR then
                                    for i = 1, #enemyList do
                                          local hero = enemyList[i]
                                          if hero and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth < 40 then
                                                rTargets[#rTargets+1] = hero
                                          end
                                    end
                              else
                                    rTargets = enemyList
                              end
                              local t = gsoSDK.TS:GetTarget(rTargets, true)
                              if t and gsoSDK.Spell:CastSpell(HK_R, t, myHero.pos, self.rData, gsoSDK.Menu.rset.hitchance:Value()) then
                                    return
                              end
                        end
                        -- Combo / Harass
                        if (mode == "Combo" and gsoSDK.Menu.rset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.rset.harass:Value()) then
                              local stopRIfW = gsoSDK.Menu.wset.stopr:Value() and self.HasWBuff
                              if not stopRIfW and rStacks and manaPercent > gsoSDK.Menu.rset.rmana:Value() then
                                    local onlyLowR = gsoSDK.Menu.rset.onlylow:Value()
                                    local AATarget2
                                    if onlyLowR and AATarget and ( AATarget.health * 100 ) / AATarget.maxHealth > 39 then
                                          AATarget2 = nil
                                    else
                                          AATarget2 = AATarget
                                    end
                                    local t
                                    if AATarget2 then
                                          t = AATarget2
                                    else
                                          local rTargets = {}
                                          if onlyLowR then
                                                for i = 1, #enemyList do
                                                      local hero = enemyList[i]
                                                      if hero and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth < 40 then
                                                            rTargets[#rTargets+1] = hero
                                                      end
                                                end
                                          else
                                                rTargets = enemyList
                                          end
                                          t = gsoSDK.TS:GetTarget(rTargets, true)
                                    end
                                    if t and gsoSDK.Spell:CastSpell(HK_R, t, myHero.pos, self.rData, gsoSDK.Menu.rset.hitchance:Value()) then
                                          return
                                    end
                              end
                        end
                  end
                  -- Q
                  local stopQIfW = gsoSDK.Menu.wset.stopq:Value() and self.HasWBuff
                  if not stopQIfW and meMana > myHero:GetSpellData(_Q).mana and gsoSDK.Spell:IsReady(_Q, { q = 0.5, w = 0.15, e = 0.33, r = 0.33 } ) then
                        -- Combo / Harass
                        if (mode == "Combo" and gsoSDK.Menu.qset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.qset.harass:Value()) then
                              local t
                              if AATarget then
                                    t = AATarget
                              else
                                    t = gsoSDK.TS:GetTarget(gsoSDK.ObjectManager:GetEnemyHeroes(1175, false, "spell"), true)
                              end
                              if t and gsoSDK.Spell:CastSpell(HK_Q, t, myHero.pos, self.qData, gsoSDK.Menu.qset.hitchance:Value()) then
                                    return
                              end
                        end
                  end
                  -- E
                  local stopEifW = gsoSDK.Menu.wset.stope:Value() and self.HasWBuff
                  if not stopEifW and manaPercent > gsoSDK.Menu.eset.emana:Value() and meMana > myHero:GetSpellData(_E).mana and gsoSDK.Spell:IsReady(_E, { q = 0.33, w = 0.15, e = 0.5, r = 0.33 } ) then
                        if (mode == "Combo" and gsoSDK.Menu.eset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.eset.harass:Value()) then
                              local t
                              if AATarget then
                                    t = AATarget
                              else
                                    t = gsoSDK.TS:GetTarget(gsoSDK.ObjectManager:GetEnemyHeroes(1280, false, "spell"), true)
                              end
                              if t and gsoSDK.Spell:CastSpell(HK_E, t, myHero.pos, self.eData, gsoSDK.Menu.eset.hitchance:Value()) then
                                    return
                              end
                        end
                  end
            end
      end
--[[
▒█░░▒█ ░█▀▀█ ▒█▀▀█ ▒█░▒█ ▒█▀▀▀█ 
░▒█▒█░ ▒█▄▄█ ▒█▄▄▀ ▒█░▒█ ░▀▀▀▄▄ 
░░▀▄▀░ ▒█░▒█ ▒█░▒█ ░▀▄▄▀ ▒█▄▄▄█ 
]]
class "__gsoVarus"
      function __gsoVarus:__init()
            self.HasQBuff = false
            gsoSDK.Menu = MenuElement({name = "Gamsteron Varus", id = "gsovarus", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gsovarussf3f.png" })
            __gsoLoader()
            gsoSDK.Orbwalker:SetSpellMoveDelays( { q = 0.2, w = 0, e = 0.2, r = 0.2 } )
            gsoSDK.Orbwalker:SetSpellAttackDelays( { q = 0.33, w = 0, e = 0.33, r = 0.33 } )
            self:SetSpellData()
            self:CreateMenu()
            self:AddTickEvent()
      end
      function __gsoVarus:SetSpellData()
            self.qData = { delay = 0.1, radius = 70, range = 1650, speed = 1900, collision = false, sType = "line" }
            self.eData = { delay = 0.5, radius = 235, range = 925, speed = 1500, collision = false, sType = "circular" }
            self.rData = { delay = 0.25, radius = 120, range = 1075, speed = 1950, collision = false, sType = "line" }
      end
      function __gsoVarus:CreateMenu()
            gsoSDK.Menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
                  gsoSDK.Menu.qset:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.qset:MenuElement({id = "harass", name = "Harass", value = false})
                  gsoSDK.Menu.qset:MenuElement({id = "stacks", name = "If enemy has 3 W stacks [ W passive ]", value = true})
                  gsoSDK.Menu.qset:MenuElement({id = "active", name = "If varus has W buff [ W active ]", value = true})
                  gsoSDK.Menu.qset:MenuElement({id = "range", name = "No enemies in AA range", value = true})
                  gsoSDK.Menu.qset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gsoSDK.Menu:MenuElement({name = "W settings", id = "wset", type = MENU })
                  gsoSDK.Menu.wset:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.wset:MenuElement({id = "harass", name = "Harass", value = false})
                  gsoSDK.Menu.wset:MenuElement({id = "whp", name = "min. hp %", value = 50, min = 1, max = 100, step = 1})
            gsoSDK.Menu:MenuElement({name = "E settings", id = "eset", type = MENU })
                  gsoSDK.Menu.eset:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.eset:MenuElement({id = "harass", name = "Harass", value = false})
                  gsoSDK.Menu.eset:MenuElement({id = "range", name = "No enemies in AA range", value = true})
                  gsoSDK.Menu.eset:MenuElement({id = "stacks", name = "If enemy has 3 W stacks [ W passive ]", value = false})
                  gsoSDK.Menu.eset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gsoSDK.Menu:MenuElement({name = "R settings", id = "rset", type = MENU })
                  gsoSDK.Menu.rset:MenuElement({id = "combo", name = "Use R Combo", value = true})
                  gsoSDK.Menu.rset:MenuElement({id = "harass", name = "Use R Harass", value = false})
                  gsoSDK.Menu.rset:MenuElement({id = "rci", name = "Use R if enemy isImmobile", value = true})
                  gsoSDK.Menu.rset:MenuElement({id = "rcd", name = "Use R if enemy distance < X", value = true})
                  gsoSDK.Menu.rset:MenuElement({id = "rdist", name = "use R if enemy distance < X", value = 500, min = 250, max = 1000, step = 50})
                  gsoSDK.Menu.rset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
      end
      function __gsoVarus:AddTickEvent()
            gsoSDK.ChampTick = function()
                  -- Check Q Buff
                  self.HasQBuff = gsoSDK.Spell:HasBuff(myHero, "varusq")
                  -- Disable / Enable Attack
                  if self.HasQBuff then
                        gsoSDK.Orbwalker.AttackEnabled = false
                  else
                        gsoSDK.Orbwalker.AttackEnabled = true
                  end
                  -- Is Attacking
                  if not self.HasQBuff and not gsoSDK.Orbwalker:CanMove() then
                        return
                  end
                  -- Get Mode
                  local mode = gsoSDK.Orbwalker:GetMode()
                  -- Can Attack
                  local AATarget = gsoSDK.TS:GetComboTarget()
                  if not self.HasQBuff and AATarget and mode ~= "None" and gsoSDK.Orbwalker:CanAttack() then
                        return
                  end
                  -- Get Enemies
                  local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(math.huge, false, "spell")
                  --R
                  local canR = (mode == "Combo" and gsoSDK.Menu.rset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.rset.harass:Value())
                  if canR and gsoSDK.Spell:IsReady(_R, { q = 0.33, w = 0, e = 0.63, r = 0.5 } ) then
                        if gsoSDK.Menu.rset.rcd:Value() then
                              local t = gsoSDK.TS:GetClosestEnemy(enemyList, gsoSDK.Menu.rset.rdist:Value())
                              if t and gsoSDK.Spell:CastSpell(HK_R, t, myHero.pos, self.rData, gsoSDK.Menu.rset.hitchance:Value()) then
                                    return
                              end
                        end
                        if gsoSDK.Menu.rset.rci:Value() then
                              local t = gsoSDK.TS:GetImmobileEnemy(enemyList, 900)
                              if t and myHero.pos:DistanceTo(t.pos) < self.rData.range and gsoSDK.Spell:CastSpell(HK_R, t) then
                                    return
                              end
                        end
                  end
                  --E
                  local canE = (mode == "Combo" and gsoSDK.Menu.eset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.eset.harass:Value())
                  if canE and gsoSDK.Spell:IsReady(_E, { q = 0.33, w = 0, e = 0.63, r = 0.33 } ) then
                        local aaRange = gsoSDK.Menu.eset.range:Value() and not AATarget
                        local onlyStacksE = gsoSDK.Menu.eset.stacks:Value()
                        local eTargets = {}
                        for i = 1, #enemyList do
                              local hero = enemyList[i]
                              local hasStacks = gsoSDK.Spell:GetBuffCount(hero, "varuswdebuff") == 3 or not onlyStacksE or myHero:GetSpellData(_W).level == 0 or aaRange
                              if hasStacks and myHero.pos:DistanceTo(hero.pos) < 925 then
                                    eTargets[#eTargets+1] = hero
                              end
                        end
                        local t = gsoSDK.TS:GetTarget(eTargets, false)
                        if t and gsoSDK.Spell:CastSpell(HK_E, t, myHero.pos, self.eData, gsoSDK.Menu.eset.hitchance:Value()) then
                              return
                        end
                  end
                  -- Q
                  local canQ = (mode == "Combo" and gsoSDK.Menu.qset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.qset.harass:Value())
                  if canQ then
                        local aaRange = gsoSDK.Menu.qset.range:Value() and not AATarget
                        local wActive = gsoSDK.Menu.qset.active:Value() and GameTimer() < gsoSDK.Spell.LastWk + 3
                        -- Q1
                        if not self.HasQBuff and gsoSDK.Spell:IsReady(_Q, { q = 0.5, w = 0.1, e = 1, r = 0.33 } ) then
                              if ControlIsKeyDown(HK_Q) then
                                    ControlKeyUp(HK_Q)
                              end
                              -- W
                              local canW = (mode == "Combo" and gsoSDK.Menu.wset.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.wset.harass:Value())
                              if canW and gsoSDK.Spell:IsReady(_W, { q = 0.33, w = 0.5, e = 0.63, r = 0.33 } ) then
                                    local whp = gsoSDK.Menu.wset.whp:Value()
                                    for i = 1, #enemyList do
                                          local hero = enemyList[i]
                                          local hp = 100 * ( hero.health / hero.maxHealth )
                                          if hp < whp and myHero.pos:DistanceTo(hero.pos) < 1500 and gsoSDK.Spell:CastSpell(HK_W) then
                                                return
                                          end
                                    end
                              end
                              local onlyStacksQ = gsoSDK.Menu.qset.stacks:Value()
                              for i = 1, #enemyList do
                                    local hero = enemyList[i]
                                    local hasStacks = gsoSDK.Spell:GetBuffCount(hero, "varuswdebuff") == 3 or not onlyStacksQ or myHero:GetSpellData(_W).level == 0 or wActive or aaRange
                                    if hasStacks and myHero.pos:DistanceTo(hero.pos) < 1500 then
                                          ControlKeyDown(HK_Q)
                                          gsoSDK.Spell.LastQ = GameTimer()
                                          return
                                    end
                              end
                        -- Q2
                        elseif self.HasQBuff and gsoSDK.Spell:IsReady(_Q, { q = 0.2, w = 0, e = 0.63, r = 0.33 } ) then
                              local qTargets = {}
                              local onlyStacksQ = gsoSDK.Menu.qset.stacks:Value()
                              for i = 1, #enemyList do
                                    local hero = enemyList[i]
                                    local hasStacks = gsoSDK.Spell:GetBuffCount(hero, "varuswdebuff") == 3 or not onlyStacksQ or myHero:GetSpellData(_W).level == 0 or wActive or aaRange
                                    if hasStacks and myHero.pos:DistanceTo(hero.pos) < 1650 then
                                          qTargets[#qTargets+1] = hero
                                    end
                              end
                              if #qTargets == 0 then
                                    for i = 1, #enemyList do
                                          local hero = enemyList[i]
                                          if myHero.pos:DistanceTo(hero.pos) < 1650 then
                                                qTargets[#qTargets+1] = hero
                                          end
                                    end
                              end
                              local qkey = gsoSDK.Spell.LastQk - 0.33
                              local qTimer = GameTimer() - qkey
                              local qExtraRange = qTimer < 2 and qTimer * 0.5 * 700 or 700
                              local qRange = 925 + qExtraRange
                              local t = gsoSDK.TS:GetTarget(qTargets, false)
                              if t and gsoSDK.Spell:CastSpell(HK_Q, t, myHero.pos, self.qData, gsoSDK.Menu.qset.hitchance:Value()) then
                                    return
                              end
                        end
                  end
            end
      end
--[[
▒█▀▀█ ▒█▀▀█ ░█▀▀█ ▒█▄░▒█ ▒█▀▀▄ 
▒█▀▀▄ ▒█▄▄▀ ▒█▄▄█ ▒█▒█▒█ ▒█░▒█ 
▒█▄▄█ ▒█░▒█ ▒█░▒█ ▒█░░▀█ ▒█▄▄▀ 
]]
class "__gsoBrand"
      function __gsoBrand:__init()
            gsoSDK.Menu = MenuElement({name = "Gamsteron Brand", id = "gsobrand", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/x1xxbrandx3xx.png" })
            __gsoLoader()
            gsoSDK.Orbwalker:SetSpellMoveDelays( { q = 0.2, w = 0.2, e = 0.2, r = 0.2 } )
            gsoSDK.Orbwalker:SetSpellAttackDelays( { q = 0.33, w = 0.33, e = 0.33, r = 0.33 } )
            self:SetSpellData()
            self:CreateMenu()
            self:AddTickEvent()
            gsoSDK.Orbwalker:CanAttackEvent(function()
                  -- LastHit, LaneClear
                  if not gsoSDK.Menu.orb.keys.combo:Value() and not gsoSDK.Menu.orb.keys.harass:Value() then
                        return true
                  end
                  -- W
                  local wDis = gsoSDK.Menu.wset.disaa:Value()
                  local wLvl = wDis and myHero:GetSpellData(_W).level or 0
                  local isWReady = wLvl > 0 and GameCanUseSpell(_W) == 0
                  local almostWReady = wLvl > 0 and myHero.mana > myHero:GetSpellData(_W).mana and myHero:GetSpellData(_W).currentCd < 1
                  local w = isWReady or almostWReady
                  -- E
                  local eDis = gsoSDK.Menu.eset.disaa:Value()
                  local eLvl = eDis and myHero:GetSpellData(_E).level or 0
                  local isEReady = eLvl > 0 and GameCanUseSpell(_E) == 0
                  local almostEReady = eLvl > 0 and myHero.mana > myHero:GetSpellData(_E).mana and myHero:GetSpellData(_E).currentCd < 1
                  local e = isEReady or almostEReady
                  if w or e then
                        return false
                  end
                  return true
            end)
      end
      function __gsoBrand:SetSpellData()
            self.qData = { delay = 0.25, radius = 80, range = 1050, speed = 1550, collision = true, sType = "line" }
            self.wData = { delay = 0.625, radius = 50, range = 900, speed = math.huge, collision = false, sType = "circular" }
      end
      function __gsoBrand:CreateMenu()
            -- Q
            gsoSDK.Menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
                  -- KS
                  gsoSDK.Menu.qset:MenuElement({name = "KS", id = "killsteal", type = MENU })
                        gsoSDK.Menu.qset.killsteal:MenuElement({id = "enabled", name = "Enabled", value = true})
                        gsoSDK.Menu.qset.killsteal:MenuElement({id = "minhp", name = "minimum enemy hp", value = 200, min = 1, max = 300, step = 1})
                        gsoSDK.Menu.qset.killsteal:MenuElement({id = "hitchance", name = "Hitchance", value = 2, drop = { "normal", "high" } })
                  -- Auto
                  gsoSDK.Menu.qset:MenuElement({name = "Auto", id = "auto", type = MENU })
                        gsoSDK.Menu.qset.auto:MenuElement({id = "stun", name = "Auto Stun", value = true})
                        gsoSDK.Menu.qset.auto:MenuElement({id = "hitchance", name = "Hitchance", value = 2, drop = { "normal", "high" } })
                  -- Combo / Harass
                  gsoSDK.Menu.qset:MenuElement({name = "Combo / Harass", id = "comhar", type = MENU })
                        gsoSDK.Menu.qset.comhar:MenuElement({id = "combo", name = "Combo", value = true})
                        gsoSDK.Menu.qset.comhar:MenuElement({id = "harass", name = "Harass", value = false})
                        gsoSDK.Menu.qset.comhar:MenuElement({id = "stun", name = "Only if will stun", value = true})
                        gsoSDK.Menu.qset.comhar:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            -- W
            gsoSDK.Menu:MenuElement({name = "W settings", id = "wset", type = MENU })
                  gsoSDK.Menu.wset:MenuElement({id = "disaa", name = "Disable attack if ready or almostReady", value = true})
                  -- KS
                  gsoSDK.Menu.wset:MenuElement({name = "KS", id = "killsteal", type = MENU })
                        gsoSDK.Menu.wset.killsteal:MenuElement({id = "enabled", name = "Enabled", value = true})
                        gsoSDK.Menu.wset.killsteal:MenuElement({id = "minhp", name = "minimum enemy hp", value = 200, min = 1, max = 300, step = 1})
                        gsoSDK.Menu.wset.killsteal:MenuElement({id = "hitchance", name = "Hitchance", value = 2, drop = { "normal", "high" } })
                  -- Auto
                  gsoSDK.Menu.wset:MenuElement({name = "Auto", id = "auto", type = MENU })
                        gsoSDK.Menu.wset.auto:MenuElement({id = "enabled", name = "Enabled", value = true})
                        gsoSDK.Menu.wset.auto:MenuElement({id = "hitchance", name = "Hitchance", value = 2, drop = { "normal", "high" } })
                  -- Combo / Harass
                  gsoSDK.Menu.wset:MenuElement({name = "Combo / Harass", id = "comhar", type = MENU })
                        gsoSDK.Menu.wset.comhar:MenuElement({id = "combo", name = "Combo", value = true})
                        gsoSDK.Menu.wset.comhar:MenuElement({id = "harass", name = "Harass", value = false})
                        gsoSDK.Menu.wset.comhar:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            -- E
            gsoSDK.Menu:MenuElement({name = "E settings", id = "eset", type = MENU })
                  gsoSDK.Menu.eset:MenuElement({id = "disaa", name = "Disable attack if ready or almostReady", value = true})
                  -- KS
                  gsoSDK.Menu.eset:MenuElement({name = "KS", id = "killsteal", type = MENU })
                        gsoSDK.Menu.eset.killsteal:MenuElement({id = "enabled", name = "Enabled", value = true})
                        gsoSDK.Menu.eset.killsteal:MenuElement({id = "minhp", name = "minimum enemy hp", value = 100, min = 1, max = 300, step = 1})
                  -- Auto
                  gsoSDK.Menu.eset:MenuElement({name = "Auto", id = "auto", type = MENU })
                        gsoSDK.Menu.eset.auto:MenuElement({id = "stun", name = "If Q ready | no collision & W not ready $ mana for Q + E", value = true})
                        gsoSDK.Menu.eset.auto:MenuElement({id = "passive", name = "If Q not ready & W not ready $ enemy has passive buff", value = true})
                  -- Combo / Harass
                  gsoSDK.Menu.eset:MenuElement({name = "Combo / Harass", id = "comhar", type = MENU })
                        gsoSDK.Menu.eset.comhar:MenuElement({id = "combo", name = "Combo", value = true})
                        gsoSDK.Menu.eset.comhar:MenuElement({id = "harass", name = "Harass", value = false})
            --R
            gsoSDK.Menu:MenuElement({name = "R settings", id = "rset", type = MENU })
                  -- Auto
                  gsoSDK.Menu.rset:MenuElement({name = "Auto", id = "auto", type = MENU })
                        gsoSDK.Menu.rset.auto:MenuElement({id = "enabled", name = "Enabled", value = true})
                        gsoSDK.Menu.rset.auto:MenuElement({id = "xenemies", name = ">= X enemies near target", value = 2, min = 1, max = 4, step = 1})
                        gsoSDK.Menu.rset.auto:MenuElement({id = "xrange", name = "< X distance enemies to target", value = 300, min = 100, max = 600, step = 50})
                  -- Combo / Harass
                  gsoSDK.Menu.rset:MenuElement({name = "Combo / Harass", id = "comhar", type = MENU })
                        gsoSDK.Menu.rset.comhar:MenuElement({id = "combo", name = "Use R Combo", value = true})
                        gsoSDK.Menu.rset.comhar:MenuElement({id = "harass", name = "Use R Harass", value = false})
                        gsoSDK.Menu.rset.comhar:MenuElement({id = "xenemies", name = ">= X enemies near target", value = 1, min = 1, max = 4, step = 1})
                        gsoSDK.Menu.rset.comhar:MenuElement({id = "xrange", name = "< X distance enemies to target", value = 300, min = 100, max = 600, step = 50})
      end
      function __gsoBrand:AddTickEvent()
            gsoSDK.ChampTick = function()
                  -- Is Attacking
                  if not gsoSDK.Orbwalker:CanMove() then
                        return
                  end
                  -- Get Mode
                  local mode = gsoSDK.Orbwalker:GetMode()
                  -- Q
                  if gsoSDK.Spell:IsReady(_Q, { q = 0.5, w = 0.5, e = 0.33, r = 0.33 } ) then
                        -- KS
                        if gsoSDK.Menu.qset.killsteal.enabled:Value() then
                              local baseDmg = 50
                              local lvlDmg = 30 * myHero:GetSpellData(_Q).level
                              local apDmg = myHero.ap * 0.55
                              local qDmg = baseDmg + lvlDmg + apDmg
                              local minHP = gsoSDK.Menu.qset.killsteal.minhp:Value()
                              if qDmg > minHP then
                                    local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(950, false, "spell")
                                    for i = 1, #enemyList do
                                          local qTarget = enemyList[i]
                                          if qTarget.health > minHP and qTarget.health < gsoSDK.Spell:CalculateDmg(qTarget, { dmgType = "ap", dmgAP = qDmg }) and gsoSDK.Spell:CastSpell(HK_Q, qTarget, myHero.pos, self.qData, gsoSDK.Menu.qset.killsteal.hitchance:Value()) then
                                                return
                                          end
                                    end
                              end
                        end
                        -- Combo Harass
                        if (mode == "Combo" and gsoSDK.Menu.qset.comhar.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.qset.comhar.harass:Value()) then
                              local blazeList = {}
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(950, false, "spell")
                              for i = 1, #enemyList do
                                    local unit = enemyList[i]
                                    if gsoSDK.Spell:GetBuffDuration(unit, "brandablaze") > 0.35 and not gsoSDK.Spell:IsCollision(unit, self.qData) then
                                          blazeList[#blazeList+1] = unit
                                    end
                              end
                              local qTarget = gsoSDK.TS:GetTarget(blazeList, true)
                              if qTarget and gsoSDK.Spell:CastSpell(HK_Q, qTarget, myHero.pos, self.qData, gsoSDK.Menu.qset.comhar.hitchance:Value()) then
                                    return
                              end
                              if not gsoSDK.Menu.qset.comhar.stun:Value() and GameTimer() > gsoSDK.Spell.LastWk + 1.25 and GameTimer() > gsoSDK.Spell.LastEk + 0.77 and GameTimer() > gsoSDK.Spell.LastRk + 0.77 then
                                    local qTarget = gsoSDK.TS:GetTarget(gsoSDK.ObjectManager:GetEnemyHeroes(950, false, "spell"), true)
                                    if qTarget and gsoSDK.Spell:CastSpell(HK_Q, qTarget, myHero.pos, self.qData, gsoSDK.Menu.qset.comhar.hitchance:Value()) then
                                          return
                                    end
                              end
                        -- Auto
                        elseif gsoSDK.Menu.qset.auto.stun:Value() then
                              local blazeList = {}
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(950, false, "spell")
                              for i = 1, #enemyList do
                                    local unit = enemyList[i]
                                    if gsoSDK.Spell:GetBuffDuration(unit, "brandablaze") > 0.35 and not gsoSDK.Spell:IsCollision(unit, self.qData) then
                                          blazeList[#blazeList+1] = unit
                                    end
                              end
                              local qTarget = gsoSDK.TS:GetTarget(blazeList, true)
                              if qTarget and gsoSDK.Spell:CastSpell(HK_Q, qTarget, myHero.pos, self.qData, gsoSDK.Menu.qset.comhar.hitchance:Value()) then
                                    return
                              end
                        end
                  end
                  -- W
                  if gsoSDK.Spell:IsReady(_W, { q = 0.33, w = 0.5, e = 0.5, r = 0.33 } ) then
                        -- KS
                        if gsoSDK.Menu.wset.killsteal.enabled:Value() then
                              local baseDmg = 30
                              local lvlDmg = 45 * myHero:GetSpellData(_W).level
                              local apDmg = myHero.ap * 0.6
                              local wDmg = baseDmg + lvlDmg + apDmg
                              local minHP = gsoSDK.Menu.wset.killsteal.minhp:Value()
                              if wDmg > minHP then
                                    local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1100, false, "spell")
                                    for i = 1, #enemyList do
                                          local wTarget = enemyList[i]
                                          if wTarget.health > minHP and wTarget.health < gsoSDK.Spell:CalculateDmg(wTarget, { dmgType = "ap", dmgAP = wDmg }) and gsoSDK.Spell:CastSpell(HK_W, wTarget, myHero.pos, self.wData, gsoSDK.Menu.wset.killsteal.hitchance:Value()) then
                                                return
                                          end
                                    end
                              end
                        end
                        -- Combo / Harass
                        if (mode == "Combo" and gsoSDK.Menu.wset.comhar.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.wset.comhar.harass:Value()) then
                              local blazeList = {}
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1100, false, "spell")
                              for i = 1, #enemyList do
                                    local unit = enemyList[i]
                                    if gsoSDK.Spell:GetBuffDuration(unit, "brandablaze") > 0.35 then
                                          blazeList[#blazeList+1] = unit
                                    end
                              end
                              local wTarget = gsoSDK.TS:GetTarget(blazeList, true)
                              if wTarget and gsoSDK.Spell:CastSpell(HK_W, wTarget, myHero.pos, self.wData, gsoSDK.Menu.wset.comhar.hitchance:Value()) then
                                    return
                              end
                              if GameTimer() > gsoSDK.Spell.LastQk + 0.77 and GameTimer() > gsoSDK.Spell.LastEk + 0.77 and GameTimer() > gsoSDK.Spell.LastRk + 0.77 then 
                                    local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1100, false, "spell")
                                    local wTarget = gsoSDK.TS:GetTarget(enemyList, true)
                                    if wTarget and gsoSDK.Spell:CastSpell(HK_W, wTarget, myHero.pos, self.wData, gsoSDK.Menu.wset.comhar.hitchance:Value()) then
                                          return
                                    end
                              end
                        -- Auto
                        elseif gsoSDK.Menu.wset.auto.enabled:Value() then
                              local blazeList = {}
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1100, false, "spell")
                              for i = 1, #enemyList do
                                    local unit = enemyList[i]
                                    if gsoSDK.Spell:GetBuffDuration(unit, "brandablaze") > 0.35 then
                                          blazeList[#blazeList+1] = unit
                                    end
                              end
                              local wTarget = gsoSDK.TS:GetTarget(blazeList, true)
                              if wTarget and gsoSDK.Spell:CastSpell(HK_W, wTarget, myHero.pos, self.wData, gsoSDK.Menu.wset.comhar.hitchance:Value()) then
                                    return
                              end
                              if GameTimer() > gsoSDK.Spell.LastQk + 0.77 and GameTimer() > gsoSDK.Spell.LastEk + 0.77 and GameTimer() > gsoSDK.Spell.LastRk + 0.77 then 
                                    local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1100, false, "spell")
                                    local wTarget = gsoSDK.TS:GetTarget(enemyList, true)
                                    if wTarget and gsoSDK.Spell:CastSpell(HK_W, wTarget, myHero.pos, self.wData, gsoSDK.Menu.wset.comhar.hitchance:Value()) then
                                          return
                                    end
                              end
                        end
                  end
                  -- E
                  if gsoSDK.Spell:IsReady(_E, { q = 0.33, w = 0.5, e = 0.5, r = 0.33 } ) then
                        -- KS
                        if gsoSDK.Menu.eset.killsteal.enabled:Value() then
                              local baseDmg = 50
                              local lvlDmg = 20 * myHero:GetSpellData(_E).level
                              local apDmg = myHero.ap * 0.35
                              local eDmg = baseDmg + lvlDmg + apDmg
                              local minHP = gsoSDK.Menu.eset.killsteal.minhp:Value()
                              if eDmg > minHP then
                                    local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(670, false, "spell")
                                    for i = 1, #enemyList do
                                          local unit = enemyList[i]
                                          if unit.health > minHP and unit.health < gsoSDK.Spell:CalculateDmg(unit, { dmgType = "ap", dmgAP = eDmg }) and gsoSDK.Spell:CastSpell(HK_E, unit) then
                                                return
                                          end
                                    end
                              end
                        end
                        -- Combo / Harass
                        if (mode == "Combo" and gsoSDK.Menu.eset.comhar.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.eset.comhar.harass:Value()) then
                              local blazeList = {}
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(670, false, "spell")
                              for i = 1, #enemyList do
                                    local unit = enemyList[i]
                                    if gsoSDK.Spell:GetBuffDuration(unit, "brandablaze") > 0.35 then
                                          blazeList[#blazeList+1] = unit
                                    end
                              end
                              local eTarget = gsoSDK.TS:GetTarget(blazeList, true)
                              if eTarget and gsoSDK.Spell:CastSpell(HK_E, eTarget) then
                                    return
                              end
                              if GameTimer() > gsoSDK.Spell.LastQk + 0.77 and GameTimer() > gsoSDK.Spell.LastWk + 1 and GameTimer() > gsoSDK.Spell.LastRk + 0.77 then 
                                    eTarget = gsoSDK.TS:GetTarget(enemyList, true)
                                    if eTarget and gsoSDK.Spell:CastSpell(HK_E, eTarget) then
                                          return
                                    end
                              end
                        -- Auto
                        elseif myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 then
                              -- EQ -> if Q ready | no collision & W not ready $ mana for Q + E
                              if gsoSDK.Menu.eset.auto.stun:Value() and myHero.mana > myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_E).mana then
                                    local isQReady = GameCanUseSpell(_Q) == 0 or myHero:GetSpellData(_Q).currentCd < 0.25
                                    local isWReady = GameCanUseSpell(_W) == 0 or myHero:GetSpellData(_W).currentCd < 0.75
                                    if isQReady and not isWReady then
                                          local blazeList = {}
                                          local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(670, false, "spell")
                                          for i = 1, #enemyList do
                                                local unit = enemyList[i]
                                                if gsoSDK.Spell:GetBuffDuration(unit, "brandablaze") > 0.35 then
                                                      blazeList[#blazeList+1] = unit
                                                end
                                          end
                                          local eTarget = gsoSDK.TS:GetTarget(blazeList, true)
                                          if eTarget and not gsoSDK.Spell:IsCollision(eTarget, self.qData) and gsoSDK.Spell:CastSpell(HK_E, eTarget) then
                                                return
                                          end
                                          if GameTimer() > gsoSDK.Spell.LastQk + 0.77 and GameTimer() > gsoSDK.Spell.LastWk + 1 and GameTimer() > gsoSDK.Spell.LastRk + 0.77 then
                                                eTarget = gsoSDK.TS:GetTarget(enemyList, true)
                                                if eTarget and not gsoSDK.Spell:IsCollision(eTarget, self.qData) and gsoSDK.Spell:CastSpell(HK_E, eTarget) then
                                                      return
                                                end
                                          end
                                    end
                              end
                              -- Passive -> If Q not ready & W not ready $ enemy has passive buff
                              if gsoSDK.Menu.eset.auto.passive:Value() then
                                    local isQReady = GameCanUseSpell(_Q) == 0 or myHero:GetSpellData(_Q).currentCd < 0.75
                                    local isWReady = GameCanUseSpell(_W) == 0 or myHero:GetSpellData(_W).currentCd < 0.75
                                    if not isQReady and not isWReady then
                                          local blazeList = {}
                                          local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(670, false, "spell")
                                          for i = 1, #enemyList do
                                                local unit = enemyList[i]
                                                if gsoSDK.Spell:GetBuffDuration(unit, "brandablaze") > 0.35 then
                                                      blazeList[#blazeList+1] = unit
                                                end
                                          end
                                          local eTarget = gsoSDK.TS:GetTarget(blazeList, true)
                                          if eTarget and gsoSDK.Spell:CastSpell(HK_E, eTarget) then
                                                return
                                          end
                                    end
                              end
                        end
                  end
                  -- R
                  if gsoSDK.Spell:IsReady(_R, { q = 0.33, w = 0.75, e = 0.33, r = 0.33 } ) then
                        -- Combo / Harass
                        if (mode == "Combo" and gsoSDK.Menu.rset.comhar.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.rset.comhar.harass:Value()) then
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(750, false, "spell")
                              local xRange = gsoSDK.Menu.rset.comhar.xrange:Value()
                              local xEnemies = gsoSDK.Menu.rset.comhar.xenemies:Value()
                              for i = 1, #enemyList do
                                    local count = 0
                                    local rTarget = enemyList[i]
                                    for j = 1, #enemyList do
                                          local unit = enemyList[j]
                                          if rTarget ~= unit and rTarget.pos:DistanceTo(unit.pos) < xRange then
                                                count = count + 1
                                          end
                                    end
                                    if count >= xEnemies and gsoSDK.Spell:CastSpell(HK_R, rTarget) then
                                          return
                                    end
                              end
                        -- Auto
                        elseif gsoSDK.Menu.rset.auto.enabled:Value() then
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(750, false, "spell")
                              local xRange = gsoSDK.Menu.rset.auto.xrange:Value()
                              local xEnemies = gsoSDK.Menu.rset.auto.xenemies:Value()
                              for i = 1, #enemyList do
                                    local count = 0
                                    local rTarget = enemyList[i]
                                    for j = 1, #enemyList do
                                          local unit = enemyList[j]
                                          if rTarget ~= unit and rTarget.pos:DistanceTo(unit.pos) < xRange then
                                                count = count + 1
                                          end
                                    end
                                    if count >= xEnemies and gsoSDK.Spell:CastSpell(HK_R, rTarget) then
                                          return
                                    end
                              end
                        end
                  end
            end
      end
--[[
▒█▀▄▀█ ▒█▀▀▀█ ▒█▀▀█ ▒█▀▀█ ░█▀▀█ ▒█▄░▒█ ░█▀▀█ 
▒█▒█▒█ ▒█░░▒█ ▒█▄▄▀ ▒█░▄▄ ▒█▄▄█ ▒█▒█▒█ ▒█▄▄█ 
▒█░░▒█ ▒█▄▄▄█ ▒█░▒█ ▒█▄▄█ ▒█░▒█ ▒█░░▀█ ▒█░▒█ 
]]
class "__gsoMorgana"
      function __gsoMorgana:__init()
            gsoSDK.Menu = MenuElement({name = "Gamsteron Morgana", id = "gsomorgana", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/morganads83fd.png" })
            __gsoLoader()
            gsoSDK.Orbwalker:SetSpellMoveDelays( { q = 0.2, w = 0.2, e = 0.2, r = 0.2 } )
            gsoSDK.Orbwalker:SetSpellAttackDelays( { q = 0.33, w = 0.33, e = 0.33, r = 0.33 } )
            self:SetSpellData()
            self:CreateMenu()
            self:AddTickEvent()
            gsoSDK.Orbwalker:CanAttackEvent(function()
                  -- LastHit, LaneClear
                  if not gsoSDK.Menu.orb.keys.combo:Value() and not gsoSDK.Menu.orb.keys.harass:Value() then
                        return true
                  end
                  -- Q
                  local qDis = gsoSDK.Menu.qset.disaa:Value()
                  local qLvl = qDis and myHero:GetSpellData(_Q).level or 0
                  local isQReady = qLvl > 0 and GameCanUseSpell(_Q) == 0
                  local almostQReady = qLvl > 0 and myHero.mana > myHero:GetSpellData(_Q).mana and myHero:GetSpellData(_Q).currentCd < 1
                  if isQReady or almostQReady then
                        return false
                  end
                  return true
            end)
      end
      function __gsoMorgana:SetSpellData()
            self.qData = { delay = 0.25, radius = 80, range = 1175, speed = 1200, collision = true, sType = "line" }
      end
      function __gsoMorgana:CreateMenu()
            -- Q
            gsoSDK.Menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            -- Disable Attack
                  gsoSDK.Menu.qset:MenuElement({id = "disaa", name = "Disable attack if ready or almostReady", value = false})
            -- KS
                  gsoSDK.Menu.qset:MenuElement({name = "KS", id = "killsteal", type = MENU })
                  gsoSDK.Menu.qset.killsteal:MenuElement({id = "enabled", name = "Enabled", value = false})
                  gsoSDK.Menu.qset.killsteal:MenuElement({id = "minhp", name = "minimum enemy hp", value = 200, min = 1, max = 300, step = 1})
                  gsoSDK.Menu.qset.killsteal:MenuElement({id = "hitchance", name = "Hitchance", value = 2, drop = { "normal", "high" } })
            -- Auto
                  gsoSDK.Menu.qset:MenuElement({name = "Auto", id = "auto", type = MENU })
                  gsoSDK.Menu.qset.auto:MenuElement({id = "enabled", name = "Enabled", value = true})
                  gsoSDK.Menu.qset.auto:MenuElement({id = "collision", name = "Skip enemies that have minion collision", value = true})
                  gsoSDK.Menu.qset.auto:MenuElement({name = "Use on:", id = "useon", type = MENU })
                        gsoSDK.ObjectManager:OnEnemyHeroLoad(function(hero) gsoSDK.Menu.qset.auto.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
                  gsoSDK.Menu.qset.auto:MenuElement({id = "hitchance", name = "Hitchance", value = 2, drop = { "normal", "high" } })
            -- Combo / Harass
                  gsoSDK.Menu.qset:MenuElement({name = "Combo / Harass", id = "comhar", type = MENU })
                  gsoSDK.Menu.qset.comhar:MenuElement({id = "combo", name = "Combo", value = true})
                  gsoSDK.Menu.qset.comhar:MenuElement({id = "harass", name = "Harass", value = false})
                  gsoSDK.Menu.qset.comhar:MenuElement({id = "collision", name = "Skip enemies that have minion collision", value = true})
                  gsoSDK.Menu.qset.comhar:MenuElement({name = "Use on:", id = "useon", type = MENU })
                        gsoSDK.ObjectManager:OnEnemyHeroLoad(function(hero) gsoSDK.Menu.qset.comhar.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
                  gsoSDK.Menu.qset.comhar:MenuElement({id = "hitchance", name = "Hitchance", value = 2, drop = { "normal", "high" } })
            -- W
            gsoSDK.Menu:MenuElement({name = "W settings", id = "wset", type = MENU })
                  gsoSDK.Menu.wset:MenuElement({id = "enabled", name = "Auto -> only Q target", value = true})
            -- E
            gsoSDK.Menu:MenuElement({name = "E settings", id = "eset", type = MENU })
                  gsoSDK.Menu.eset:MenuElement({id = "note1", name = "Note: not ready yet !", type = SPACE})
            --R
            gsoSDK.Menu:MenuElement({name = "R settings", id = "rset", type = MENU })
                  -- KS
                  gsoSDK.Menu.rset:MenuElement({name = "KS", id = "killsteal", type = MENU })
                        gsoSDK.Menu.rset.killsteal:MenuElement({id = "enabled", name = "Enabled", value = false})
                        gsoSDK.Menu.rset.killsteal:MenuElement({id = "minhp", name = "minimum enemy hp", value = 200, min = 1, max = 300, step = 1})
                  -- Auto
                  gsoSDK.Menu.rset:MenuElement({name = "Auto", id = "auto", type = MENU })
                        gsoSDK.Menu.rset.auto:MenuElement({id = "enabled", name = "Enabled", value = true})
                        gsoSDK.Menu.rset.auto:MenuElement({id = "xenemies", name = ">= X enemies near morgana", value = 3, min = 1, max = 5, step = 1})
                        gsoSDK.Menu.rset.auto:MenuElement({id = "xrange", name = "< X distance enemies to morgana", value = 300, min = 100, max = 550, step = 50})
                  -- Combo / Harass
                  gsoSDK.Menu.rset:MenuElement({name = "Combo / Harass", id = "comhar", type = MENU })
                        gsoSDK.Menu.rset.comhar:MenuElement({id = "combo", name = "Use R Combo", value = true})
                        gsoSDK.Menu.rset.comhar:MenuElement({id = "harass", name = "Use R Harass", value = false})
                        gsoSDK.Menu.rset.comhar:MenuElement({id = "xenemies", name = ">= X enemies near morgana", value = 2, min = 1, max = 4, step = 1})
                        gsoSDK.Menu.rset.comhar:MenuElement({id = "xrange", name = "< X distance enemies to morgana", value = 300, min = 100, max = 550, step = 50})
      end
      function __gsoMorgana:AddTickEvent()
            gsoSDK.ChampTick = function()
                  -- Is Attacking
                  if not gsoSDK.Orbwalker:CanMove() then
                        return
                  end
                  -- Get Mode
                  local mode = gsoSDK.Orbwalker:GetMode()
                  -- Q
                  if gsoSDK.Spell:IsReady(_Q, { q = 0.5, w = 0.33, e = 0.33, r = 0.33 } ) then
                        -- KS
                        if gsoSDK.Menu.qset.killsteal.enabled:Value() then
                              local baseDmg = 25
                              local lvlDmg = 55 * myHero:GetSpellData(_Q).level
                              local apDmg = myHero.ap * 0.9
                              local qDmg = baseDmg + lvlDmg + apDmg
                              local minHP = gsoSDK.Menu.qset.killsteal.minhp:Value()
                              if qDmg > minHP then
                                    local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1175, false, "spell")
                                    for i = 1, #enemyList do
                                          local qTarget = enemyList[i]
                                          if qTarget.health > minHP and qTarget.health < gsoSDK.Spell:CalculateDmg(qTarget, { dmgType = "ap", dmgAP = qDmg }) and gsoSDK.Spell:CastSpell(HK_Q, qTarget, myHero.pos, self.qData, gsoSDK.Menu.qset.killsteal.hitchance:Value()) then
                                                return
                                          end
                                    end
                              end
                        end
                        -- Combo Harass
                        if (mode == "Combo" and gsoSDK.Menu.qset.comhar.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.qset.comhar.harass:Value()) then
                              local qList = {}
                              local skipCollision = gsoSDK.Menu.qset.comhar.collision:Value()
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1175, false, "spell")
                              for i = 1, #enemyList do
                                    local hero = enemyList[i]
                                    local heroName = hero.charName
                                    if gsoSDK.Menu.qset.comhar.useon[heroName] and gsoSDK.Menu.qset.comhar.useon[heroName]:Value() then
                                          if not skipCollision or not gsoSDK.Spell:IsCollision(hero, self.qData) then
                                                qList[#qList+1] = hero
                                          end
                                    end
                              end
                              local qTarget = gsoSDK.TS:GetTarget(qList, true)
                              if qTarget and gsoSDK.Spell:CastSpell(HK_Q, qTarget, myHero.pos, self.qData, gsoSDK.Menu.qset.comhar.hitchance:Value()) then
                                    return
                              end
                        -- Auto
                        elseif gsoSDK.Menu.qset.auto.enabled:Value() then
                              local qList = {}
                              local skipCollision = gsoSDK.Menu.qset.auto.collision:Value()
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(1175, false, "spell")
                              for i = 1, #enemyList do
                                    local hero = enemyList[i]
                                    local heroName = hero.charName
                                    if gsoSDK.Menu.qset.auto.useon[heroName] and gsoSDK.Menu.qset.auto.useon[heroName]:Value() then
                                          if not skipCollision or not gsoSDK.Spell:IsCollision(hero, self.qData) then
                                                qList[#qList+1] = hero
                                          end
                                    end
                              end
                              local qTarget = gsoSDK.TS:GetTarget(qList, true)
                              if qTarget and gsoSDK.Spell:CastSpell(HK_Q, qTarget, myHero.pos, self.qData, gsoSDK.Menu.qset.comhar.hitchance:Value()) then
                                    return
                              end
                        end
                  end
                  -- W
                  if gsoSDK.Menu.wset.enabled:Value() and gsoSDK.Spell:IsReady(_W, { q = 0.33, w = 0.5, e = 0.33, r = 0.33 } ) then
                        local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(900, false, "spell")
                        for i = 1, #enemyList do
                              local unit = enemyList[i]
                              if gsoSDK.Spell:GetBuffDuration(unit, "darkbindingmissile") > 0.35 and gsoSDK.Spell:CastSpell(HK_W, unit) then
                                    return
                              end
                        end
                  end
                  --[[ E
                  if gsoSDK.Spell:IsReady(_E, { q = 0.33, w = 0.33, e = 0.5, r = 0.33 } ) then
                  end
                  ]]
                  -- R
                  if gsoSDK.Spell:IsReady(_R, { q = 0.33, w = 0.75, e = 0.33, r = 0.33 } ) then
                        -- KS
                        if gsoSDK.Menu.rset.killsteal.enabled:Value() then
                              local baseDmg = 75
                              local lvlDmg = 75 * myHero:GetSpellData(_R).level
                              local apDmg = myHero.ap * 0.7
                              local rDmg = baseDmg + lvlDmg + apDmg
                              local minHP = gsoSDK.Menu.rset.killsteal.minhp:Value()
                              if rDmg > minHP then
                                    local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(550, false, "spell")
                                    for i = 1, #enemyList do
                                          local rTarget = enemyList[i]
                                          if rTarget.health > minHP and rTarget.health < gsoSDK.Spell:CalculateDmg(rTarget, { dmgType = "ap", dmgAP = rDmg }) and gsoSDK.Spell:CastSpell(HK_R) then
                                                return
                                          end
                                    end
                              end
                        end
                        -- Combo / Harass
                        if (mode == "Combo" and gsoSDK.Menu.rset.comhar.combo:Value()) or (mode == "Harass" and gsoSDK.Menu.rset.comhar.harass:Value()) then
                              local count = 0
                              local xRange = gsoSDK.Menu.rset.comhar.xrange:Value()
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(550, false, "spell")
                              for i = 1, #enemyList do
                                    local unit = enemyList[i]
                                    if unit.pos:DistanceTo(myHero.pos) < xRange then
                                          count = count + 1
                                    end
                              end
                              if count >= gsoSDK.Menu.rset.comhar.xenemies:Value() and gsoSDK.Spell:CastSpell(HK_R) then
                                    return
                              end
                        -- Auto
                        elseif gsoSDK.Menu.rset.auto.enabled:Value() then
                              local count = 0
                              local xRange = gsoSDK.Menu.rset.auto.xrange:Value()
                              local enemyList = gsoSDK.ObjectManager:GetEnemyHeroes(550, false, "spell")
                              for i = 1, #enemyList do
                                    local unit = enemyList[i]
                                    if unit.pos:DistanceTo(myHero.pos) < xRange then
                                          count = count + 1
                                    end
                              end
                              if count >= gsoSDK.Menu.rset.auto.xenemies:Value() and gsoSDK.Spell:CastSpell(HK_R) then
                                    return
                              end
                        end
                  end
            end
      end
--[[
▒█░░░ ▒█▀▀▀█ ░█▀▀█ ▒█▀▀▄ 　 ░█▀▀█ ▒█░░░ ▒█░░░ 
▒█░░░ ▒█░░▒█ ▒█▄▄█ ▒█░▒█ 　 ▒█▄▄█ ▒█░░░ ▒█░░░ 
▒█▄▄█ ▒█▄▄▄█ ▒█░▒█ ▒█▄▄▀ 　 ▒█░▒█ ▒█▄▄█ ▒█▄▄█ 
]]
if myHero.charName == "Twitch" then
      __gsoTwitch()
elseif myHero.charName == "Ezreal" then
      __gsoEzreal()
elseif myHero.charName == "KogMaw" then
      __gsoKogMaw()
elseif myHero.charName == "Varus" then
      __gsoVarus()
elseif myHero.charName == "Brand" then
      __gsoBrand()
elseif myHero.charName == "Morgana" then
      __gsoMorgana()
else
      gsoSDK.Menu = MenuElement({name = "Gamsteron Test", id = "gamsteron", type = MENU })
      __gsoLoader()
      print("this hero is not supported")
end
