local gsoMyHero = myHero
local gsoMathSqrt = math.sqrt
local gsoDrawText = Draw.Text
local gsoGameTimer = Game.Timer
local gsoDrawColor = Draw.Color
local gsoDrawCircle = Draw.Circle
local gsoGetTickCount = GetTickCount
local gsoControlKeyUp = Control.KeyUp
local gsoControlKeyDown = Control.KeyDown
local gsoControlIsKeyDown = Control.IsKeyDown
local gsoControlSetCursor = Control.SetCursorPos
local gsoControlMouseEvent = Control.mouse_event
local gsoINFO = { version = "0.646", author = "gamsteron" }
class "__gsoTPred"
function  __gsoTPred:__init()
  self.GetDistanceSqr = function(p1, p2)
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
  end
  self.GetDistance = function(p1, p2)
    return math.sqrt(self.GetDistanceSqr(p1, p2))
  end
  self.CutWaypoints = function(Waypoints, distance, unit)
    local result = {}
    local remaining = distance
    if distance > 0 then
      for i = 1, #Waypoints -1 do
        local A, B = Waypoints[i], Waypoints[i + 1]
        if A and B then 
          local dist = self.GetDistance(A, B)
          if dist >= remaining then
            result[1] = Vector(A) + remaining * (Vector(B) - Vector(A)):Normalized()
            for j = i + 1, #Waypoints do
              result[j - i + 1] = Waypoints[j]
            end
            remaining = 0
            break
          else
            remaining = remaining - dist
          end
        end
      end
    else
      local A, B = Waypoints[1], Waypoints[2]
      result = Waypoints
      result[1] = Vector(A) - distance * (Vector(B) - Vector(A)):Normalized()
    end
    return result
  end
  self.GetCollisionPoint = function(t, sP1x, sP1y, S, K)
      return t and {x = sP1x+S*t, y = sP1y+K*t} or nil
  end
  self.VectorMovementCollision = function(startPoint1, endPoint1, v1, startPoint2, v2, delay)
    local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
    local d, e = eP1x-sP1x, eP1y-sP1y
    local dist, t1, t2 = math.sqrt(d*d+e*e), nil, nil
    local S, K = dist~=0 and v1*d/dist or 0, dist~=0 and v1*e/dist or 0
    if delay and delay~=0 then sP1x, sP1y = sP1x+S*delay, sP1y+K*delay end
    local r, j = sP2x-sP1x, sP2y-sP1y
    local c = r*r+j*j
    if dist>0 then
      if v1 == math.huge then
        local t = dist/v1
        t1 = v2*t>=0 and t or nil
      elseif v2 == math.huge then
        t1 = 0
      else
        local a, b = S*S+K*K-v2*v2, -r*S-j*K
        if a==0 then 
          if b==0 then --c=0->t variable
            t1 = c==0 and 0 or nil
          else --2*b*t+c=0
            local t = -c/(2*b)
            t1 = v2*t>=0 and t or nil
          end
        else --a*t*t+2*b*t+c=0
          local sqr = b*b-a*c
          if sqr>=0 then
            local nom = math.sqrt(sqr)
            local t = (-nom-b)/a
            t1 = v2*t>=0 and t or nil
            t = (nom-b)/a
            t2 = v2*t>=0 and t or nil
          end
        end
      end
    elseif dist==0 then
      t1 = 0
    end
    return t1, self.GetCollisionPoint(t1, sP1x, sP1y, S, K), t2, self.GetCollisionPoint(t2, sP1x, sP1y, S, K), dist
  end
  self.GetCurrentWayPoints = function(object)
    local result = {}
    if object.pathing.hasMovePath then
      table.insert(result, Vector(object.pos.x,object.pos.y, object.pos.z))
      for i = object.pathing.pathIndex, object.pathing.pathCount do
        path = object:GetPath(i)
        table.insert(result, Vector(path.x, path.y, path.z))
      end
    else
      table.insert(result, object and Vector(object.pos.x,object.pos.y, object.pos.z) or Vector(object.pos.x,object.pos.y, object.pos.z))
    end
    return result
  end
  self.GetWaypointsLength = function(Waypoints)
    local result = 0
    for i = 1, #Waypoints -1 do
      result = result + self.GetDistance(Waypoints[i], Waypoints[i + 1])
    end
    return result
  end
  self.CanMove = function(unit, delay)
    for i = 0, unit.buffCount do
      local buff = unit:GetBuff(i);
      if buff.count > 0 and buff.duration>=delay then
        if (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11) then
          return false -- block everything
        end
      end
    end
    return true
  end
  self.IsImmobile = function(unit, delay, radius, speed, from, spelltype)
    local ExtraDelay = speed == math.huge and 0 or (from and unit and unit.pos and (self.GetDistance(from, unit.pos) / speed))
    if (self.CanMove(unit, delay + ExtraDelay) == false) then
      return true
    end
    return false
  end
  self.CalculateTargetPosition = function(unit, delay, radius, speed, from, spelltype)
    local Waypoints = {}
    local Position, CastPosition = Vector(unit.pos), Vector(unit.pos)
    local t
    Waypoints = self.GetCurrentWayPoints(unit)
    local Waypointslength = self.GetWaypointsLength(Waypoints)
    local movementspeed = unit.pathing.isDashing and unit.pathing.dashSpeed or unit.ms
    if #Waypoints == 1 then
      Position, CastPosition = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z), Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
      return Position, CastPosition
    elseif (Waypointslength - delay * movementspeed + radius) >= 0 then
      local tA = 0
      Waypoints = self.CutWaypoints(Waypoints, delay * movementspeed - radius)
      if speed ~= math.huge then
        for i = 1, #Waypoints - 1 do
          local A, B = Waypoints[i], Waypoints[i+1]
          if i == #Waypoints - 1 then
            B = Vector(B) + radius * Vector(B - A):Normalized()
          end
          local t1, p1, t2, p2, D = self.VectorMovementCollision(A, B, movementspeed, Vector(from.x,from.y,from.z), speed)
          local tB = tA + D / movementspeed
          t1, t2 = (t1 and tA <= t1 and t1 <= (tB - tA)) and t1 or nil, (t2 and tA <= t2 and t2 <= (tB - tA)) and t2 or nil
          t = t1 and t2 and math.min(t1, t2) or t1 or t2
          if t then
            CastPosition = t==t1 and Vector(p1.x, 0, p1.y) or Vector(p2.x, 0, p2.y)
            break
          end
          tA = tB
        end
      else
        t = 0
        CastPosition = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
      end
      if t then
        if (self.GetWaypointsLength(Waypoints) - t * movementspeed - radius) >= 0 then
          Waypoints = self.CutWaypoints(Waypoints, radius + t * movementspeed)
          Position = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
        else
          Position = CastPosition
        end
      elseif unit.type ~= myHero.type then
        CastPosition = Vector(Waypoints[#Waypoints].x, Waypoints[#Waypoints].y, Waypoints[#Waypoints].z)
        Position = CastPosition
      end
    elseif unit.type ~= myHero.type then
      CastPosition = Vector(Waypoints[#Waypoints].x, Waypoints[#Waypoints].y, Waypoints[#Waypoints].z)
      Position = CastPosition
    end
    return Position, CastPosition
  end
  self.VectorPointProjectionOnLineSegment = function(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
  end
  self.CheckCol = function(unit, minion, Position, delay, radius, range, speed, from, draw)
    if unit.networkID == minion.networkID then 
      return false
    end
    local waypoints = self.GetCurrentWayPoints(minion)
    local MPos, CastPosition = #waypoints == 1 and Vector(minion.pos) or self.CalculateTargetPosition(minion, delay, radius, speed, from, "line")
    if from and MPos and self.GetDistanceSqr(from, MPos) <= (range)^2 and self.GetDistanceSqr(from, minion.pos) <= (range + 100)^2 then
      local buffer = (#waypoints > 1) and 8 or 0 
      if minion.type == myHero.type then
        buffer = buffer + minion.boundingRadius
      end
      if #waypoints > 1 then
        local proj1, pointLine, isOnSegment = self.VectorPointProjectionOnLineSegment(from, Position, Vector(MPos))
        if proj1 and isOnSegment and (self.GetDistanceSqr(MPos, proj1) <= (minion.boundingRadius + radius + buffer) ^ 2) then
          return true
        end
      end
      local proj2, pointLine, isOnSegment = self.VectorPointProjectionOnLineSegment(from, Position, Vector(minion.pos))
      if proj2 and isOnSegment and (self.GetDistanceSqr(minion.pos, proj2) <= (minion.boundingRadius + radius + buffer) ^ 2) then
        return true
      end
    end
  end
  self.CheckMinionCollision = function(unit, Position, delay, radius, range, speed, from, enemyMinions)
    Position = Vector(Position)
    from = from and Vector(from) or myHero.pos
    local result = false
    for i = 1, #enemyMinions do
      local minion = enemyMinions[i]
      if self.CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw) then
        return true
      end
    end
    return false
  end
  self.isSlowed = function(unit, delay, speed, from)
    for i = 0, unit.buffCount do
      local buff = unit:GetBuff(i);
      if from and unit and buff.count > 0 and buff.duration>=(delay + self.GetDistance(unit.pos, from) / speed) then
        if (buff.type == 10) then
          return true
        end
      end
    end
    return false
  end
  self.GetSpellInterceptTime = function(startPos, endPos, delay, speed)	
    local interceptTime = delay + self.GetDistance(startPos, endPos) / speed
    return interceptTime
  end
  self.TryGetBuff = function(unit, buffname)	
    for i = 1, unit.buffCount do 
      local Buff = unit:GetBuff(i)
      if Buff.name == buffname and Buff.duration > 0 then
        return Buff, true
      end
    end
    return nil, false
  end
  self.GetInteruptTarget = function(source, range, delay, speed, timingAccuracy)
    local target	
    for i = 1, Game.HeroCount() do
      local t = Game.Hero(i)
      if t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
        local dashEndPosition = t:GetPath(1)
        if self.GetDistance(source, dashEndPosition) <= range then				
          --The dash ends within range of our skill. We now need to find if our spell can connect with them very close to the time their dash will end
          local dashTimeRemaining = self.GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
          local skillInterceptTime = self.GetSpellInterceptTime(myHero.pos, dashEndPosition, delay, speed)
          local deltaInterceptTime = math.abs(skillInterceptTime - dashTimeRemaining)
          if deltaInterceptTime < timingAccuracy then
            target = t
            return target
          end
        end			
      end
    end
  end
  self.GetBestCastPosition = function(unit, delay, radius, range, speed, from, collision, spelltype, enemyMinions, timeThreshold)
    if not timeThreshold then
      timeThreshold = .35
    end	
    range = range and range - 4 or math.huge
    radius = radius == 0 and 1 or radius - 4
    speed = speed and speed or math.huge
    if not from then
      from = Vector(myHero.pos)
    end
    local IsFromMyHero = self.GetDistanceSqr(from, myHero.pos) < 50*50 and true or false
    delay = delay + (0.07 + Game.Latency() / 2000)
    local Position, CastPosition = self.CalculateTargetPosition(unit, delay, radius, speed, from, spelltype)
    local HitChance = 1
    Waypoints = self.GetCurrentWayPoints(unit)
    if (#Waypoints == 1) then
      HitChance = 2
    end
    if self.isSlowed(unit, delay, speed, from) then
      HitChance = 2
    end
    if self.GetDistance(myHero.pos, unit.pos) < 250 then
      HitChance = 2
      Position, CastPosition = self.CalculateTargetPosition(unit, delay*0.5, radius, speed*2, from, spelltype)
      Position = CastPosition
    end
    local angletemp = Vector(from):AngleBetween(Vector(unit.pos), Vector(CastPosition))
    if angletemp > 60 then
      HitChance = 1
    elseif angletemp < 10 then
      HitChance = 2
    end
    if (unit.activeSpell and unit.activeSpell.valid) then
      HitChance = 2
      local timeToAvoid = radius / unit.ms +  unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer() 
      local timeToIntercept = self.GetSpellInterceptTime(from, unit.pos, delay, speed)
      local deltaInterceptTime = timeToIntercept - timeToAvoid		
      if deltaInterceptTime < timeThreshold then
        HitChance = 4
        CastPosition = unit.pos
      end		
    end
    if (self.IsImmobile(unit, delay, radius, speed, from, spelltype)) then
      HitChance = 5
      CastPosition = unit.pos
    end
    --[[Out of range]]
    if IsFromMyHero then
      if (spelltype == "line" and self.GetDistanceSqr(from, Position) >= range * range) then
        HitChance = 0
      end
      if (spelltype == "circular" and (self.GetDistanceSqr(from, Position) >= (range + radius)^2)) then
        HitChance = 0
      end
      if from and Position and (self.GetDistanceSqr(from, Position) > range ^ 2) then
        HitChance = 0
      end
    end
    radius = radius*2
    if collision and HitChance > 0 then
      if collision and self.CheckMinionCollision(unit, unit.pos, delay, radius, range, speed, from, enemyMinions) then
        HitChance = -1
      elseif self.CheckMinionCollision(unit, Position, delay, radius, range, speed, from, enemyMinions) then
        HitChance = -1
      elseif self.CheckMinionCollision(unit, CastPosition, delay, radius, range, speed, from, enemyMinions) then
        HitChance = -1
      end
    end
    if not CastPosition or not Position then
      HitChance = -1
    end
    return CastPosition, HitChance, Position
  end
end

class "__gsoItems"

function __gsoItems:__init()
  self.menu = itemMenu
  self.itemList = {
    [3144] = { i = nil, hk = nil },
    [3153] = { i = nil, hk = nil }
  }
  self.lastBotrk = 0
  self.performance = 0
  self._botrk = function()
    local hkKey = nil
    if GetTickCount() < self.lastBotrk + 1000 then return false end
    local itmSlot1 = self.itemList[3144].i
    local itmSlot2 = self.itemList[3153].i
    if itmSlot1 and myHero:GetSpellData(itmSlot1).currentCd == 0 then
      hkKey = self.itemList[3144].hk
    elseif itmSlot2 and myHero:GetSpellData(itmSlot2).currentCd == 0 then
      hkKey = self.itemList[3153].hk
    end
    return hkKey
  end
  Callback.Add('Tick', function()
    local getTick = GetTickCount()
    if getTick > self.performance + 500 then
      self.performance = GetTickCount()
      local t = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7 }
      local t2 = { [3153] = 0, [3144] = 0 }
      for i = 1, #t do
        local item = t[i]
        local itemID = gsoMyHero:GetItemData(item).itemID
        local t2Item = t2[itemID]
        if t2Item then
          t2[itemID] = t2Item + 1
        end
        if self.itemList[itemID] then
          self.itemList[itemID].i = item
          local t3 = { HK_ITEM_1, HK_ITEM_2, HK_ITEM_3, HK_ITEM_4, HK_ITEM_5, HK_ITEM_6, HK_ITEM_7 }
          self.itemList[itemID].hk = t3[i]
        end
      end
      for k,v in pairs(self.itemList) do
        local itm = self.itemList[k]
        if t2[k] == 0 and (itm.i or itm.hk) then
          self.itemList[k].i = nil
          self.itemList[k].hk = nil
        end
      end
    end
  end)
end
local gsoMenu
local gsoMode
local gsoLoaded = false
local gsoDelayedSpell = {}
local gsoSpellData = { q = {}, w = {}, e = {}, r = {} }
local gsoDrawData = { q = false, w = false, e = false, r = false }
local gsoSpellState = { q = true, lq = 0, lqk = 0, w = true, lw = 0, lwk = 0, e = true, le = 0, lek = 0, r = true, lr = 0, lrk = 0 }
function OnLoad()
  local gsoOrbwalker = __gsoOrbwalker()
        gsoMenu = gsoOrbwalker.Menu
        gsoMode = gsoOrbwalker.Mode
  local gsoActions = gsoOrbwalker.DelayedActions
  local gsoTimers = gsoOrbwalker.Timers
  local gsoState = gsoOrbwalker.State
  local gsoExtra = gsoOrbwalker.Extra
  local gsoObjects = gsoOrbwalker.Objects
  local gsoItems = __gsoItems()
  local gsoTPred = __gsoTPred()
  local gsoDistance = gsoOrbwalker.Distance
  local gsoExtended = gsoOrbwalker.Extended
  local gsoImmortal = gsoOrbwalker.IsImmortal
  local gsoSetCursor = gsoOrbwalker.CursorPositionChanged
  local gsoHPPred = gsoOrbwalker.MinionHealthPrediction
  local gsoGetTarget = gsoOrbwalker.GetTarget
  local gsoCalcDmg = gsoOrbwalker.CalculateDamage
  local function gsoClosestPointOnLineSegment(p, p1, p2)
    local px,pz,py = p.x, p.z, p.y
    local ax,az,ay = p1.x, p1.z, p1.y
    local bx,bz,by = p2.x, p2.z, p2.y
    local bxax = bx - ax
    local bzaz = bz - az
    local byay = by - by
    local t = ((px - ax) * bxax + (pz - az) * bzaz + (py - ay) * byay) / (bxax * bxax + bzaz * bzaz + byay * byay)
    if t < 0 then
      return p1, false
    elseif t > 1 then
      return p2, false
    else
      return Vector({ x = ax + t * bxax, z = az + t * bzaz, y = ay + t * byay }), true
    end
  end
  local function gsoCheckWall(from, to, distance)
    local pos1 = to + (to-from):Normalized() * 50
    local pos2 = pos1 + (to-from):Normalized() * (distance - 50)
    local point1 = Point(pos1.x, pos1.z)
    local point2 = Point(pos2.x, pos2.z)
    if (MapPosition:inWall(point1) and MapPosition:inWall(point2)) or MapPosition:intersectsWall(LineSegment(point1, point2)) then
      return true
    end
    return false
  end
  local function gsoCheckHeroesCollision(p1, p2, width, id)
    local gsoEHeroes = gsoObjects.enemyHeroes
    for i = 1, #gsoEHeroes do
      local hero = gsoEHeroes[i]
      if hero.visible and hero.networkID ~= id then
        local heroPos = hero.pos
        local point,onLineSegment = gsoClosestPointOnLineSegment(heroPos, p1, p2)
        local distanceToPoint = gsoDistance(heroPos, point)
        if distanceToPoint < width + hero.boundingRadius + 25 then
          return true
        end
      end
    end
    return false
  end
  local function gsoCheckMinionsCollision(p1, p2, width, id)
    local gsoEMinions = gsoObjects.enemyMinions
    for i = 1, #gsoEMinions do
      local minion = gsoEMinions[i]
      if minion.networkID ~= id then
        local minionPos = minion.pos
        local point,onLineSegment = gsoClosestPointOnLineSegment(minionPos, p1, p2)
        local distanceToPoint = gsoDistance(minionPos, point)
        if distanceToPoint < width + minion.boundingRadius + 25 then
          return true
        end
      end
    end
    return false
  end
  local function gsoGetCastPos(spellData, sourcePos, target, from)
    local tP = target.pos
    local sD = spellData
    local castpos,HitChance,pos = gsoTPred.GetBestCastPosition(target, sD.delay, sD.width*0.5, sD.range, sD.speed, sourcePos, sD.col, sD.sType, gsoObjects.enemyMinions)
    if HitChance > 0 and gsoDistance(tP, castpos) < 500 then
      local distanceToSource = gsoDistance(sourcePos, castpos)
      if distanceToSource < 150 or distanceToSource > sD.range then
        return nil
      end
      if sD.hCol then
        local id = from.hero and target.networkID or 0
        if gsoCheckHeroesCollision(sourcePos, castpos, sD.width, id) then
          return nil
        end
      end
      if sD.mCol then
        local id = from.minion and target.networkID or 0
        if gsoCheckMinionsCollision(sourcePos, castpos, sD.width, id) then
          return nil
        end
      end
      return castpos
    end
    return nil
  end
  local function gsoBuffCount(unit, bName)
    for i = 0, unit.buffCount do
      local buff = unit:GetBuff(i)
      if buff and buff.count > 0 and buff.name:lower() == bName then
        return buff.count
      end
    end
    return 0
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
  local function gsoBuffDuration(unit, bName)
    for i = 0, unit.buffCount do
      local buff = unit:GetBuff(i)
      if buff and buff.count > 0 and buff.name:lower() == bName then
        return buff.duration
      end
    end
    return 0
  end
  local function gsoIsImmobile(unit, time)
    for i = 0, unit.buffCount do
      local buff = unit:GetBuff(i)
      if buff and buff.count > 0 then
        local bType = buff.type
        if (bType == 5 or bType == 11 or bType == 29 or bType == 24 or buff.name == "recall") and buff.duration <= time then
          return true
        end
      end
    end
    return false
  end
  local function gsoImmobileTime(unit)
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
  local function gsoGetImmobileEnemy(sourcePos, enemyList, maxDistance)
    local result = nil
    local num = 0
    for i = 1, #enemyList do
      local hero = enemyList[i]
      local distance = gsoDistance(sourcePos, hero.pos)
      local iT = gsoImmobileTime(hero)
      if distance < maxDistance and iT > num then
        num = iT
        result = hero
      end
    end
    return result
  end
  local function gsoGetClosestEnemy(sourcePos, enemyList, maxDistance)
    local result = nil
    for i = 1, #enemyList do
      local hero = enemyList[i]
      local distance = gsoDistance(sourcePos, hero.pos)
      if distance < maxDistance then
        maxDistance = distance
        result = hero
      end
    end
    return result
  end
  local function gsoCountEnemyHeroesInRange(sourcePos, range, bb)
    local count = 0
    local gsoEHeroes = gsoObjects.enemyHeroes
    for i = 1, #gsoEHeroes do
      local unit = gsoEHeroes[i]
      local extraRange = bb and unit.boundingRadius or 0
      if gsoDistance(sourcePos, unit.pos) < range + extraRange then
        count = count + 1
      end
    end
    return count
  end
  local function gsoPosOnEnemyBoundingRadius(pos, id, to, units)
    if units.minions then
      local gsoEMinions = gsoObjects.enemyMinions
      for i = 1, #gsoEMinions do
        local unit = gsoEMinions[i]
        local canCheck = to.minion and id ~= unit.networkID
        if canCheck and gsoDistance(pos, unit.pos) < unit.boundingRadius then
          return true
        end
      end
    end
    if units.heroes then
      local gsoEHeroes = gsoObjects.enemyHeroes
      for i = 1, #gsoEHeroes do
        local unit = gsoEHeroes[i]
        local canCheck = to.hero and id ~= unit.networkID
        if unit.visible and canCheck and gsoDistance(pos, unit.pos) < unit.boundingRadius then
          return true
        end
      end
    end
    if units.turrets then
      local gsoETurrets = gsoObjects.enemyTurrets
      for i = 1, #gsoETurrets do
        local unit = gsoETurrets[i]
        if gsoDistance(pos, unit.pos) < unit.boundingRadius then
          return true
        end
      end
    end
    return false
  end
  local function gsoCheckTimers(sT)
    local gT = GetTickCount() - ( gsoExtra.minLatency * 1000 )
    local q = gT - gsoSpellState.lq
    local qq = gT - gsoSpellState.lqk
    local w = gT - gsoSpellState.lw
    local ww = gT - gsoSpellState.lwk
    local e = gT - gsoSpellState.le
    local ee = gT - gsoSpellState.lek
    local r = gT - gsoSpellState.lr
    local rr = gT - gsoSpellState.lrk
    local sq = sT.q
    local sw = sT.w
    local se = sT.e
    local sr = sT.r
    if q > sq and qq > sq and w > sw and ww > sw and e > se and ee > se and r > sr and rr > sr then
      return true
    end
    return false
  end
  local function gsoCastSpell(hkSpell)
    Control.KeyDown(hkSpell)
    Control.KeyUp(hkSpell)
    gsoTimers.lastMoveSend = 0
    return true
  end
  local function gsoCastSpellTarget(hkSpell, range, sourcePos, target, to, units)
    local castpos = target and target.pos or nil
    local canCast = castpos and sourcePos and gsoDistance(castpos, sourcePos) < range
          canCast = canCast and not gsoPosOnEnemyBoundingRadius(castpos, target.networkID, to, units) and castpos:ToScreen().onScreen
    if canCast then
      local cPos = cursorPos
      Control.SetCursorPos(castpos)
      Control.KeyDown(hkSpell)
      Control.KeyUp(hkSpell)
      gsoSetCursor({ endTime = GetTickCount() + 50, action = function() Control.SetCursorPos(cPos.x, cPos.y) end, active = true }, castpos)
      gsoTimers.lastMoveSend = 0
      return true
    end
    return false
  end
  local function gsoCastSpellSkillShot(hkSpell, sourcePos, target, from)
    local spellData
    if hkSpell == HK_Q then spellData = gsoSpellData.q elseif hkSpell == HK_W then spellData = gsoSpellData.w elseif hkSpell == HK_E then spellData = gsoSpellData.e elseif hkSpell == HK_R then spellData = gsoSpellData.r end
    local castpos = target.x and target or gsoGetCastPos(spellData, sourcePos, target, from)
    if castpos then
      castpos = spellData.out and sourcePos:Extended(castpos, 500) or castpos
      if castpos:ToScreen().onScreen then
        local cPos = cursorPos
        Control.SetCursorPos(castpos)
        Control.KeyDown(hkSpell)
        Control.KeyUp(hkSpell)
        gsoSetCursor({ endTime = GetTickCount() + 50, action = function() Control.SetCursorPos(cPos.x, cPos.y) end, active = true }, castpos)
        gsoTimers.lastMoveSend = 0
        return true
      end
    end
    return false
  end
  local function gsoIsReady(spell, sT)
    return not gsoState.isChangingCursorPos and gsoCheckTimers(sT) and Game.CanUseSpell(spell) == 0
  end
  local function gsoIsReadyFast(spell, sT)
    return gsoCheckTimers(sT) and Game.CanUseSpell(spell) == 0
  end
  local gsoLoadMyHero = {
    __Aatrox = function() end,
    __Ahri = function() end,
    __Akali = function() end,
    __Alistar = function() end,
    __Amumu = function() end,
    __Anivia = function() end,
    __Annie = function() end,
    
    
    
    
    
    
    
    

    
    
    __Ashe = function()
      local champInfo = { hasQBuff = false, qEndTime = 0, asNoQ = myHero.attackSpeed, oldWindUp = myHero.attackData.windUpTime }
      local gsoMeMenu = gsoMenu:MenuElement({id = "gsoashe", name = "Ashe", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ashe.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
          gsoMeMenu.rset:MenuElement({id = "combo", name = "Use R Combo", value = true})
          gsoMeMenu.rset:MenuElement({id = "harass", name = "Use R Harass", value = false})
          gsoMeMenu.rset:MenuElement({id = "rci", name = "Use R if enemy isImmobile", value = true})
          gsoMeMenu.rset:MenuElement({id = "rcd", name = "Use R if enemy distance < X", value = true})
          gsoMeMenu.rset:MenuElement({id = "rdist", name = "use R if enemy distance < X", value = 500, min = 250, max = 1000, step = 50})
          gsoMeMenu.rset:MenuElement({name = "R Semi Manual", id = "semirashe", type = MENU })
            gsoMeMenu.rset.semirashe:MenuElement({name = "Semi-Manual Key", id = "enabled", key = string.byte("T")})
            gsoMeMenu.rset.semirashe:MenuElement({name = "Only enemies with HP < X%", id = "semilow", value = true})
            gsoMeMenu.rset.semirashe:MenuElement({name = "X %", id = "semip", value = 100, min = 1, max = 100, step = 1 })
            gsoMeMenu.rset.semirashe:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
            gsoMeMenu.rset.semirashe:MenuElement({name = "Use on:", id = "useon", type = MENU })
      gsoDrawData = { w = true, wr = 1200 }
      gsoSpellData.w = { delay = 0.25, range = 1200, width = 50, speed = 2000, sType = "line", col = true, hCol = true, mCol = true, out = true }
      gsoSpellData.r = { delay = 0.25, range = 1500, width = 125, speed = 1600, sType = "line", col = false, hCol = true, mCol = false, out = true }
      gsoOrbwalker:OnEnemyHeroLoad(function(heroName)
        gsoMeMenu.rset.semirashe.useon:MenuElement({id = heroName, name = heroName, value = true})
      end)
      gsoOrbwalker:BonusDamageOnMinion2(function(unit)
        local dmg = gsoMyHero.totalDamage
        local crit = 0.1 + gsoMyHero.critChance
        local aaData = gsoMyHero.attackData
        local mePos = gsoMyHero.pos
        for i = 0, unit.buffCount do
          local buff = unit:GetBuff(i)
          if buff and buff.count > 0 and buff.name:lower() == "ashepassiveslow" then
            local aacompleteT = aaData.windUpTime + (gsoDistance(mePos, unit.pos) / aaData.projectileSpeed)
            if aacompleteT + 0.1 < buff.duration then
              return dmg * crit
            end
          end
        end
        return 0
      end)
      gsoOrbwalker:AttackSpeed(function()
        local num = gsoGameTimer() - champInfo.qEndTime
        if num > -champInfo.oldWindUp and num < 2 then
          return champInfo.asNoQ
        end
        return gsoMyHero.attackSpeed
      end)
      gsoOrbwalker:OnMove(function(args)
        local target = args.Target
        local isTarget = target ~= nil
        local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        local mePos = gsoMyHero.pos
        local enemyList = {}
        for i = 1, #gsoObjects.enemyHeroes do
          local hero = gsoObjects.enemyHeroes[i]
          if hero and hero.visible and not gsoImmortal(hero, false) then
            enemyList[#enemyList+1] = hero
          end
        end
        
        if not gsoState.enabledAttack and gsoCheckTimers({ q = 0, w = 300, e = 300, r = 300 }) then
          gsoState.enabledAttack = true
        end
        
        -- USE R :
        local canR = ( isCombo and gsoMeMenu.rset.combo:Value() ) or ( isHarass and gsoMeMenu.rset.harass:Value() )
              canR = canR and (not isTarget or gsoSpellState.r) and gsoIsReady(_R, { q = 0, w = 250, e = 250, r = 1000 })
        if canR then
          if gsoMeMenu.rset.rcd:Value() then
            local t = gsoGetClosestEnemy(mePos, enemyList, gsoMeMenu.rset.rdist:Value())
            if t and gsoCastSpellSkillShot(HK_R, mePos, t, { hero = true, minion = false }) then
              gsoSpellState.lr = GetTickCount()
              gsoSpellState.w = false
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
          if gsoMeMenu.rset.rci:Value() then
            local t = gsoGetImmobileEnemy(mePos, enemyList, 1000)
            if t and gsoCastSpellSkillShot(HK_R, mePos, t.pos, { hero = true, minion = false }) then
              gsoSpellState.lr = GetTickCount()
              gsoSpellState.w = false
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
        end

        -- USE Q :
        local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
        if canQ and isTarget and gsoIsReadyFast(_Q, { q = 1000, w = 250, e = 250, r = 250 }) then
          local aaSpeed = ( gsoMyHero.attackSpeed + 0.15 + (gsoMyHero:GetSpellData(_Q).level * 0.05) ) * gsoExtra.baseAttackSpeed
          local numAS   = aaSpeed >= 2.5 and 1 / 2.5 or 1 / aaSpeed
          if gsoGameTimer() > gsoTimers.lastAttackSend + numAS and gsoCastSpell(HK_Q) then
            champInfo.oldWindUp = gsoTimers.windUpTime
            champInfo.asNoQ = myHero.attackSpeed
            gsoSpellState.lq = GetTickCount()
            gsoExtra.resetAttack = true
            args.Process = false
            return
          end
        end
        if not isTarget or afterAttack then
          -- USE W :
          local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                canW = canW and (not isTarget or gsoSpellState.w) and gsoIsReady(_W, { q = 0, w = 1000, e = 250, r = 250 })
          if canW then
            local t = isTarget and target or gsoGetTarget(1200, gsoMyHero.pos, enemyList, "ad", false, false)
            if t and gsoCastSpellSkillShot(HK_W, mePos, t, { hero = true, minion = false }) then
              gsoSpellState.lw = GetTickCount()
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
        end
        if not gsoCheckTimers({ q = 0, w = 250, e = 250, r = 250 }) then
          args.Process = false
        end
      end)
      gsoOrbwalker:OnTick(function()
        local qDuration = gsoBuffDuration(gsoMyHero, "asheqattack")
        champInfo.hasQBuff = qDuration > 0
        champInfo.qEndTime = qDuration > 0 and Game.Timer() + qDuration or champInfo.qEndTime
        if gsoMeMenu.rset.semirashe.enabled:Value() and gsoIsReady(_R, { q = 0, w = 250, e = 250, r = 1000 }) then
          local enemyList = {}
          for i = 1, #gsoObjects.enemyHeroes do
            local hero = gsoObjects.enemyHeroes[i]
            if hero and hero.visible and not gsoImmortal(hero, false) then
              enemyList[#enemyList+1] = hero
            end
          end
          local rTargets = {}
          for i = 1, #enemyList do
            local hero = enemyList[i]
            local heroName = hero.charName
            local isFromList = gsoMeMenu.rset.semirashe.useon[heroName] and gsoMeMenu.rset.semirashe.useon[heroName]:Value()
            local hpPercent = gsoMeMenu.rset.semirashe.semilow:Value() and gsoMeMenu.rset.semirashe.semip:Value() or 100
            local isLowHP = isFromList and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if isLowHP then
              rTargets[#rTargets+1] = hero
            end
          end
          local rrange = gsoMeMenu.rset.semirashe.rrange:Value()
          local rTarget = gsoGetTarget(rrange, gsoMyHero.pos, rTargets, "ad", false, false)
          if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget, { hero = true, minion = false }) then
            gsoSpellState.lr = GetTickCount()
            gsoState.enabledAttack = false
          end
        end
      end)
      gsoOrbwalker:OnIssue(function(issue)
        if issue.attack then
          gsoSpellState.q = true; gsoSpellState.w = true; gsoSpellState.e = true; gsoSpellState.r = true
        end
      end)
    end,
    
    
    
    
    
    
    
    
    
    
    __AurelionSol = function() end,
    __Azir = function() end,
    __Bard = function() end,
    __Blitzcrank = function() end,
    __Brand = function() end,
    __Braum = function() end,
    __Caitlyn = function() end,
    __Camille = function() end,
    __Cassiopeia = function() end,
    __Chogath = function() end,
    __Corki = function() end,
    __Darius = function() end,
    __Diana = function() end,
    __DrMundo = function() end,
    __Draven = function() end,
    __Ekko = function() end,
    __Elise = function() end,
    __Evelynn = function() end,
    __Ezreal = function() end,
    __Fiddlesticks = function() end,
    __Fiora = function() end,
    __Fizz = function() end,
    __Galio = function() end,
    __Gangplank = function() end,
    __Garen = function() end,
    __Gnar = function() end,
    __Gragas = function() end,
    __Graves = function() end,
    __Hecarim = function() end,
    __Heimerdinger = function() end,
    __Illaoi = function() end,
    __Irelia = function() end,
    __Ivern = function() end,
    __Janna = function() end,
    __JarvanIV = function() end,
    __Jax = function() end,
    __Jayce = function() end,
    __Jhin = function() end,
    
    
    
    
    
    
    
    
    
    __Jinx = function()
      local champInfo = { hasQBuff = false }
      local gsoMeMenu = gsoMenu:MenuElement({id = "gsojinx", name = "Jinx", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/jinx.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "wout", name = "W only if enemy out of attack range", value = false})
          gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
          gsoMeMenu.rset:MenuElement({name = "Semi Manual", id = "semirjinx", type = MENU })
            gsoMeMenu.rset.semirjinx:MenuElement({name = "Semi-Manual Key", id = "enabled", key = string.byte("T")})
            gsoMeMenu.rset.semirjinx:MenuElement({name = "Only enemies with HP < X%", id = "semilow",  value = true})
            gsoMeMenu.rset.semirjinx:MenuElement({name = "X %", id = "semip", value = 35, min = 1, max = 100, step = 1 })
            gsoMeMenu.rset.semirjinx:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
            gsoMeMenu.rset.semirjinx:MenuElement({name = "Use on:", id = "useon", type = MENU })
      local _jinxQ = function()
        if champInfo.hasQBuff then
          return 525 + gsoMyHero.boundingRadius + 35
        else
          local qExtra = 25 * gsoMyHero:GetSpellData(_Q).level
          return 575 + qExtra + myHero.boundingRadius + 35
        end
      end
      gsoDrawData = { q = true, qf = function() return _jinxQ() end, w = true, wr = 1450, e = true, er = 900 }
      gsoSpellData.w = { delay = 0.5, range = 1450, width = 70, speed = 3200, sType = "line", col = true, hCol = true, mCol = true, out = true }
      gsoSpellData.r = { delay = 0.5, range = 0, width = 225, speed = 1750, sType = "line", col = false, hCol = true, mCol = false, out = true }
      gsoOrbwalker:OnEnemyHeroLoad(function(heroName)
        gsoMeMenu.rset.semirjinx.useon:MenuElement({id = heroName, name = heroName, value = true})
      end)
      gsoOrbwalker:OnMove(function(args)
        local target = args.Target
        local isTarget = target ~= nil
        local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        local mePos = gsoMyHero.pos
        local enemyList = {}
        for i = 1, #gsoObjects.enemyHeroes do
          local hero = gsoObjects.enemyHeroes[i]
          if hero and hero.visible and not gsoImmortal(hero, false) then
            enemyList[#enemyList+1] = hero
          end
        end
        
        if not gsoCheckTimers({ q = 0, w = 500, e = 0, r = 500 }) then
          args.Process = false
        end
        if not gsoState.enabledAttack and gsoCheckTimers({ q = 0, w = 600, e = 0, r = 600 }) then
          gsoState.enabledAttack = true
        end
        
        -- USE E :
        local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
        if canE and gsoIsReady(_E, { q = 650, w = 550, e = 1000, r = 550 }) then
          local t = gsoGetImmobileEnemy(mePos, enemyList, 900)
          if t and gsoCastSpellTarget(HK_E, 900, mePos, t, {}, {}) then
            gsoSpellState.le = gsoGetTickCount()
            args.Process = false
            return
          end
        end
        
        -- USE Q :
        local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
        if canQ and gsoIsReadyFast(_Q, { q = 650, w = 550, e = 75, r = 550 }) then
          local canCastQ = false
          local extraQ = 25 * myHero:GetSpellData(_Q).level
          local qRange = 575 + extraQ
          if not isTarget and not champInfo.hasQBuff and gsoCountEnemyHeroesInRange(mePos, qRange + 300, false) > 0 then
            canCastQ = true
          end
          if isTarget and champInfo.hasQBuff and gsoDistance(mePos, target.pos) < 525 + gsoMyHero.boundingRadius then
            canCastQ = true
          end
          if canCastQ and gsoCastSpell(HK_Q) then
            gsoSpellState.lq = gsoGetTickCount()
            args.Process = false
            return
          end
        end
        
        -- USE W :
        if not isTarget or afterAttack then
          local wout = gsoMeMenu.wset.wout:Value()
          if not wout or not isTarget then
            local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
            if canW and gsoIsReady(_W, { q = 0, w = 1000, e = 75, r = 550 }) and (not isTarget or gsoSpellState.w) then
              local wTarget
              if isTarget then
                wTarget = target
              else
                wTarget = gsoGetTarget(1450, gsoMyHero.pos, enemyList, "ad", false, false)
              end
              if wTarget and gsoCastSpellSkillShot(HK_W, mePos, wTarget, {hero = true}) then
                gsoSpellState.lw = gsoGetTickCount()
                gsoState.enabledAttack = false
                args.Process = false
                return
              end
            end
          end
        end
      end)
      gsoOrbwalker:OnTick(function()
        champInfo.hasQBuff = gsoHasBuff(gsoMyHero, "jinxq")
        -- semi r
        if gsoMeMenu.rset.semirjinx.enabled:Value() and gsoIsReady(_R, { q = 0, w = 550, e = 75, r = 1000 }) then
          local enemyList = {}
          for i = 1, #gsoObjects.enemyHeroes do
            local hero = gsoObjects.enemyHeroes[i]
            if hero and hero.visible and not gsoImmortal(hero, false) then
              enemyList[#enemyList+1] = hero
            end
          end
          local rTargets = {}
          for i = 1, #enemyList do
            local hero = enemyList[i]
            local heroName = hero.charName
            local isFromList = gsoMeMenu.rset.semirjinx.useon[heroName] and gsoMeMenu.rset.semirjinx.useon[heroName]:Value()
            local hpPercent = gsoMeMenu.rset.semirjinx.semilow:Value() and gsoMeMenu.rset.semirjinx.semip:Value() or 100
            local isLowHP = isFromList and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if isLowHP then
              rTargets[#rTargets+1] = hero
            end
          end
          local rrange = gsoMeMenu.rset.semirjinx.rrange:Value()
          local rTarget = gsoGetTarget(rrange, gsoMyHero.pos, rTargets, "ad", false, false)
          gsoSpellData.r.range = gsoMeMenu.rset.semirjinx.rrange:Value()
          if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget, {hero = true}) then
            gsoSpellState.lr = GetTickCount()
            gsoState.enabledAttack = false
          end
        end
      end)
      gsoOrbwalker:OnIssue(function(issue)
        if issue.attack then
          gsoSpellState.q = true; gsoSpellState.w = true; gsoSpellState.e = true; gsoSpellState.r = true
        end
      end)
    end,
    
    
    
    
    
    
    
    
    __Kalista = function() end,
    __Karma = function() end,
    __Karthus = function() end,
    __Kassadin = function() end,
    __Katarina = function() end,
    __Kayle = function() end,
    __Kayn = function() end,
    __Kennen = function() end,
    __Khazix = function() end,
    __Kindred = function() end,
    __Kled = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __KogMaw = function()
      local champInfo = { hasWBuff = false }
      local gsoMeMenu = gsoMenu:MenuElement({id = "gsokog", name = "KogMaw", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kog.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
            gsoMeMenu.wset:MenuElement({id = "stopq", name = "Stop Q if has W buff", value = false})
            gsoMeMenu.wset:MenuElement({id = "stope", name = "Stop E if has W buff", value = false})
            gsoMeMenu.wset:MenuElement({id = "stopr", name = "Stop R if has W buff", value = false})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
            gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
            gsoMeMenu.eset:MenuElement({id = "emana", name = "Minimum Mana %", value = 20, min = 1, max = 100, step = 1 })
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
            gsoMeMenu.rset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.rset:MenuElement({id = "harass", name = "Harass", value = false})
            gsoMeMenu.rset:MenuElement({id = "onlylow", name = "Only 0-40 % HP enemies", value = true})
            gsoMeMenu.rset:MenuElement({id = "stack", name = "Stop at x stacks", value = 3, min = 1, max = 9, step = 1 })
            gsoMeMenu.rset:MenuElement({id = "rmana", name = "Minimum Mana %", value = 20, min = 1, max = 100, step = 1 })
            gsoMeMenu.rset:MenuElement({name = "KS", id = "ksmenu", type = MENU })
                gsoMeMenu.rset.ksmenu:MenuElement({id = "ksr", name = "KS - Enabled", value = true})
                gsoMeMenu.rset.ksmenu:MenuElement({id = "csksr", name = "KS -> Check R stacks", value = false})
            gsoMeMenu.rset:MenuElement({name = "Semi Manual", id = "semirkog", type = MENU })
                gsoMeMenu.rset.semirkog:MenuElement({name = "Semi-Manual Key", id = "semir", key = string.byte("T")})
                gsoMeMenu.rset.semirkog:MenuElement({name = "Check R stacks", id = "semistacks", value = false})
                gsoMeMenu.rset.semirkog:MenuElement({name = "Only 0-40 % HP enemies", id = "semilow",  value = false})
                gsoMeMenu.rset.semirkog:MenuElement({name = "Use on:", id = "useon", type = MENU })
      local _kogR = function()
        local rlvl = gsoMyHero:GetSpellData(_R).level
        if rlvl == 0 then
          return 1200
        else
          local extraR = 300 * rlvl
          return 900 + extraR
        end
      end
      gsoDrawData = { q = true, qr = 1175, e = true, er = 1280, r = true, rf = function() return _kogR() end }
      gsoSpellData.q = { delay = 0.25, range = 1175, width = 70, speed = 1650, sType = "line", col = true, hCol = true, mCol = true, out = true }
      gsoSpellData.e = { delay = 0.25, range = 1280, width = 120, speed = 1350, sType = "line", col = false, hCol = false, mCol = false, out = true }
      gsoSpellData.r = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false, hCol = false, mCol = false, out = false }
      gsoOrbwalker:OnEnemyHeroLoad(function(heroName)
        gsoMeMenu.rset.semirkog.useon:MenuElement({id = heroName, name = heroName, value = true})
      end)
    
    
    -- KOG ONMOVE
      gsoOrbwalker:OnMove(function(args)
        local target = args.Target
        local isTarget = target ~= nil
        local afterAttack = gsoGameTimer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        local mePos = gsoMyHero.pos
        local enemyList = {}
        for i = 1, #gsoObjects.enemyHeroes do
          local hero = gsoObjects.enemyHeroes[i]
          if hero and hero.visible and not gsoImmortal(hero, false) then
            enemyList[#enemyList+1] = hero
          end
        end
        
        if not gsoCheckTimers({ q = 250, w = 0, e = 250, r = 250 }) then
          args.Process = false
        end
        if not gsoState.enabledAttack and gsoCheckTimers({ q = 350, w = 0, e = 350, r = 350 }) then
          gsoState.enabledAttack = true
        end
        
        -- USE W :
        local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
              canW = canW and gsoIsReadyFast(_W, { q = 250, w = 1000, e = 250, r = 250 })
              canW = canW and gsoGameTimer() > gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.5 )
        if canW then
          for i = 1, #enemyList do
            local hero = enemyList[i]
            if gsoDistance(mePos, hero.pos) < 610 + ( 20 * gsoMyHero:GetSpellData(_W).level ) + gsoMyHero.boundingRadius + hero.boundingRadius and gsoCastSpell(HK_W) then
              gsoSpellState.lw = GetTickCount()
              gsoSpellState.q = false
              gsoSpellState.e = false
              gsoSpellState.r = false
              return
            end
          end
        end
        
        if not isTarget or afterAttack then
          
          local wMana = 40 - ( gsoMyHero:GetSpellData(_W).currentCd * gsoMyHero.mpRegen )
          local meMana = gsoMyHero.mana - wMana
          
          if not isTarget and gsoGetTickCount() - gsoSpellState.lw < 350 then
            return
          end
          
          -- USE Q :
          local stopQIfW = gsoMeMenu.wset.stopq:Value() and champInfo.hasWBuff
          local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                canQ = canQ and not stopQIfW and meMana > gsoMyHero:GetSpellData(_Q).mana and (not isTarget or gsoSpellState.q)
          if canQ and gsoIsReady(_Q, { q = 1000, w = 150, e = 350, r = 350 }) then
            local qTarget
            if isTarget then
              qTarget = target
            else
              qTarget = gsoGetTarget(1175, gsoMyHero.pos, enemyList, "ap", false, false)
            end
            if qTarget and gsoCastSpellSkillShot(HK_Q, mePos, qTarget, {hero = true}) then
              gsoSpellState.lq = GetTickCount()
              gsoSpellState.e = false
              gsoSpellState.r = false
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
          
          -- USE E :
          local stopEIfW = gsoMeMenu.wset.stope:Value() and champInfo.hasWBuff
          local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
                canE = canE and not stopEIfW and meMana > gsoMyHero:GetSpellData(_E).mana and (not isTarget or gsoSpellState.e)
                canE = canE and ( myHero.mana * 100 ) / myHero.maxMana > gsoMeMenu.eset.emana:Value() and gsoIsReady(_E, { q = 350, w = 150, e = 1000, r = 350 }) 
          if canE then
            local eTarget
            if isTarget then
              eTarget = target
            else
              eTarget = gsoGetTarget(1280, gsoMyHero.pos, enemyList, "ap", false, false)
            end
            if eTarget and gsoCastSpellSkillShot(HK_E, mePos, eTarget, {hero = true}) then
              gsoSpellState.le = GetTickCount()
              gsoSpellState.q = false
              gsoSpellState.r = false
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
          
          -- USE R :
          local rStacks = gsoBuffCount(myHero, "kogmawlivingartillerycost") < gsoMeMenu.rset.stack:Value()
          local stopRIfW = gsoMeMenu.wset.stopr:Value() and champInfo.hasWBuff
          local canR = ( isCombo and gsoMeMenu.rset.combo:Value() ) or ( isHarass and gsoMeMenu.rset.harass:Value() )
                canR = canR and rStacks and not stopRIfW and gsoIsReady(_R, { q = 350, w = 150, e = 350, r = 750 }) and (not isTarget or gsoSpellState.r)
                canR = canR and meMana > gsoMyHero:GetSpellData(_R).mana and ( gsoMyHero.mana * 100 ) / gsoMyHero.maxMana > gsoMeMenu.rset.rmana:Value()
          if canR then
            
            local rrange = 900 + ( 300 * gsoMyHero:GetSpellData(_R).level )
            
            -- only enemies with hp lower than 40%
            local onlyLowR = gsoMeMenu.rset.onlylow:Value()
            
            -- check for target in attack range
            local rTarget
            if not onlyLowR and isTarget then rTarget = target end
            if onlyLowR and isTarget and ( target.health * 100 ) / target.maxHealth < 39 then rTarget = target end
            
            -- check for targets in R range
            local rTargets = {}
            if not rTarget then
              if onlyLowR then
                for i = 1, #enemyList do
                  local hero = enemyList[i]
                  if hero and ( hero.health * 100 ) / hero.maxHealth < 39 then
                    rTargets[#rTargets+1] = hero
                  end
                end
              else
                rTargets = enemyList
              end
            end
            
            -- target
            local rT
            if rTarget then
              rT = rTarget
            else
              rT = gsoGetTarget(gsoSpellData.r.range + 110, gsoMyHero.pos, rTargets, "ap", false, false)
            end
            if rT and gsoCastSpellSkillShot(HK_R, mePos, rT, {hero = true}) then
              gsoSpellState.lr = GetTickCount()
              gsoSpellState.q = false
              gsoSpellState.e = false
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
        end
      end)


    -- KOG TICK
      gsoOrbwalker:OnTick(function()
        local hasWBuff = false
        for i = 0, gsoMyHero.buffCount do
          local buff = gsoMyHero:GetBuff(i)
          if buff and buff.count > 0 and buff.duration > 0 and buff.name == "KogMawBioArcaneBarrage" then
            hasWBuff = true
            break
          end
        end
        champInfo.hasWBuff = hasWBuff
        local mePos = myHero.pos
        
        local canR = gsoIsReady(_R, { q = 350, w = 150, e = 350, r = 750 })
        if canR and gsoState.canMove and gsoGameTimer() > gsoTimers.lastAttackSend + gsoTimers.windUpTime + 0.07 then
          
          local enemyList = {}
          for i = 1, #gsoObjects.enemyHeroes do
            local hero = gsoObjects.enemyHeroes[i]
            if hero and hero.visible and not gsoImmortal(hero, false) then
              enemyList[#enemyList+1] = hero
            end
          end
          -- spell data
          local extraRRange = 300 * myHero:GetSpellData(_R).level 
          gsoSpellData.r.range = 900 + extraRRange
          
          local rStacks = gsoBuffCount(myHero, "kogmawlivingartillerycost") < gsoMeMenu.rset.stack:Value()
          local checkRStacksKS = gsoMeMenu.rset.ksmenu.csksr:Value()
          if gsoMeMenu.rset.ksmenu.ksr:Value() and ( not checkRStacksKS or rStacks ) then
            
            -- check for killable targets in R range

            local rTargets = {}
            for i = 1, #enemyList do
              local hero = enemyList[i]
              local baseRDmg = 60 + ( 40 * gsoMyHero:GetSpellData(_R).level ) + ( gsoMyHero.bonusDamage * 0.65 ) + ( gsoMyHero.ap * 0.25 )
              local rMultipier = math.floor(100 - ( ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth ))
              local rDmg = rMultipier > 60 and baseRDmg * 2 or baseRDmg * ( 1 + ( rMultipier * 0.00833 ) )
                    rDmg = gsoCalcDmg(hero, { dmgAP = rDmg, dmgType = "ap" } )
              local unitKillable = rDmg > hero.health + (hero.hpRegen * 2)
              if unitKillable then
                rTargets[#rTargets+1] = hero
              end
            end
            
            -- target
            local rT
            if #rTargets > 0 then
              rT = gsoGetTarget(gsoSpellData.r.range + 110, gsoMyHero.pos, rTargets, "ap", false, false)
            end
            
            -- use spell
            if rT and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rT, {}) then
              gsoSpellState.lr = GetTickCount()
              gsoSpellState.q = false
              gsoSpellState.e = false
              gsoState.enabledAttack = false
              return
            end
          end
          
          local checkRStacksSemi = gsoMeMenu.rset.semirkog.semistacks:Value()
          if gsoMeMenu.rset.semirkog.semir:Value() and ( not checkRStacksSemi or rStacks ) then
            
            -- only enemies with hp lower than 40%
            local onlyLowR = gsoMeMenu.rset.semirkog.semilow:Value()

            -- check for targets in R range
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
            
            -- target
            local rT
            if #rTargets > 0 then
              rT = gsoGetTarget(gsoSpellData.r.range + 110, gsoMyHero.pos, rTargets, "ap", false, false)
            end
            
            -- use spell
            if rT and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rT, {}) then
              gsoSpellState.lr = GetTickCount()
              gsoSpellState.q = false
              gsoSpellState.e = false
              gsoState.enabledAttack = false
              return
            end
          end
        end
      end)
    
      gsoOrbwalker:OnIssue(function(issue)
        if issue.attack then
          gsoSpellState.q = true; gsoSpellState.w = true; gsoSpellState.e = true; gsoSpellState.r = true
        end
      end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Leblanc = function() end,
    __LeeSin = function() end,
    __Leona = function() end,
    __Lissandra = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Lucian = function()
      local champInfo = { hasRBuff = false }
      local gsoMeMenu = gsoMenu:MenuElement({name = "Lucian", id = "gsolucian", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/lucian.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
      gsoDrawData = { q = true, qr = 500+120, w = true, wr = 900+350, e = true, er = 425, r = true, rr = 1200 }
      gsoSpellData.w = { delay = 0.25, range = 1250, width = 75, speed = 1600, sType = "line", col = false, mCol = false, hCol = false, out = true }
      gsoOrbwalker:OnMove(function(args)
        local target = args.Target
        local isTarget = target ~= nil
        local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        local mePos = gsoMyHero.pos
        local enemyList = {}
        for i = 1, #gsoObjects.enemyHeroes do
          local hero = gsoObjects.enemyHeroes[i]
          if hero and hero.visible and not gsoImmortal(hero, false) then
            enemyList[#enemyList+1] = hero
          end
        end
        
        if not gsoCheckTimers({ q = 350, w = 250, e = 450, r = 0 }) then
          args.Process = false
          return
        end
        if not gsoState.enabledAttack and gsoCheckTimers({ q = 350, w = 200, e = 300, r = 0 }) then
          gsoState.enabledAttack = true
          return
        end
        
        if not isTarget or afterAttack then
          local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
                canE = canE and (not isTarget or (isTarget and gsoSpellState.e)) and gsoIsReadyFast(_E, { q = 500, w = 250, e = 1000, r = 500 }) and not champInfo.hasRBuff
          if canE then
            local meRange = gsoMyHero.range + gsoMyHero.boundingRadius
            for i = 1, #enemyList do
              local hero = enemyList[i]
              local heroPos = hero.pos
              local distToMouse = gsoDistance(mePos, mousePos)
              local distToHero = gsoDistance(mePos, heroPos)
              local distToEndPos = gsoDistance(mePos, hero.pathing.endPos)
              local extRange
              if distToEndPos > distToHero then
                extRange = distToMouse > 325 and 325 or distToMouse
              else
                extRange = distToMouse > 425 and 425 or distToMouse
              end
              local extPos = mePos + (mousePos-mePos):Normalized() * extRange
              local distEnemyToExt = gsoDistance(extPos, heroPos)
              if distEnemyToExt < meRange + hero.boundingRadius and gsoCastSpell(HK_E) then
                gsoSpellState.le = GetTickCount()
                gsoSpellState.q = false
                gsoSpellState.w = false
                gsoSpellState.r = false
                gsoExtra.resetAttack = true
                gsoState.enabledAttack = false
                args.Process = false
                return
              end
            end
          end
          local canQ = (isCombo and gsoMeMenu.qset.combo:Value()) or (isHarass and gsoMeMenu.qset.harass:Value())
                canQ = canQ and isTarget and gsoSpellState.q and gsoIsReady(_Q, { q = 1000, w = 400, e = 400, r = 500 }) and not champInfo.hasRBuff
          if canQ and gsoCastSpellTarget(HK_Q, 500 + gsoMyHero.boundingRadius + target.boundingRadius, mePos, target, {hero=true}, {minions=true, heroes=true}) then
            gsoSpellState.lq = GetTickCount()
            gsoSpellState.w = false
            gsoSpellState.r = false
            gsoState.enabledAttack = false
            args.Process = false
            return
          end
          local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                canW = canW and (not isTarget or gsoSpellState.w) and gsoIsReady(_W, { q = 500, w = 350, e = 350, r = 500 }) and not champInfo.hasRBuff
          if canW then
            local wTarget
            if isTarget then
              wTarget = target
            else
              wTarget = gsoGetTarget(1350, gsoMyHero.pos, enemyList, "ad", false, false)
            end
            if wTarget and gsoCastSpellSkillShot(HK_W, mePos, wTarget, {hero = true}) then
              gsoSpellState.lw = GetTickCount()
              gsoSpellState.q = false
              gsoSpellState.r = false
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
        end
      end)
      gsoOrbwalker:OnTick(function()
        if gsoHasBuff(gsoMyHero, "lucianr") then
          champInfo.hasRBuff = true
          gsoState.enabledAttack = false
        else
          champInfo.hasRBuff = false
          gsoState.enabledAttack = true
        end
      end)
      gsoOrbwalker:OnIssue(function(issue)
        if issue.attack then
          gsoSpellState.q = true; gsoSpellState.w = true; gsoSpellState.e = true; gsoSpellState.r = true
        end
      end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Lulu = function() end,
    __Lux = function() end,
    __Malphite = function() end,
    __Malzahar = function() end,
    __Maokai = function() end,
    __MasterYi = function() end,
    __MissFortune = function() end,
    __MonkeyKing = function() end,
    __Mordekaiser = function() end,
    __Morgana = function() end,
    __Nami = function() end,
    __Nasus = function() end,
    __Nautilus = function() end,
    __Nidalee = function() end,
    __Nocturne = function() end,
    __Nunu = function() end,
    __Olaf = function() end,
    __Orianna = function() end,
    __Ornn = function() end,
    __Pantheon = function() end,
    __Poppy = function() end,
    __Quinn = function() end,
    __Rakan = function() end,
    __Rammus = function() end,
    __RekSai = function() end,
    __Renekton = function() end,
    __Rengar = function() end,
    __Riven = function() end,
    __Rumble = function() end,
    __Ryze = function() end,
    __Sejuani = function() end,
    __Shaco = function() end,
    __Shen = function() end,
    __Shyvana = function() end,
    __Singed = function() end,
    __Sion = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Sivir = function()
      local champInfo = { lastReset = 0, asNoW = myHero.attackSpeed }
        local gsoMeMenu = gsoMenu:MenuElement({name = "Sivir", id = "gsosivir", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/sivir.png" })
          gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
          gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
      gsoDrawData = { q = true, qr = 1250, r = true, rr = 1000 }
      gsoSpellData.q = { delay = 0.25, range = 1250, width = 60, speed = 1350, sType = "line", col = false, mCol = false, hCol = false, out = true }
      gsoOrbwalker:AttackSpeed(function()
        local wDiff = gsoGetTickCount() - gsoSpellState.lwk - gsoExtra.minLatency
        if wDiff > 3500 and wDiff < 4500 then
          return champInfo.asNoW
        end
        return gsoMyHero.attackSpeed
      end)
      gsoOrbwalker:OnMove(function(args)
        local target = args.Target
        local isTarget = target ~= nil
        local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        local mePos = gsoMyHero.pos
        local enemyList = {}
        for i = 1, #gsoObjects.enemyHeroes do
          local hero = gsoObjects.enemyHeroes[i]
          if hero and hero.visible and not gsoImmortal(hero, false) then
            enemyList[#enemyList+1] = hero
          end
        end
        
        if not gsoCheckTimers({ q = 250, w = 0, e = 0, r = 0 }) then
          args.Process = false
          return
        end
        if not gsoState.enabledAttack and gsoCheckTimers({ q = 350, w = 0, e = 0, r = 0 }) then
          gsoState.enabledAttack = true
          return
        end
        
        local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
              canW = canW and isTarget and gsoGameTimer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.5 )
              canW = canW and gsoIsReadyFast(_W, { q = 250, w = 1000, e = 0, r = 0 })
        if canW and gsoCastSpell(HK_W) then
          gsoSpellState.lw = GetTickCount()
          gsoSpellState.q = false
          gsoOrbwalker:AddAction({ func = function() gsoExtra.resetAttack = true end, endTime = gsoGameTimer() + 0.05 })
          args.Process = false
          return
        end
        
        if not isTarget or afterAttack then
          
          -- USE Q :
          local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                canQ = canQ and gsoIsReady(_Q, { q = 1000, w = 0, e = 0, r = 0 }) and (not isTarget or gsoSpellState.q)
          if canQ then
            local qTarget
            if isTarget then
              qTarget = target
            else
              qTarget = gsoGetTarget(1250, gsoMyHero.pos, enemyList, "ad", false, false)
            end
            if qTarget and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qTarget, {hero = true}) then
              gsoSpellState.lq = GetTickCount()
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
        end
      end)
      gsoOrbwalker:OnIssue(function(issue)
        if issue.attack then
          gsoSpellState.q = true; gsoSpellState.w = true; gsoSpellState.e = true; gsoSpellState.r = true
        end
      end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Skarner = function() end,
    __Sona = function() end,
    __Soraka = function() end,
    __Swain = function() end,
    __Syndra = function() end,
    __TahmKench = function() end,
    __Taliyah = function() end,
    __Talon = function() end,
    __Taric = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Teemo = function()
      local gsoMeMenu = gsoMenu:MenuElement({name = "Teemo", id = "gsoteemo", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/teemo.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoMeMenu.wset:MenuElement({id = "mindist", name = "Min. distance to enemy", value = 850, min = 680, max = 1250, step = 10 })
            gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
            gsoMeMenu.rset:MenuElement({id = "immo", name = "only if enemy isImmobile", value = true})
            gsoMeMenu.rset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.rset:MenuElement({id = "harass", name = "Harass", value = false})
      local function _teemoR()
        local rLvl = gsoMyHero:GetSpellData(_R).level
        if rLvl == 0 then rLvl = 1 end
        return 150 + ( 250 * rLvl )
      end
      gsoDrawData = { q = true, qr = 680, r = true, rf = function() return _teemoR() end }
      gsoSpellData.r = { delay = 0.25, range = 0, width = 200, speed = 1000, sType = "circular", col = false, mCol = false, hCol = false, out = false }
      gsoOrbwalker:OnMove(function(args)
        local target = args.Target
        local isTarget = target ~= nil
        local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        local mePos = gsoMyHero.pos
        local enemyList = {}
        for i = 1, #gsoObjects.enemyHeroes do
          local hero = gsoObjects.enemyHeroes[i]
          if hero and hero.visible and not gsoImmortal(hero, false) then
            enemyList[#enemyList+1] = hero
          end
        end
        
        if not gsoCheckTimers({ q = 250, w = 0, e = 0, r = 250 }) then
          args.Process = false
          return
        end
        if not gsoState.enabledAttack and gsoCheckTimers({ q = 350, w = 0, e = 0, r = 350 }) then
          gsoState.enabledAttack = true
          return
        end
        
        if not isTarget or afterAttack then
          
          -- USE Q :
          local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                canQ = canQ and gsoIsReady(_Q, { q = 1000, w = 0, e = 0, r = 750 }) and (not isTarget or gsoSpellState.q)
          if canQ then
            local qTarget
            if isTarget then
              qTarget = target
            else
              qTarget = gsoGetTarget(680, gsoMyHero.pos, enemyList, "ap", false, false)
            end
            if qTarget and gsoCastSpellTarget(HK_Q, 680, mePos, qTarget, {hero=true}, {minions=true, heroes=true}) then
              gsoSpellState.r = false
              gsoSpellState.lq = gsoGetTickCount()
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
          
          -- USE R :
          local canR = ( isCombo and gsoMeMenu.rset.combo:Value() ) or ( isHarass and gsoMeMenu.rset.harass:Value() )
                canR = canR and gsoIsReady(_R, { q = 350, w = 0, e = 0, r = 1000 }) and (not isTarget or gsoSpellState.r)
          if canR then
            local rRange = 150 + ( 250 * gsoMyHero:GetSpellData(_R).level )
            gsoSpellData.r.range = rRange
            local onlyImmobile = gsoMeMenu.rset.immo:Value()
            local rTarget = onlyImmobile and gsoGetImmobileEnemy(mePos, enemyList, rRange) or nil
            if not rTarget and not onlyImmobile then
              local isTeemoTarget = isTarget and gsoDistance(mePos, target.pos) < rRange
              if isTeemoTarget then
                rTarget = target
              else
                rTarget = gsoGetTarget(rRange, gsoMyHero.pos, enemyList, "ap", false, false)
              end
            end
            if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget, {hero = true}) then
              gsoSpellState.q = false
              gsoSpellState.lr = gsoGetTickCount()
              gsoState.enabledAttack = false
              args.Process = false
              return
            end
          end
          
          -- USE W :
          local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                canW = canW and gsoIsReadyFast(_W, { q = 350, w = 1000, e = 0, r = 350 })
          if canW then
            for i = 1, #enemyList do
              local hero = enemyList[i]
              if gsoDistance(mePos, hero.pos) < gsoMeMenu.wset.mindist:Value() and gsoCastSpell(HK_W) then
                gsoSpellState.lw = GetTickCount()
                return
              end
            end
          end
        end
      end)
      gsoOrbwalker:OnIssue(function(issue)
        if issue.attack then
          gsoSpellState.q = true; gsoSpellState.w = true; gsoSpellState.e = true; gsoSpellState.r = true
        end
      end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Thresh = function() end,
    __Tristana = function() end,
    __Trundle = function() end,
    __Tryndamere = function() end,
    __TwistedFate = function() end,
    __Twitch = function() end,
    __Udyr = function() end,
    __Urgot = function() end,
    __Varus = function() end,
    __Vayne = function() end,
    __Veigar = function() end,
    __Velkoz = function() end,
    __Vi = function() end,
    __Viktor = function() end,
    __Vladimir = function() end,
    __Volibear = function() end,
    __Warwick = function() end,
    __Xayah = function() end,
    __Xerath = function() end,
    __XinZhao = function() end,
    __Yasuo = function() end,
    __Yorick = function() end,
    __Zac = function() end,
    __Zed = function() end,
    __Ziggs = function() end,
    __Zilean = function() end,
    __Zoe = function() end,
    __Zyra = function() end
  }
  gsoMenu:MenuElement({name = "Drawings", id = "gsodraw", leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/circles.png", type = MENU })
    gsoMenu.gsodraw:MenuElement({name = "Enabled",  id = "enabled", value = true})
  gsoMenu:MenuElement({name = "Items", id = "gsoitem", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/item.png" })
    gsoMenu.gsoitem:MenuElement({id = "botrk", name = "        botrk", value = true, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/botrk.png" })
  gsoOrbwalker:OnMove(function(args)
    local botrkMinus = gsoGetTickCount() - gsoItems.lastBotrk
    if botrkMinus < 100 then
      args.Process = false
      return
    end
    local botrkTarget = args.Target
    local canBotrk = botrkTarget and gsoDistance(botrkTarget.pos, gsoMyHero.pos) < 520
    if canBotrk and gsoMenu.gsoitem.botrk:Value() and botrkMinus > 1000 and gsoGameTimer() > gsoTimers.lastMoveSend + 0.075 and gsoGameTimer() > gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.5 ) and gsoMode.isCombo() then
      local botrkHK = gsoItems._botrk()
      if botrkHK and gsoCastSpellTarget(botrkHK, 520, gsoMyHero.pos, botrkTarget, {hero=true}, {heroes=true}) then
        gsoItems.lastBotrk = gsoGetTickCount()
        args.Process = false
        return
      end
    end
  end)
  if myHero.charName == "Aatrox" then gsoLoadMyHero.__Aatrox() elseif myHero.charName == "Ahri" then gsoLoadMyHero.__Ahri() elseif myHero.charName == "Akali" then gsoLoadMyHero.__Akali() elseif myHero.charName == "Alistar" then gsoLoadMyHero.__Alistar() elseif myHero.charName == "Amumu" then gsoLoadMyHero.__Amumu() elseif myHero.charName == "Anivia" then gsoLoadMyHero.__Anivia() elseif myHero.charName == "Annie" then gsoLoadMyHero.__Annie() elseif myHero.charName == "Ashe" then gsoLoadMyHero.__Ashe() elseif myHero.charName == "AurelionSol" then gsoLoadMyHero.__AurelionSol() elseif myHero.charName == "Azir" then gsoLoadMyHero.__Azir() elseif myHero.charName == "Bard" then gsoLoadMyHero.__Bard() elseif myHero.charName == "Blitzcrank" then gsoLoadMyHero.__Blitzcrank() elseif myHero.charName == "Brand" then gsoLoadMyHero.__Brand() elseif myHero.charName == "Braum" then gsoLoadMyHero.__Braum() elseif myHero.charName == "Caitlyn" then gsoLoadMyHero.__Caitlyn() elseif myHero.charName == "Camille" then gsoLoadMyHero.__Camille() elseif myHero.charName == "Cassiopeia" then gsoLoadMyHero.__Cassiopeia() elseif myHero.charName == "Chogath" then gsoLoadMyHero.__Chogath() elseif myHero.charName == "Corki" then gsoLoadMyHero.__Corki() elseif myHero.charName == "Darius" then gsoLoadMyHero.__Darius() elseif myHero.charName == "Diana" then gsoLoadMyHero.__Diana() elseif myHero.charName == "DrMundo" then gsoLoadMyHero.__DrMundo() elseif myHero.charName == "Draven" then gsoLoadMyHero.__Draven() elseif myHero.charName == "Ekko" then gsoLoadMyHero.__Ekko() elseif myHero.charName == "Elise" then gsoLoadMyHero.__Elise() elseif myHero.charName == "Evelynn" then gsoLoadMyHero.__Evelynn() elseif myHero.charName == "Ezreal" then gsoLoadMyHero.__Ezreal() elseif myHero.charName == "Fiddlesticks" then gsoLoadMyHero.__Fiddlesticks() elseif myHero.charName == "Fiora" then gsoLoadMyHero.__Fiora() elseif myHero.charName == "Fizz" then gsoLoadMyHero.__Fizz() elseif myHero.charName == "Galio" then gsoLoadMyHero.__Galio() elseif myHero.charName == "Gangplank" then gsoLoadMyHero.__Gangplank() elseif myHero.charName == "Garen" then gsoLoadMyHero.__Garen() elseif myHero.charName == "Gnar" then gsoLoadMyHero.__Gnar() elseif myHero.charName == "Gragas" then gsoLoadMyHero.__Gragas() elseif myHero.charName == "Graves" then gsoLoadMyHero.__Graves() elseif myHero.charName == "Hecarim" then gsoLoadMyHero.__Hecarim() elseif myHero.charName == "Heimerdinger" then gsoLoadMyHero.__Heimerdinger() elseif myHero.charName == "Illaoi" then gsoLoadMyHero.__Illaoi() elseif myHero.charName == "Irelia" then gsoLoadMyHero.__Irelia() elseif myHero.charName == "Ivern" then gsoLoadMyHero.__Ivern() elseif myHero.charName == "Janna" then gsoLoadMyHero.__Janna() elseif myHero.charName == "JarvanIV" then gsoLoadMyHero.__JarvanIV() elseif myHero.charName == "Jax" then gsoLoadMyHero.__Jax() elseif myHero.charName == "Jayce" then gsoLoadMyHero.__Jayce() elseif myHero.charName == "Jhin" then gsoLoadMyHero.__Jhin() elseif myHero.charName == "Jinx" then gsoLoadMyHero.__Jinx() elseif myHero.charName == "Kalista" then gsoLoadMyHero.__Kalista() elseif myHero.charName == "Karma" then gsoLoadMyHero.__Karma() elseif myHero.charName == "Karthus" then gsoLoadMyHero.__Karthus() elseif myHero.charName == "Kassadin" then gsoLoadMyHero.__Kassadin() elseif myHero.charName == "Katarina" then gsoLoadMyHero.__Katarina() elseif myHero.charName == "Kayle" then gsoLoadMyHero.__Kayle() elseif myHero.charName == "Kayn" then gsoLoadMyHero.__Kayn() elseif myHero.charName == "Kennen" then gsoLoadMyHero.__Kennen() elseif myHero.charName == "Khazix" then gsoLoadMyHero.__Khazix() elseif myHero.charName == "Kindred" then gsoLoadMyHero.__Kindred() elseif myHero.charName == "Kled" then gsoLoadMyHero.__Kled() elseif myHero.charName == "KogMaw" then gsoLoadMyHero.__KogMaw() elseif myHero.charName == "Leblanc" then gsoLoadMyHero.__Leblanc() elseif myHero.charName == "LeeSin" then gsoLoadMyHero.__LeeSin() elseif myHero.charName == "Leona" then gsoLoadMyHero.__Leona() elseif myHero.charName == "Lissandra" then gsoLoadMyHero.__Lissandra() elseif myHero.charName == "Lucian" then gsoLoadMyHero.__Lucian() elseif myHero.charName == "Lulu" then gsoLoadMyHero.__Lulu() elseif myHero.charName == "Lux" then gsoLoadMyHero.__Lux() elseif myHero.charName == "Malphite" then gsoLoadMyHero.__Malphite() elseif myHero.charName == "Malzahar" then gsoLoadMyHero.__Malzahar() elseif myHero.charName == "Maokai" then gsoLoadMyHero.__Maokai() elseif myHero.charName == "MasterYi" then gsoLoadMyHero.__MasterYi() elseif myHero.charName == "MissFortune" then gsoLoadMyHero.__MissFortune() elseif myHero.charName == "MonkeyKing" then gsoLoadMyHero.__MonkeyKing() elseif myHero.charName == "Mordekaiser" then gsoLoadMyHero.__Mordekaiser() elseif myHero.charName == "Morgana" then gsoLoadMyHero.__Morgana() elseif myHero.charName == "Nami" then gsoLoadMyHero.__Nami() elseif myHero.charName == "Nasus" then gsoLoadMyHero.__Nasus() elseif myHero.charName == "Nautilus" then gsoLoadMyHero.__Nautilus() elseif myHero.charName == "Nidalee" then gsoLoadMyHero.__Nidalee() elseif myHero.charName == "Nocturne" then gsoLoadMyHero.__Nocturne() elseif myHero.charName == "Nunu" then gsoLoadMyHero.__Nunu() elseif myHero.charName == "Olaf" then gsoLoadMyHero.__Olaf() elseif myHero.charName == "Orianna" then gsoLoadMyHero.__Orianna() elseif myHero.charName == "Ornn" then gsoLoadMyHero.__Ornn() elseif myHero.charName == "Pantheon" then gsoLoadMyHero.__Pantheon() elseif myHero.charName == "Poppy" then gsoLoadMyHero.__Poppy() elseif myHero.charName == "Quinn" then gsoLoadMyHero.__Quinn() elseif myHero.charName == "Rakan" then gsoLoadMyHero.__Rakan() elseif myHero.charName == "Rammus" then gsoLoadMyHero.__Rammus() elseif myHero.charName == "RekSai" then gsoLoadMyHero.__RekSai() elseif myHero.charName == "Renekton" then gsoLoadMyHero.__Renekton() elseif myHero.charName == "Rengar" then gsoLoadMyHero.__Rengar() elseif myHero.charName == "Riven" then gsoLoadMyHero.__Riven() elseif myHero.charName == "Rumble" then gsoLoadMyHero.__Rumble() elseif myHero.charName == "Ryze" then gsoLoadMyHero.__Ryze() elseif myHero.charName == "Sejuani" then gsoLoadMyHero.__Sejuani() elseif myHero.charName == "Shaco" then gsoLoadMyHero.__Shaco() elseif myHero.charName == "Shen" then gsoLoadMyHero.__Shen() elseif myHero.charName == "Shyvana" then gsoLoadMyHero.__Shyvana() elseif myHero.charName == "Singed" then gsoLoadMyHero.__Singed() elseif myHero.charName == "Sion" then gsoLoadMyHero.__Sion() elseif myHero.charName == "Sivir" then gsoLoadMyHero.__Sivir() elseif myHero.charName == "Skarner" then gsoLoadMyHero.__Skarner() elseif myHero.charName == "Sona" then gsoLoadMyHero.__Sona() elseif myHero.charName == "Soraka" then gsoLoadMyHero.__Soraka() elseif myHero.charName == "Swain" then gsoLoadMyHero.__Swain() elseif myHero.charName == "Syndra" then gsoLoadMyHero.__Syndra() elseif myHero.charName == "TahmKench" then gsoLoadMyHero.__TahmKench() elseif myHero.charName == "Taliyah" then gsoLoadMyHero.__Taliyah() elseif myHero.charName == "Talon" then gsoLoadMyHero.__Talon() elseif myHero.charName == "Taric" then gsoLoadMyHero.__Taric() elseif myHero.charName == "Teemo" then gsoLoadMyHero.__Teemo() elseif myHero.charName == "Thresh" then gsoLoadMyHero.__Thresh() elseif myHero.charName == "Tristana" then gsoLoadMyHero.__Tristana() elseif myHero.charName == "Trundle" then gsoLoadMyHero.__Trundle() elseif myHero.charName == "Tryndamere" then gsoLoadMyHero.__Tryndamere() elseif myHero.charName == "TwistedFate" then gsoLoadMyHero.__TwistedFate() elseif myHero.charName == "Twitch" then gsoLoadMyHero.__Twitch() elseif myHero.charName == "Udyr" then gsoLoadMyHero.__Udyr() elseif myHero.charName == "Urgot" then gsoLoadMyHero.__Urgot() elseif myHero.charName == "Varus" then gsoLoadMyHero.__Varus() elseif myHero.charName == "Vayne" then gsoLoadMyHero.__Vayne() elseif myHero.charName == "Veigar" then gsoLoadMyHero.__Veigar() elseif myHero.charName == "Velkoz" then gsoLoadMyHero.__Velkoz() elseif myHero.charName == "Vi" then gsoLoadMyHero.__Vi() elseif myHero.charName == "Viktor" then gsoLoadMyHero.__Viktor() elseif myHero.charName == "Vladimir" then gsoLoadMyHero.__Vladimir() elseif myHero.charName == "Volibear" then gsoLoadMyHero.__Volibear() elseif myHero.charName == "Warwick" then gsoLoadMyHero.__Warwick() elseif myHero.charName == "Xayah" then gsoLoadMyHero.__Xayah() elseif myHero.charName == "Xerath" then gsoLoadMyHero.__Xerath() elseif myHero.charName == "XinZhao" then gsoLoadMyHero.__XinZhao() elseif myHero.charName == "Yasuo" then gsoLoadMyHero.__Yasuo() elseif myHero.charName == "Yorick" then gsoLoadMyHero.__Yorick() elseif myHero.charName == "Zac" then gsoLoadMyHero.__Zac() elseif myHero.charName == "Zed" then gsoLoadMyHero.__Zed() elseif myHero.charName == "Ziggs" then gsoLoadMyHero.__Ziggs() elseif myHero.charName == "Zilean" then gsoLoadMyHero.__Zilean() elseif myHero.charName == "Zoe" then gsoLoadMyHero.__Zoe() elseif myHero.charName == "Zyra" then gsoLoadMyHero.__Zyra() end
  gsoMenu.gsodraw:MenuElement({name = "Circles", id = "circle1", type = MENU,
    onclick = function()
      if myHero.charName == "Twitch" then
        gsoMenu.gsodraw.circle1.invenable:Hide(true)
        gsoMenu.gsodraw.circle1.invcolor:Hide(true)
        gsoMenu.gsodraw.circle1.notenable:Hide(true)
        gsoMenu.gsodraw.circle1.notcolor:Hide(true) end
      if myHero.charName == "Draven" then
        gsoMenu.gsodraw.circle1.aaxeenable:Hide(true)
        gsoMenu.gsodraw.circle1.aaxecolor:Hide(true)
        gsoMenu.gsodraw.circle1.aaxewidth:Hide(true)
        gsoMenu.gsodraw.circle1.aaxeradius:Hide(true)
        gsoMenu.gsodraw.circle1.iaxeenable:Hide(true)
        gsoMenu.gsodraw.circle1.iaxecolor:Hide(true)
        gsoMenu.gsodraw.circle1.iaxewidth:Hide(true)
        gsoMenu.gsodraw.circle1.iaxeradius:Hide(true) end
      if gsoDrawData.q then
        gsoMenu.gsodraw.circle1.qrange:Hide(true)
        gsoMenu.gsodraw.circle1.qrangecolor:Hide(true)
        gsoMenu.gsodraw.circle1.qrangewidth:Hide(true) end
      if gsoDrawData.w then
        gsoMenu.gsodraw.circle1.wrange:Hide(true)
        gsoMenu.gsodraw.circle1.wrangecolor:Hide(true)
        gsoMenu.gsodraw.circle1.wrangewidth:Hide(true) end
      if gsoDrawData.e then
        gsoMenu.gsodraw.circle1.erange:Hide(true)
        gsoMenu.gsodraw.circle1.erangecolor:Hide(true)
        gsoMenu.gsodraw.circle1.erangewidth:Hide(true) end
      if gsoDrawData.r then
        gsoMenu.gsodraw.circle1.rrange:Hide(true)
        gsoMenu.gsodraw.circle1.rrangecolor:Hide(true)
        gsoMenu.gsodraw.circle1.rrangewidth:Hide(true) end end })
  if myHero.charName == "Twitch" then
    gsoMenu.gsodraw.circle1:MenuElement({name = "Q Invisible Range", id = "note9", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
        gsoMenu.gsodraw.circle1.invenable:Hide()
        gsoMenu.gsodraw.circle1.invcolor:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({id = "invenable", name = "        Enabled", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({id = "invcolor", name = "        Color ", color = Draw.Color(200, 255, 0, 0)})
    gsoMenu.gsodraw.circle1:MenuElement({name = "Q Notification Range", id = "note10", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
        gsoMenu.gsodraw.circle1.notenable:Hide()
        gsoMenu.gsodraw.circle1.notcolor:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({id = "notenable", name = "        Enabled", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({id = "notcolor", name = "        Color", color = Draw.Color(200, 188, 77, 26)}) end
  if gsoDrawData.q then
    gsoMenu.gsodraw.circle1:MenuElement({name = "Q Range", id = "note5", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
        gsoMenu.gsodraw.circle1.qrange:Hide()
        gsoMenu.gsodraw.circle1.qrangecolor:Hide()
        gsoMenu.gsodraw.circle1.qrangewidth:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({id = "qrange", name = "        Enabled", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({id = "qrangecolor", name = "        Color", color = Draw.Color(255, 66, 134, 244)})
      gsoMenu.gsodraw.circle1:MenuElement({id = "qrangewidth", name = "        Width", value = 1, min = 1, max = 10}) end
  if gsoDrawData.w then
    gsoMenu.gsodraw.circle1:MenuElement({name = "W Range", id = "note6", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
        gsoMenu.gsodraw.circle1.wrange:Hide()
        gsoMenu.gsodraw.circle1.wrangecolor:Hide()
        gsoMenu.gsodraw.circle1.wrangewidth:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({id = "wrange", name = "        Enabled", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({id = "wrangecolor", name = "        Color", color = Draw.Color(255, 92, 66, 244)})
      gsoMenu.gsodraw.circle1:MenuElement({id = "wrangewidth", name = "        Width", value = 1, min = 1, max = 10}) end
  if gsoDrawData.e then
    gsoMenu.gsodraw.circle1:MenuElement({name = "E Range", id = "note7", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
          gsoMenu.gsodraw.circle1.erange:Hide()
          gsoMenu.gsodraw.circle1.erangecolor:Hide()
          gsoMenu.gsodraw.circle1.erangewidth:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({id = "erange", name = "        Enabled", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({id = "erangecolor", name = "        Color", color = Draw.Color(255, 66, 244, 149)})
      gsoMenu.gsodraw.circle1:MenuElement({id = "erangewidth", name = "        Width", value = 1, min = 1, max = 10}) end
  if gsoDrawData.r then
    gsoMenu.gsodraw.circle1:MenuElement({name = "R Range", id = "note8", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
        gsoMenu.gsodraw.circle1.rrange:Hide()
        gsoMenu.gsodraw.circle1.rrangecolor:Hide()
        gsoMenu.gsodraw.circle1.rrangewidth:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({id = "rrange", name = "        Enabled", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({id = "rrangecolor", name = "        Color", color = Draw.Color(255, 244, 182, 66)})
      gsoMenu.gsodraw.circle1:MenuElement({id = "rrangewidth", name = "        Width", value = 1, min = 1, max = 10}) end
  if myHero.charName == "Draven" then
    gsoMenu.gsodraw.circle1:MenuElement({name = "Active Axe", id = "note9", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
        gsoMenu.gsodraw.circle1.aaxeenable:Hide()
        gsoMenu.gsodraw.circle1.aaxecolor:Hide()
        gsoMenu.gsodraw.circle1.aaxewidth:Hide()
        gsoMenu.gsodraw.circle1.aaxeradius:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({name = "        Enabled",  id = "aaxeenable", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({name = "        Color",  id = "aaxecolor", color = Draw.Color(255, 49, 210, 0)})
      gsoMenu.gsodraw.circle1:MenuElement({name = "        Width",  id = "aaxewidth", value = 1, min = 1, max = 10})
      gsoMenu.gsodraw.circle1:MenuElement({name = "        Radius",  id = "aaxeradius", value = 170, min = 50, max = 300, step = 10})
      gsoMenu.gsodraw.circle1:MenuElement({name = "InActive Axes", id = "note10", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
        onclick = function()
          gsoMenu.gsodraw.circle1.iaxeenable:Hide()
          gsoMenu.gsodraw.circle1.iaxecolor:Hide()
          gsoMenu.gsodraw.circle1.iaxewidth:Hide()
          gsoMenu.gsodraw.circle1.iaxeradius:Hide() end })
        gsoMenu.gsodraw.circle1:MenuElement({name = "        Enabled",  id = "iaxeenable", value = true})
        gsoMenu.gsodraw.circle1:MenuElement({name = "        Color",  id = "iaxecolor", color = Draw.Color(255, 153, 0, 0)})
        gsoMenu.gsodraw.circle1:MenuElement({name = "        Width",  id = "iaxewidth", value = 1, min = 1, max = 10})
        gsoMenu.gsodraw.circle1:MenuElement({name = "        Radius",  id = "iaxeradius", value = 170, min = 50, max = 300, step = 10}) end
  if myHero.charName == "Twitch" or myHero.charName == "Ezreal" then
    gsoMenu.gsodraw:MenuElement({name = "Texts", id = "texts1", type = MENU,
      onclick = function()
        if myHero.charName == "Twitch" then
          gsoMenu.gsodraw.texts1.enabletime:Hide(true)
          gsoMenu.gsodraw.texts1.colortime:Hide(true) end
        if myHero.charName == "Ezreal" then
          gsoMenu.gsodraw.texts1.enableautoq:Hide(true)
          gsoMenu.gsodraw.texts1.colorautoqe:Hide(true)
          gsoMenu.gsodraw.texts1.colorautoqd:Hide(true)
          gsoMenu.gsodraw.texts1.sizeautoq:Hide(true)
          gsoMenu.gsodraw.texts1.customautoq:Hide(true)
          gsoMenu.gsodraw.texts1.xautoq:Hide(true)
          gsoMenu.gsodraw.texts1.yautoq:Hide(true) end end})
      if myHero.charName == "Twitch" then
        gsoMenu.gsodraw.texts1:MenuElement({name = "Q Timer", id = "note11", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
          onclick = function()
            gsoMenu.gsodraw.texts1.enabletime:Hide()
            gsoMenu.gsodraw.texts1.colortime:Hide() end })
          gsoMenu.gsodraw.texts1:MenuElement({id = "enabletime", name = "        Enabled", value = true})
          gsoMenu.gsodraw.texts1:MenuElement({id = "colortime", name = "        Color", color = Draw.Color(200, 65, 255, 100)}) end
      if myHero.charName == "Ezreal" then
        gsoMenu.gsodraw.texts1:MenuElement({name = "Auto Q", id = "note9", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
          onclick = function()
            gsoMenu.gsodraw.texts1.enableautoq:Hide()
            gsoMenu.gsodraw.texts1.colorautoqe:Hide()
            gsoMenu.gsodraw.texts1.colorautoqd:Hide()
            gsoMenu.gsodraw.texts1.sizeautoq:Hide()
            gsoMenu.gsodraw.texts1.customautoq:Hide()
            gsoMenu.gsodraw.texts1.xautoq:Hide()
            gsoMenu.gsodraw.texts1.yautoq:Hide() end })
          gsoMenu.gsodraw.texts1:MenuElement({id = "enableautoq", name = "        Enabled", value = true})
          gsoMenu.gsodraw.texts1:MenuElement({id = "colorautoqe", name = "        Color If Enabled", color = Draw.Color(255, 000, 255, 000)})
          gsoMenu.gsodraw.texts1:MenuElement({id = "colorautoqd", name = "        Color If Disabled", color = Draw.Color(255, 255, 000, 000)})
          gsoMenu.gsodraw.texts1:MenuElement({id = "sizeautoq", name = "        Text Size", value = 25, min = 1, max = 64, step = 1 }) end end
  if _G.Orbwalker then
    GOS.BlockMovement = true
    GOS.BlockAttack = true
    _G.Orbwalker.Enabled:Value(false) end
  if _G.SDK and _G.SDK.Orbwalker then
    _G.SDK.Orbwalker:SetMovement(false)
    _G.SDK.Orbwalker:SetAttack(false) end
  if _G.EOW then
    _G.EOW:SetMovements(false)
    _G.EOW:SetAttacks(false) end
  print("gamsteronAIO "..gsoINFO.version.." | loaded!")
  gsoLoaded = true
end
function OnDraw()
    if not gsoLoaded or not gsoMenu.gsodraw.enabled:Value() then return end
    local mePos = gsoMyHero.pos
    local drawMenu = gsoMenu.gsodraw.circle1
    if gsoDrawData.q and drawMenu.qrange:Value() then
        local qrange = gsoDrawData.qf and gsoDrawData.qf() or gsoDrawData.qr
        gsoDrawCircle(mePos, qrange, drawMenu.qrangewidth:Value(), drawMenu.qrangecolor:Value()) end
    if gsoDrawData.w and drawMenu.wrange:Value() then
        local wrange = gsoDrawData.wf and gsoDrawData.wf() or gsoDrawData.wr
        gsoDrawCircle(mePos, wrange, drawMenu.wrangewidth:Value(), drawMenu.wrangecolor:Value()) end
    if gsoDrawData.e and drawMenu.erange:Value() then
        local erange = gsoDrawData.ef and gsoDrawData.ef() or gsoDrawData.er
        gsoDrawCircle(mePos, erange, drawMenu.erangewidth:Value(), drawMenu.erangecolor:Value()) end
    if gsoDrawData.r and drawMenu.rrange:Value() then
        local rrange = gsoDrawData.rf and gsoDrawData.rf() or gsoDrawData.rr
        gsoDrawCircle(mePos, rrange, drawMenu.rrangewidth:Value(), drawMenu.rrangecolor:Value()) end
end
function OnWndMsg(msg, wParam)
  if not gsoLoaded then return end
  local getTick = gsoGetTickCount()
  local manualNum = -1
  if wParam == HK_Q and getTick > gsoSpellState.lqk + 1000 and Game.CanUseSpell(_Q) == 0 then gsoSpellState.lqk = getTick; manualNum = 0
  elseif wParam == HK_W and getTick > gsoSpellState.lwk + 1000 and Game.CanUseSpell(_W) == 0 then gsoSpellState.lwk = getTick; manualNum = 1
  elseif wParam == HK_E and getTick > gsoSpellState.lek + 1000 and Game.CanUseSpell(_E) == 0 then gsoSpellState.lek = getTick; manualNum = 2
  elseif wParam == HK_R and getTick > gsoSpellState.lrk + 1000 and Game.CanUseSpell(_R) == 0 then gsoSpellState.lrk = getTick; manualNum = 3 end
  if manualNum > -1 and not gsoDelayedSpell[manualNum] then if gsoMode.isCombo() or gsoMode.isHarass() or gsoMode.isLaneClear() or gsoMode.isLastHit() then gsoDelayedSpell[manualNum] = { function() Control.KeyDown(wParam);Control.KeyUp(wParam);Control.KeyDown(wParam);Control.KeyUp(wParam);Control.KeyDown(wParam);Control.KeyUp(wParam); end, getTick} end end
end
