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
local gsoINFO = { version = "0.647", author = "gamsteron" }
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
    delay = delay + (0.07 + Game.Latency() * 0.001)
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
local gsoSpellDraw = { q = false, w = false, e = false, r = false }
local gsoSpellCan = { q = true, w = true, e = true, r = true, botrk = true }
local gsoSpellTimers = { lq = 0, lqk = 0, lw = 0, lwk = 0, le = 0, lek = 0, lr = 0, lrk = 0 }
function OnLoad()
  local gsoOrbwalker = __gsoOrbwalker()
        gsoMenu = gsoOrbwalker.Menu
        gsoMode = gsoOrbwalker.Mode
  local gsoActions = gsoOrbwalker.AddAction
  local gsoTimers = gsoOrbwalker.Timers
  local gsoState = gsoOrbwalker.State
  local gsoFarm = gsoOrbwalker.Farm
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
  local function gsoIsHeroValid(range, hero, jaxE, bb)
    if hero and gsoDistance(gsoMyHero.pos, hero.pos) < range + (bb and hero.boundingRadius or 0) and not hero.dead and hero.isTargetable and hero.valid and hero.visible and not gsoImmortal(hero, jaxE) then
      return true
    else
      return false
    end
  end
  local function gsoInsidePolygon(polygon, point)
    local result = false
    local j = #polygon
    local pointx = point.x
    local pointz = point.z
    for i = 1, #polygon do
      if (polygon[i].z < pointz and polygon[j].z >= pointz or polygon[j].z < pointz and polygon[i].z >= pointz) then
        if (polygon[i].x + ( pointz - polygon[i].z ) / (polygon[j].z - polygon[i].z) * (polygon[j].x - polygon[i].x) < pointx) then
          result = not result
        end
      end
      j = i
    end
    return result
  end
  local function gsoClosestPointOnLineSegment(p, p1, p2)
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
    local gsoEHeroes = gsoObjects.enemyHeroes_spell
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
        local id = not from and target.networkID or 0
        if gsoCheckHeroesCollision(sourcePos, castpos, sD.width, id) then
          return nil
        end
      end
      if sD.mCol then
        local id = from and target.networkID or 0
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
        if (bType == 5 or bType == 11 or bType == 29 or bType == 24 or buff.name == "recall") and buff.duration >= time then
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
    local gsoEHeroes = gsoObjects.enemyHeroes_spell
    for i = 1, #gsoEHeroes do
      local unit = gsoEHeroes[i]
      local extraRange = bb and unit.boundingRadius or 0
      if gsoDistance(sourcePos, unit.pos) < range + extraRange then
        count = count + 1
      end
    end
    return count
  end
  local function gsoCheckTimers(sT)
    local latency = gsoExtra.minLatency * 1000
    local gT = gsoGetTickCount() - latency
    local q = gT - gsoSpellTimers.lq
    local qq = gT - gsoSpellTimers.lqk
    local w = gT - gsoSpellTimers.lw
    local ww = gT - gsoSpellTimers.lwk
    local e = gT - gsoSpellTimers.le
    local ee = gT - gsoSpellTimers.lek
    local r = gT - gsoSpellTimers.lr
    local rr = gT - gsoSpellTimers.lrk
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
    return true
  end
  local function gsoNearTurret(pos)
    local eTurrets = gsoObjects.enemyTurrets
    for i = 1, #eTurrets do
      local tur = eTurrets[i]
      if gsoDistance(tur.pos, pos) < 900 then
        return true
      end
    end
    return false
  end
  local function gsoNearEnemyHero(pos)
    local eHeroes = gsoObjects.enemyHeroes_immortal
    for i = 1, #eHeroes do
      local hero = eHeroes[i]
      if gsoDistance(hero.pos, pos) < hero.boundingRadius then
        return true
      end
    end
    return false
  end
  local function gsoNearEnemyMinion(pos)
    local eMinions = gsoObjects.enemyMinions
    for i = 1, #eMinions do
      local minion = eMinions[i]
      if gsoDistance(minion.pos, pos) < minion.boundingRadius then
        return true
      end
    end
    return false
  end
  local function gsoCastSpellTarget(hkSpell, range, sourcePos, target, bb)
    local castpos = target and target.pos or nil
    local bbox = bb ~= nil and target.boundingRadius or 0
    local canCast = castpos and sourcePos and gsoDistance(castpos, sourcePos) < range + bbox and castpos:ToScreen().onScreen
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
    if not target then return false end
    if hkSpell == HK_Q then spellData = gsoSpellData.q elseif hkSpell == HK_W then spellData = gsoSpellData.w elseif hkSpell == HK_E then spellData = gsoSpellData.e elseif hkSpell == HK_R then spellData = gsoSpellData.r end
    local castpos = target.x and target or gsoGetCastPos(spellData, sourcePos, target, from)
    if castpos then
      local canCheck = false
      if spellData.out then
        for i = 1, 35 do
          local castpos2 = sourcePos:Extended(castpos, 3500 - i * 100)
          if castpos2:ToScreen().onScreen then
            castpos = castpos2
            canCheck = true
            break
          end
        end
      end
      if canCheck == true or castpos:ToScreen().onScreen then
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
    return gsoOrbwalker.CanSetCursorPos and gsoCheckTimers(sT) and Game.CanUseSpell(spell) == 0
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
      
      --[[ vars ]]
      local champInfo = { hasQBuff = false, qEndTime = 0, asNoQ = myHero.attackSpeed, oldWindUp = myHero.attackData.windUpTime }
      
      --[[ menu ]]
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
      
      --[[ draw ]]
      gsoSpellDraw = { w = true, wr = 1200 }
      
      --[[ spell data ]]
      gsoSpellData.w = { delay = 0.25, range = 1200, width = 50, speed = 2000, sType = "line", col = true, hCol = true, mCol = true, out = true }
      gsoSpellData.r = { delay = 0.25, range = 1500, width = 125, speed = 1600, sType = "line", col = false, hCol = true, mCol = false, out = true }
      
      --[[ on enemy hero load ]]
      gsoOrbwalker:OnEnemyHeroLoad(function(heroName)
        gsoMeMenu.rset.semirashe.useon:MenuElement({id = heroName, name = heroName, value = true})
      end)
      
      --[[ damage on minion ]]
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
      
      --[[ custom attack speed ]]
      gsoOrbwalker:AttackSpeed(function()
        local num = gsoGameTimer() - champInfo.qEndTime
        if num > -champInfo.oldWindUp and num < 2 then
          return champInfo.asNoQ
        end
        return gsoMyHero.attackSpeed
      end)
      
      --[[ on move ]]
      gsoOrbwalker:OnMove(function()
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          --R
          local canR = ( isCombo and gsoMeMenu.rset.combo:Value() ) or ( isHarass and gsoMeMenu.rset.harass:Value() )
                canR = canR and gsoIsReady(_R, { q = 0, w = 250, e = 250, r = 1000 })
          if canR then
            if gsoMeMenu.rset.rcd:Value() then
              local t = gsoGetClosestEnemy(mePos, gsoObjects.enemyHeroes_spell, gsoMeMenu.rset.rdist:Value())
              if t and gsoCastSpellSkillShot(HK_R, mePos, t) then
                gsoSpellTimers.lr = gsoGetTickCount()
                gsoSpellCan.w = false
                gsoSpellCan.botrk = false
                return false
              end
            end
            if gsoMeMenu.rset.rci:Value() then
              local t = gsoGetImmobileEnemy(mePos, gsoObjects.enemyHeroes_spell, 1000)
              if t and gsoCastSpellSkillShot(HK_R, mePos, t.pos) then
                gsoSpellTimers.lr = gsoGetTickCount()
                gsoSpellCan.w = false
                gsoSpellCan.botrk = false
                return false
              end
            end
          end
          --Q
          local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
          if canQ and isTarget and gsoIsReadyFast(_Q, { q = 1000, w = 250, e = 250, r = 250 }) then
            local aaSpeed = ( gsoMyHero.attackSpeed + 0.15 + (gsoMyHero:GetSpellData(_Q).level * 0.05) ) * gsoExtra.baseAttackSpeed
            local numAS   = aaSpeed >= 2.5 and 1 / 2.5 or 1 / aaSpeed
            if gsoGameTimer() > gsoTimers.lastAttackSend + numAS and gsoCastSpell(HK_Q) then
              champInfo.oldWindUp = gsoTimers.windUpTime
              champInfo.asNoQ = myHero.attackSpeed
              gsoSpellTimers.lq = gsoGetTickCount()
              gsoExtra.resetAttack = true
              gsoSpellCan.botrk = false
              return false
            end
          end
          --W
          if not isTarget or afterAttack then
            local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                  canW = canW and (not isTarget or gsoSpellCan.w) and gsoIsReady(_W, { q = 0, w = 1000, e = 250, r = 250 })
            if canW then
              local t = isTarget == true and target or gsoGetTarget(1200, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false)
              if t and gsoCastSpellSkillShot(HK_W, mePos, t) then
                gsoSpellTimers.lw = GetTickCount()
                gsoSpellCan.botrk = false
                return false
              end
            end
          end
        end
        return true
      end)
      
      --[[ on tick ]]
      gsoOrbwalker:OnTick(function()
        local qDuration = gsoBuffDuration(gsoMyHero, "asheqattack")
        champInfo.hasQBuff = qDuration > 0
        champInfo.qEndTime = qDuration > 0 and Game.Timer() + qDuration or champInfo.qEndTime
        if gsoMeMenu.rset.semirashe.enabled:Value() and gsoIsReady(_R, { q = 0, w = 250, e = 250, r = 1000 }) then
          local enemyList = gsoObjects.enemyHeroes_spell
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
          local rTarget = gsoGetTarget(rrange, rTargets, gsoMyHero.pos, false, false)
          if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget) then
            gsoSpellTimers.lr = GetTickCount()
            gsoSpellCan.botrk = false
          end
        end
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 0, w = 200, e = 200, r = 200 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 0, w = 300, e = 300, r = 300 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    
    
    
    
    
    
    __AurelionSol = function() end,
    __Azir = function() end,
    __Bard = function() end,
    __Blitzcrank = function() end,
    __Brand = function() end,
    __Braum = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Caitlyn = function()
      local champInfo = { hasRBuff = false }
      local gsoMeMenu = gsoMenu:MenuElement({name = "Caitlyn", id = "gsocaitlyn", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/caitlynE2se.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "immobile", name = "Immobile", value = true})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
      local function caitRRange()
        local rLvl = myHero:GetSpellData(_R).level
        if rLvl == 0 then
          return 2000
        else
          return 1500 + 500 * rLvl
        end
      end
      gsoSpellDraw = { q = true, qr = 1250, w = true, wr = 800, e = true, er = 750, r = true, rf = function() return caitRRange() end }
      gsoSpellData.q = { delay = 0.6, range = 1250, width = 60, speed = 2200, sType = "line", col = false, mCol = false, hCol = false, out = true }
      gsoSpellData.e = { delay = 0.15, range = 750, width = 70, speed = 1600, sType = "line", col = true, mCol = true, hCol = true, out = true }
      gsoOrbwalker:OnMove(function(args)
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          if not isTarget or afterAttack then
            local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
                  canE = canE and isTarget == true and gsoSpellCan.e == true and gsoIsReady(_E, { q = 650, w = 250, e = 1000, r = 1000 })
            if canE and gsoDistance(gsoMyHero.pos, target.pos) < 750 and gsoCastSpellSkillShot(HK_E, gsoMyHero.pos, target) then
              gsoSpellTimers.le = GetTickCount()
              gsoSpellCan.q = false
              gsoSpellCan.botrk = false
              return false
            end
            local canQ = (isCombo and gsoMeMenu.qset.combo:Value()) or (isHarass and gsoMeMenu.qset.harass:Value())
                  canQ = canQ and (not isTarget or gsoSpellCan.q) and gsoIsReady(_Q, { q = 1000, w = 400, e = 400, r = 500 })
            if canQ then
              local qTarget = target
              if not isTarget then qTarget = gsoGetTarget(1250, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false) end
              if qTarget and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qTarget) then
                gsoSpellTimers.lq = GetTickCount()
                gsoSpellCan.e = false
                gsoSpellCan.botrk = false
                return false
              end
            end
          end
        end
        return true
      end)
      
      gsoOrbwalker:OnTick(function()
        local canW = gsoMeMenu.wset.immobile:Value() and gsoIsReady(_W, { q = 650, w = 1000, e = 250, r = 1000 })
        if canW then
          local enemyList = gsoObjects.enemyHeroes_spell
          for i = 1, #enemyList do
            local hero = enemyList[i]
            if gsoDistance(hero.pos, gsoMyHero.pos) < 800 and gsoIsImmobile(hero, 0.5) and gsoCastSpellSkillShot(HK_W, gsoMyHero.pos, hero.pos) then
              gsoSpellTimers.lw = GetTickCount()
              gsoSpellCan.q = false
              gsoSpellCan.e = false
              gsoSpellCan.botrk = false
              break
            end
          end
        end
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 550, w = 150, e = 150, r = 1000 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 650, w = 200, e = 200, r = 1000 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Camille = function() end,
    __Cassiopeia = function() end,
    __Chogath = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Corki = function()
      
      local champInfo = { hasWBuff = false }
      --[[ menu ]]
      local gsoMeMenu = gsoMenu:MenuElement({name = "Corki", id = "gsocorki", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gsocorkidfd8.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "onlyaa", name = "Only OnAttack", value = true})
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
            gsoMeMenu.rset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.rset:MenuElement({id = "harass", name = "Harass", value = false})
      
      --[[ draw ]]
      gsoSpellDraw = { q = true, qr = 825, w = true, wr = 600, r = true, rr = 1225 }
      
      --[[ spell data ]]
      gsoSpellData.q = { delay = 0.3, range = 825, width = 250, speed = 1000, sType = "circular", col = false, mCol = false, hCol = false, out = false }
      gsoSpellData.r = { delay = 0.2, range = 1225, width = 40, speed = 2000, sType = "line", col = true, mCol = true, hCol = true, out = true }
      
      --[[ on move ]]
      gsoOrbwalker:OnMove(function()
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          local enemyList = gsoObjects.enemyHeroes_spell
          if not isTarget or afterAttack then
            --E
            local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
            if canE and champInfo.hasWBuff == false and isTarget and gsoIsReadyFast(_E, { q = 350, w = 350, e = 1000, r = 350 }) and gsoCastSpell(HK_E) then
              gsoSpellTimers.le = GetTickCount()
            end
            --Q
            local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                  canQ = canQ and gsoIsReady(_Q, { q = 1000, w = 350, e = 0, r = 350 }) and (not isTarget or gsoSpellCan.q)
            if canQ and champInfo.hasWBuff == false then
              local qTarget = target
              if not isTarget then qTarget = gsoGetTarget(825, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false) end
              if qTarget and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qTarget) then
                gsoSpellCan.botrk = false
                gsoSpellTimers.lq = gsoGetTickCount()
                return false
              end
            end
            --R
            local canR = ( isCombo and gsoMeMenu.rset.combo:Value() ) or ( isHarass and gsoMeMenu.rset.harass:Value() )
                  canR = canR and gsoIsReady(_R, { q = 350, w = 350, e = 0, r = 1000 }) and (not isTarget or gsoSpellCan.r)
            if canR and champInfo.hasWBuff == false then
              local rTarget = target
              if not isTarget then rTarget = gsoGetTarget(1225, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false) end
              if rTarget and gsoCastSpellSkillShot(HK_R, mePos, rTarget) then
                gsoSpellCan.botrk = false
                gsoSpellTimers.lr = gsoGetTickCount()
                return false
              end
            end
          end
        end
        return true
      end)
      
      --[[ ON TICK ]]
      gsoOrbwalker:OnTick(function()
        champInfo.hasWBuff = gsoHasBuff(gsoMyHero, "valkyriesound") == true
        local getTick = gsoGetTickCount()
        if getTick - gsoSpellTimers.lw > 1000 and Game.CanUseSpell(_W) == 0 then
          for k,v in pairs(gsoDelayedSpell) do
            if k == 1 then
              if not gsoState.isChangingCursorPos then
                v[1]()
                gsoSetCursor({ endTime = GetTickCount() + 50, action = function() return end, active = true }, nil)
                gsoSpellTimers.lw = gsoGetTickCount()
                gsoDelayedSpell[k] = nil
                break
              end
              if GetTickCount() - v[2] > 125 then
                gsoDelayedSpell[k] = nil
              end
              break
            end
          end
        end
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 150, w = 600, e = 0, r = 150 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 250, w = 350, e = 0, r = 250 }) and champInfo.hasWBuff == false end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Darius = function() end,
    __Diana = function() end,
    __DrMundo = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Draven = function()
      
      --[[ vars ]]
      local gsoQParticles = {}
      
      --[[ spell data ]]
      gsoSpellData.e = { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false, hCol = false, mCol = false, out = true }
      gsoSpellData.r = { delay = 0.25, range = 0, width = 125, speed = 2000, sType = "line", col = false, hCol = false, mCol = false, out = true }
      
      --[[ menu ]]
      local gsoMeMenu = gsoMenu:MenuElement({name = "Draven", id = "gsodraven", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/draven.png" })
        gsoMeMenu:MenuElement({name = "AXE settings", id = "aset", type = MENU })
          gsoMeMenu.aset:MenuElement({id = "stopmove", name = "Hold radius", value = 100, min = 75, max = 125, step = 5 })
          if gsoMeMenu.aset.stopmove:Value() < 75 then gsoMeMenu.aset.stopmove:Value(75) end
          gsoMeMenu.aset:MenuElement({id = "cdist", name = "distance from axe to cursor", value = 750, min = 500, max = 1500, step = 50 })
          gsoMeMenu.aset:MenuElement({id = "catch", name = "Catch axes", value = true})
          gsoMeMenu.aset:MenuElement({id = "catcht", name = "stop under turret", value = true})
          gsoMeMenu.aset:MenuElement({id = "catcho", name = "[combo] stop if no enemy in range", value = true})
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
          gsoMeMenu.wset:MenuElement({id = "hdist", name = "max enemy distance", value = 750, min = 500, max = 2000, step = 50 })
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "R Semi Manual", id = "rset", type = MENU })
          gsoMeMenu.rset:MenuElement({name = "Semi Manual", id = "semirdraven", type = MENU })
            gsoMeMenu.rset.semirdraven:MenuElement({name = "Semi-Manual Key", id = "enabled", key = string.byte("T")})
            gsoMeMenu.rset.semirdraven:MenuElement({name = "Only enemies with HP < X%", id = "semilow", value = true})
            gsoMeMenu.rset.semirdraven:MenuElement({name = "X %", id = "semip", value = 35, min = 1, max = 100, step = 1 })
            gsoMeMenu.rset.semirdraven:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
            gsoMeMenu.rset.semirdraven:MenuElement({name = "Use on:", id = "useon", type = MENU })
      
      --[[ draw ]]
      gsoSpellDraw = { e = true, er = 1050 }
      Callback.Add('Draw', function()
        if gsoMeMenu.aset.catch:Value() then
          local aenabled = gsoMenu.gsodraw.circle1.aaxeenable:Value()
          local ienabled = gsoMenu.gsodraw.circle1.iaxeenable:Value()
          if aenabled or ienabled then
            for k,v in pairs(gsoQParticles) do
              if not v.success then
                if v.active and aenabled then
                  local acol = gsoMenu.gsodraw.circle1.aaxecolor:Value()
                  local arad = gsoMenu.gsodraw.circle1.aaxeradius:Value()
                  local awid = gsoMenu.gsodraw.circle1.aaxewidth:Value()
                  gsoDrawCircle(v.pos, arad, awid, acol)
                elseif ienabled then
                  local icol = gsoMenu.gsodraw.circle1.iaxecolor:Value()
                  local irad = gsoMenu.gsodraw.circle1.iaxeradius:Value()
                  local iwid = gsoMenu.gsodraw.circle1.iaxewidth:Value()
                  gsoDrawCircle(v.pos, irad, iwid, icol)
                end
              end
            end
          end
        end
      end)
      
      gsoOrbwalker:OnMove(function()
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          local enemyList = gsoObjects.enemyHeroes_spell
          -- USE E :
          if not isTarget or afterAttack then
            local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
            if canE and gsoIsReady(_E, { q = 0, w = 0, e = 1000, r = 250 }) then
              local eTarget = target
              if not isTarget then eTarget = gsoGetTarget(1050, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false) end
              if eTarget and gsoCastSpellSkillShot(HK_E, mePos, eTarget) then
                gsoSpellTimers.le = GetTickCount()
                gsoSpellCan.botrk = false
                return false
              end
            end
          end
          -- USE W :
          local delayNum = isTarget and 2750 or 2000
          local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
          if canW and afterAttack and gsoIsReady(_W, { q = 0, w = delayNum, e = 350, r = 350 }) then
            for i = 1, #enemyList do
              local hero  = enemyList[i]
              local delayNum = isTarget and 2750 or 2000
              if gsoDistance(myHero.pos, hero.pos) < gsoMeMenu.wset.hdist:Value() and gsoCastSpell(HK_W) then
                gsoSpellTimers.lw = GetTickCount()
                gsoSpellCan.botrk = false
                return false
              end
            end
          end
        end
        return true
      end)
      
      gsoOrbwalker:SetMousePos(function()
        if not gsoMeMenu.aset.catch:Value() then return nil end
        local qPos = nil
        local kID = nil
        local num = 1000000000
        for k,v in pairs(gsoQParticles) do
          if not v.success then
            local distanceToMouse = gsoDistance(v.pos, mousePos)
            if distanceToMouse < num then
              qPos = v.pos
              num = distanceToMouse
              kID = k
            end
          end
        end
        if qPos ~= nil then
          qPos = qPos:Extended(mousePos, gsoMeMenu.aset.stopmove:Value())
          local stopUnderTurret = gsoMeMenu.aset.catcht:Value() and gsoNearTurret(qPos)
          local stopOutOfAARange = gsoMeMenu.aset.catcho:Value() and gsoMode.isCombo() and gsoCountEnemyHeroesInRange(gsoMyHero.pos, gsoMyHero.range + gsoMyHero.boundingRadius, true) == 0
          local stopNearBB = gsoNearEnemyHero(qPos) == true or gsoNearEnemyMinion(qPos) == true
          if qPos and ( stopUnderTurret or stopOutOfAARange or stopNearBB ) then
            qPos = nil
            gsoQParticles[kID].active = false
          else
            gsoQParticles[kID].active = true
          end
        end
        return qPos
      end)
      
      --[[ on enemy hero load ]]
      gsoOrbwalker:OnEnemyHeroLoad(function(heroName)
        gsoMeMenu.rset.semirdraven.useon:MenuElement({id = heroName, name = heroName, value = true})
      end)
      
      --[[ on attack ]]
      gsoOrbwalker:OnAttack(function()
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
          if canQ and isTarget and gsoIsReadyFast(_Q, { q = 1000, w = 0, e = 250, r = 250 }) and gsoCastSpell(HK_Q) then
            gsoSpellTimers.lq = GetTickCount()
          end
        end
      end)
      
      --[[ on tick ]]
      gsoOrbwalker:OnTick(function()
        -- semi r
        if gsoMeMenu.rset.semirdraven.enabled:Value() and gsoIsReady(_R, { q = 0, w = 100, e = 250, r = 1000 }) then
          local enemyList = gsoObjects.enemyHeroes_spell
          local rTargets = {}
          for i = 1, #enemyList do
            local hero = enemyList[i]
            local heroName = hero.charName
            local isFromList = gsoMeMenu.rset.semirdraven.useon[heroName] and gsoMeMenu.rset.semirdraven.useon[heroName]:Value()
            local hpPercent = gsoMeMenu.rset.semirdraven.semilow:Value() and gsoMeMenu.rset.semirdraven.semip:Value() or 100
            local isLowHP = isFromList and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if isLowHP then
              rTargets[#rTargets+1] = hero
            end
          end
          local rrange = gsoMeMenu.rset.semirdraven.rrange:Value()
          local rTarget = gsoGetTarget(rrange, rTargets, gsoMyHero.pos, false, false)
          gsoSpellData.r.range = rrange
          if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget) then
            gsoSpellTimers.lr = GetTickCount()
          end
        end
        -- handle axes
        local mePos = myHero.pos
        for i = 1, Game.ParticleCount() do
          local particle = Game.Particle(i)
          local particlePos = particle and particle.pos or nil
          if particlePos and gsoDistance(mePos, particlePos) < 500 then
            local pname = particle.name
            if pname == "Draven_Base_Q_reticle" then
              local particleID = particle.handle
              if not gsoQParticles[particleID] then
                gsoQParticles[particleID] = { pos = particlePos, tick = GetTickCount(), success = false, active = false }
                gsoTimers.lastMoveSend = 0
              end
            end
          end
        end
        for k,v in pairs(gsoQParticles) do
          local timerMinus = GetTickCount() - v.tick
          local minLatency = gsoExtra.minLatency * 1000
          local numMenu = 1000 - minLatency + myHero.ms - 330
          if not v.success and timerMinus > numMenu then
            gsoQParticles[k].success = true
            gsoTimers.lastMoveSend = 0
          end
          if timerMinus > numMenu and timerMinus < numMenu + 100 then
            gsoTimers.lastMoveSend = 0
          end
          if timerMinus > 2000 then
            gsoQParticles[k] = nil
          end
        end
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 0, w = 0, e = 250, r = 250 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 0, w = 0, e = 350, r = 350 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Ekko = function() end,
    __Elise = function() end,
    __Evelynn = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Ezreal = function()
    
    --[[ vars ]]
      local gsoLoadTime = Game.Timer()
    
    --[[ spell data ]]
      gsoSpellData.q = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true, hCol = true, mCol = true, out = true }
      gsoSpellData.w = { delay = 0.25, range = 1000, width = 80, speed = 1550, sType = "line", col = false, hCol = false, mCol = false, out = true }
      gsoSpellData.r = { delay = 1, range = 0, width = 160, speed = 2000, sType = "line", col = false, hCol = false, mCol = false, out = true }
    
    --[[ menu ]]
      local gsoMeMenu = gsoMenu:MenuElement({name = "Ezreal", id = "gsoezreal", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ezreal.png" })
        gsoMeMenu:MenuElement({name = "Auto Q", id = "autoq", type = MENU })
          gsoMeMenu.autoq:MenuElement({id = "enable", name = "Enable", value = true, key = string.byte("T"), toggle = true})
          gsoMeMenu.autoq:MenuElement({id = "autoqout", name = "Only if enemy out of attack range", value = true})
          gsoMeMenu.autoq:MenuElement({id = "mana", name = "Q Auto min. mana percent", value = 50, min = 0, max = 100, step = 1 })
          gsoMeMenu.autoq:MenuElement({name = "Use on:", id = "useon", type = MENU })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
          gsoMeMenu.qset:MenuElement({id = "laneclear", name = "LaneClear", value = false})
          gsoMeMenu.qset:MenuElement({id = "lasthit", name = "LastHit", value = true})
          gsoMeMenu.qset:MenuElement({id = "qout", name = "Only if enemy out of attack range", value = false})
          gsoMeMenu.qset:MenuElement({id = "qlh", name = "Q LastHit min. mana percent", value = 10, min = 0, max = 100, step = 1 })
          gsoMeMenu.qset:MenuElement({id = "qlc", name = "Q LaneClear min. mana percent", value = 50, min = 0, max = 100, step = 1 })
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
          gsoMeMenu.wset:MenuElement({id = "wout", name = "Only if enemy out of attack range", value = false})
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
          gsoMeMenu.rset:MenuElement({name = "Semi Manual", id = "semirez", type = MENU })
            gsoMeMenu.rset.semirez:MenuElement({name = "Semi-Manual Key", id = "enabled", key = string.byte("T")})
            gsoMeMenu.rset.semirez:MenuElement({name = "Only enemies with HP < X%", id = "semilow", value = true})
            gsoMeMenu.rset.semirez:MenuElement({name = "X %", id = "semip", value = 35, min = 1, max = 100, step = 1 })
            gsoMeMenu.rset.semirez:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
            gsoMeMenu.rset.semirez:MenuElement({name = "Use on:", id = "useon", type = MENU })
    
    --[[ draw ]]
      gsoSpellDraw = { q = true, qr = 1150, w = true, wr = 1000, e = true, er = 475 }
      Callback.Add('Draw', function()
        if gsoMenu.gsodraw.texts1.enableautoq:Value() then
          local mePos = myHero.pos:To2D()
          local posX = mePos.x - 50
          local posY = mePos.y
          if gsoMeMenu.autoq.enable:Value() then
            Draw.Text("Auto Q Enabled", gsoMenu.gsodraw.texts1.sizeautoq:Value(), posX, posY, gsoMenu.gsodraw.texts1.colorautoqe:Value()) 
          else
            Draw.Text("Auto Q Disabled", gsoMenu.gsodraw.texts1.sizeautoq:Value(), posX, posY, gsoMenu.gsodraw.texts1.colorautoqd:Value()) 
          end
        end
      end)
    
    --[[ on enemy hero load ]]
      gsoOrbwalker:OnEnemyHeroLoad(function(heroName)
        gsoMeMenu.rset.semirez.useon:MenuElement({id = heroName, name = heroName, value = true})
        gsoMeMenu.autoq.useon:MenuElement({id = heroName, name = heroName, value = true})
      end)
    
    --[[ on tick ]]
      gsoOrbwalker:OnTick(function()
        local enemyList = gsoObjects.enemyHeroes_spell
        --E
        local getTick = GetTickCount()
        if getTick - gsoSpellTimers.le > 1000 and Game.CanUseSpell(_E) == 0 then
          for k,v in pairs(gsoDelayedSpell) do
            if k == 2 then
              if not gsoState.isChangingCursorPos then
                v[1]()
                gsoSetCursor({ endTime = GetTickCount() + 50, action = function() return end, active = true }, nil)
                gsoSpellTimers.le = gsoGetTickCount()
                gsoDelayedSpell[k] = nil
                break
              end
              if GetTickCount() - v[2] > 125 then
                gsoDelayedSpell[k] = nil
              end
              break
            end
          end
        end
        -- semi r
        if gsoMeMenu.rset.semirez.enabled:Value() and gsoIsReady(_R, { q = 350, w = 350, e = 550, r = 1100 }) then
          local rTargets = {}
          for i = 1, #enemyList do
            local hero = enemyList[i]
            local heroName = hero.charName
            local isFromList = gsoMeMenu.rset.semirez.useon[heroName] and gsoMeMenu.rset.semirez.useon[heroName]:Value()
            local hpPercent = gsoMeMenu.rset.semirez.semilow:Value() and gsoMeMenu.rset.semirez.semip:Value() or 100
            local isLowHP = isFromList and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if isLowHP then
              rTargets[#rTargets+1] = hero
            end
          end
          local rrange = gsoMeMenu.rset.semirez.rrange:Value()
          gsoSpellData.r.range = rrange
          local rTarget = gsoGetTarget(rrange, rTargets, gsoMyHero.pos, true, false)
          if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget) then
            gsoSpellTimers.lr = GetTickCount()
          end
        end
        
        -- AUTO Q :
        local canQ = gsoGameTimer() > gsoLoadTime + 1 and gsoMeMenu.autoq.enable:Value() and not gsoMode.isCombo()
              canQ = canQ and gsoIsReady(_Q, { q = 1000, w = 350, e = 550, r = 1100 })
              canQ = canQ and ( 100 * myHero.mana ) / myHero.maxMana > gsoMeMenu.autoq.mana:Value()
              canQ = canQ and ( not gsoMeMenu.qset.qout:Value() or gsoCountEnemyHeroesInRange(gsoMyHero.pos, gsoMyHero.range + gsoMyHero.boundingRadius, true) == 0 )
        if canQ then
          local qEnemyList = gsoObjects.enemyHeroes_attack
          local meRange = myHero.range + myHero.boundingRadius
          local mePos = myHero.pos
          for i = 1, #qEnemyList do
            local unit = qEnemyList[i]
            local unitName = unit.charName
            if gsoMeMenu.autoq.useon[unitName] and gsoMeMenu.autoq.useon[unitName]:Value() then
              local unitPos = unit.pos
              local distance = gsoDistance(mePos, unitPos)
              local isAA = distance < meRange + unit.boundingRadius
              if distance < 1150 and ( not isAA or gsoSpellCan.q ) and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, unit) then
                gsoSpellTimers.lq = GetTickCount()
                gsoSpellCan.w = false
                break
              end
            end
          end
        end
        gsoObjects.comboTarget = nil
      end)
      
    --[[ local functions ]]
      local function gsoCastQ(t)
        if t and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, t, true) then
          gsoSpellTimers.lq = GetTickCount()
          gsoSpellCan.w = false
          return true
        end
        return false
      end
      
      local function gsoCastQFarm(isLastHit, isLaneClear, isHarass)
        local isLH = gsoMeMenu.qset.lasthit:Value() and (isLastHit or isHarass)
        local isLC = gsoMeMenu.qset.laneclear:Value() and isLaneClear
        if isLH or isLC then
          local canQ = gsoIsReady(_Q, { q = 1000, w = 350, e = 500, r = 1100 })
          if canQ == false then return false end
          local manaPercent = 100 * myHero.mana / myHero.maxMana
          local canLH = manaPercent > gsoMeMenu.qset.qlh:Value()
          local canLC = manaPercent > gsoMeMenu.qset.qlc:Value()
          if not canLH and not canLC then return false end
          local qDmg = ((25 * myHero:GetSpellData(_Q).level) - 10) + (1.1 * myHero.totalDamage) + (0.4 * myHero.ap)
          local enemyMinions = gsoObjects.enemyMinions
          local qLaneClearable = {}
          local qCanLaneClear = isLaneClear
          local mePos = gsoMyHero.pos
          for i = 1, #enemyMinions do
            local eMinion = enemyMinions[i]
            local eMinion_handle	= eMinion.handle
            if eMinion.handle ~= gsoFarm.lastHitID then
              local eMinPredictedHP = gsoHPPred(eMinion.health, eMinion_handle, gsoDistance(mePos, eMinion.pos) / 2000)
              if eMinPredictedHP - qDmg < 0 then
                if gsoCastQ(eMinion) then
                  gsoFarm.lastHitQID = eMinion.handle
                  return true
                end
                qCanLaneClear = false
              elseif qCanLaneClear == true and eMinPredictedHP - qDmg > 100 then
                qLaneClearable[#qLaneClearable+1] = eMinion
              end
            end
          end
          if qCanLaneClear == true then
            for i = 1, #enemyMinions do
              if gsoCastQ(enemyMinions[i]) then
                return true
              end
            end
          end
        end
        return false
      end
      
    --[[ on move ]]
      gsoOrbwalker:OnMove(function()
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        local isLastHit = gsoMode.isLastHit()
        local isLaneClear = gsoMode.isLaneClear()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          if not isTarget or afterAttack then
            --Q
            local canQ = gsoIsReady(_Q, { q = 1000, w = 350, e = 500, r = 1100 })
            canQ = canQ and ( not gsoMeMenu.qset.qout:Value() or not isTarget )
            canQ = canQ and ( not isTarget or gsoSpellCan.q )
            canQ = canQ and ( ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() ) )
            if canQ then
              local qTarget = target
              if not isTarget then qTarget = gsoGetTarget(1150, gsoObjects.enemyHeroes_attack, gsoMyHero.pos, false, false) end
              if qTarget and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qTarget) then
                gsoSpellTimers.lq = GetTickCount()
                gsoSpellCan.w = false
                return false
              end
            end
            --W
            local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                  canW = canW and ( not gsoMeMenu.wset.wout:Value() or not isTarget)
                  canW = canW and ( not isTarget or gsoSpellCan.w ) and gsoIsReady(_W, { q = 350, w = 1000, e = 500, r = 1100 })
            if canW then
              local wTarget = target
              if not isTarget then wTarget = gsoGetTarget(1000, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false) end
              if wTarget and gsoCastSpellSkillShot(HK_W, gsoMyHero.pos, wTarget) then
                gsoSpellTimers.lw = GetTickCount()
                gsoSpellCan.q = false
                return false
              end
            end
          end
        elseif isLastHit or isLaneClear or isHarass then
          --Q FARM
          if gsoCastQFarm(isLastHit, isLaneClear, isHarass) then
            gsoSpellTimers.lq = GetTickCount()
            gsoSpellCan.w = false
            return false
          end
        end
        return true
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 175, w = 175, e = 250, r = 1000 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 350, w = 350, e = 350, r = 1100 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Jhin = function()
      
      gsoOrbwalker.OnlyServer()
      
      local champInfo = { hasPBuff = false, hasRBuff = false }
      local gsoJhinRPos = { polygon = nil, canDraw = false, startPos = nil, pos1 = nil, middle = nil, pos2 = nil }
      --[[ menu ]]
      local gsoMeMenu = gsoMenu:MenuElement({name = "Jhin", id = "gsojhin", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gsojhin23d.png" })
        gsoMeMenu:MenuElement({id = "autor", name = "Auto R -> if jhin has R Buff", value = true})
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "onlyimmo", name = "Only Immobile", value = true})
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
      
      --[[ draw ]]
      gsoSpellDraw = { q = true, qr = 550 + 120, w = true, wr = 3000, e = true, er = 750, r = true, rr = 3500 }
      
      --[[ spell data ]]
      gsoSpellData.q = { delay = 0.25, range = 0 }
      gsoSpellData.w = { delay = 0.75, range = 3000, width = 40, speed = 5000, sType = "line", col = false, mCol = false, hCol = false, out = true }
      gsoSpellData.e = { delay = 0.25, range = 750, width = 140, speed = 1650, sType = "circular", col = false, mCol = false, hCol = false, out = false }
      gsoSpellData.r = { delay = 0.25, range = 3500, width = 80, speed = 5000, sType = "line", col = false, mCol = false, hCol = false, out = true }
      
      gsoOrbwalker:OnTick(function()
        champInfo.hasPBuff = gsoHasBuff(gsoMyHero, "jhinpassivereload") == true
        local enemyList = gsoObjects.enemyHeroes_spell
        local aSpell = gsoMyHero.activeSpell
        if aSpell and aSpell.valid and aSpell.name:lower() == "jhinr" then
          if gsoJhinRPos.canDraw == false and GetTickCount() > gsoSpellTimers.lrk + 250 then
            local middlePos = Vector(aSpell.placementPos)
            local startPos = Vector(aSpell.startPos)
            local pos1 = startPos + (middlePos - startPos):Rotated(0, 30.6 * math.pi / 180, 0):Normalized() * 3500
            local pos2 = startPos + (middlePos - startPos):Rotated(0, -30.6 * math.pi / 180, 0):Normalized() * 3500
            gsoJhinRPos.polygon = { pos1 + (pos1 - startPos):Normalized() * 3500, pos2 + (pos2 - startPos):Normalized() * 3500, startPos }
            gsoJhinRPos.middle = middlePos
            gsoJhinRPos.pos1 = pos1
            gsoJhinRPos.pos2 = pos2
            gsoJhinRPos.startPos = startPos
            gsoJhinRPos.canDraw = true
          end
          champInfo.hasRBuff = true
          if gsoJhinRPos.canDraw == true then
            if gsoMeMenu.autor:Value() and gsoIsReady(_R, { q = 0, w = 0, e = 0, r = 750 }) then
              local rTargets = {}
              local mePos = gsoMyHero.pos
              for i = 1, #enemyList do
                local unit = enemyList[i]
                local unitPos = unit.pos
                if gsoInsidePolygon(gsoJhinRPos.polygon, unitPos) == true then
                  local dist = gsoDistance(mePos, unitPos)
                  local rDelay = 0.25 + (dist / 5000)
                  local unitMoveLenght = unit.ms * rDelay * 0.75
                  if gsoDistance(mePos, unit.pos) < 3500 - unitMoveLenght then
                    rTargets[#rTargets+1] = unit
                  end
                end
              end
              local rTarget = gsoGetTarget(3500, rTargets, gsoMyHero.pos, false, false)
              if rTarget then
                if gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget) then
                  gsoSpellTimers.lr = GetTickCount()
                end
              end
            end
          end
        elseif champInfo.hasRBuff == true and gsoJhinRPos.canDraw == true and GetTickCount() > gsoSpellTimers.lrk + 500 then
          champInfo.hasRBuff = false
          gsoJhinRPos.canDraw = false
        end
        gsoObjects.comboTarget = nil
      end)
      
      Callback.Add('Draw', function()
        if gsoJhinRPos.canDraw then
          local p1 = gsoJhinRPos.startPos:To2D()
          local p2 = gsoJhinRPos.pos1:To2D()
          local p3 = gsoJhinRPos.pos2:To2D()
          Draw.Line(p1.x, p1.y, p2.x, p2.y,1,gsoDrawColor(255, 255, 255, 255))
          Draw.Line(p1.x, p1.y, p3.x, p3.y,1,gsoDrawColor(255, 255, 255, 255))
        end
      end)
      
      --[[ on move ]]
      gsoOrbwalker:OnMove(function()
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local mePos = gsoMyHero.pos
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local enemyList = gsoObjects.enemyHeroes_spell
          if GetTickCount() < gsoSpellTimers.lrk + 350 then
            champInfo.hasRBuff = true
          end
          if champInfo.hasRBuff == true then return false end
          if not isTarget or afterAttack or champInfo.hasPBuff == true then
            local CanSpell = not isTarget or champInfo.hasPBuff == true
            --Q
            local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                  canQ = canQ and ( CanSpell or gsoSpellCan.q ) and gsoIsReady(_Q, { q = 1000, w = 750, e = 350, r = 500 })
            if canQ then
              local qTarget = target
              gsoSpellData.q.range = 550 + gsoMyHero.boundingRadius
              if not isTarget then qTarget = gsoGetTarget(gsoSpellData.q.range, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, true) end
              if qTarget and gsoCastSpellTarget(HK_Q, gsoSpellData.q.range + qTarget.boundingRadius - 35, mePos, qTarget) then
                gsoSpellCan.botrk = false
                gsoSpellTimers.lq = gsoGetTickCount()
                return false
              end
            end
            --W
            local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                  canW = canW and ( CanSpell or gsoSpellCan.w ) and gsoIsReady(_W, { q = 350, w = 1000, e = 350, r = 500 })
            if canW then
              local t = target
              if isTarget == false then t = gsoGetTarget(3000, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false) end
              if t and gsoCastSpellSkillShot(HK_W, mePos, t) then
                gsoSpellCan.botrk = false
                gsoSpellTimers.lw = GetTickCount()
                return false
              end
            end
            --E
            local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
                  canE = canE and ( CanSpell or gsoSpellCan.e ) and gsoIsReady(_E, { q = 350, w = 750, e = 1000, r = 500 })
            if canE then
              if gsoMeMenu.eset.onlyimmo:Value() then
                local t = gsoGetImmobileEnemy(mePos, gsoObjects.enemyHeroes_spell, 750)
                if t and gsoCastSpellSkillShot(HK_E, mePos, t.pos) then
                  gsoSpellCan.botrk = false
                  gsoSpellTimers.le = GetTickCount()
                  return false
                end
              else
                local t = isTarget == true and target or gsoGetTarget(750, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false)
                if t and gsoCastSpellSkillShot(HK_E, mePos, t) then
                  gsoSpellCan.botrk = false
                  gsoSpellTimers.le = GetTickCount()
                  return false
                end
              end
            end
          end
        end
        return true
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 150, w = 600, e = 150, r = 500 }) and champInfo.hasRBuff == false end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 250, w = 750, e = 250, r = 500 }) and champInfo.hasPBuff == false and champInfo.hasRBuff == false end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Jinx = function()
      
      --[[ vars ]]
      local champInfo = { hasQBuff = false, asQ = gsoMyHero.attackSpeed, lasQBuff = 0, lastQNoBuff = 0 }
      
      --[[ menu ]]
      local gsoMeMenu = gsoMenu:MenuElement({id = "gsojinx", name = "Jinx", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/jinx.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "qrange", name = "Extra Q Buff Range", value = 0, min = 0, max = 50, step = 10 })
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
      
      --[[ draw data ]]
      local _jinxQ = function()
        if champInfo.hasQBuff then
          return 525 + gsoMyHero.boundingRadius + 35
        else
          local qExtra = 25 * gsoMyHero:GetSpellData(_Q).level
          return 575 + qExtra + myHero.boundingRadius + 35
        end
      end
      gsoSpellDraw = { q = true, qf = function() return _jinxQ() end, w = true, wr = 1450, e = true, er = 900 }
      
      --[[ spell data ]]
      gsoSpellData.w = { delay = 0.5, range = 1450, width = 70, speed = 3200, sType = "line", col = true, hCol = true, mCol = true, out = true }
      gsoSpellData.r = { delay = 0.5, range = 0, width = 225, speed = 1750, sType = "line", col = false, hCol = true, mCol = false, out = true }
      
      --[[ on enemy hero load ]]
      gsoOrbwalker:OnEnemyHeroLoad(function(heroName)
        gsoMeMenu.rset.semirjinx.useon:MenuElement({id = heroName, name = heroName, value = true})
      end)
      
      --[[ on move ]]
      gsoOrbwalker:OnMove(function(args)
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          --E
          local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
          if canE and gsoIsReady(_E, { q = 650, w = 550, e = 1000, r = 550 }) and gsoCastSpellTarget(HK_E, 900, mePos, gsoGetImmobileEnemy(mePos, gsoObjects.enemyHeroes_spell, 900)) then
            gsoSpellTimers.le = gsoGetTickCount()
            gsoSpellCan.botrk = false
            return false
          end
          --Q
          local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
          if canQ and gsoIsReadyFast(_Q, { q = 650, w = 550, e = 75, r = 550 }) then
            local canCastQ = false
            local extraQ = 25 * myHero:GetSpellData(_Q).level
            local qRange = 575 + extraQ
            if not isTarget and not champInfo.hasQBuff and gsoCountEnemyHeroesInRange(mePos, qRange + 300, false) > 0 then
              canCastQ = true
              champInfo.lasQBuff = gsoGetTickCount()
            end
            if isTarget and champInfo.hasQBuff and gsoDistance(mePos, target.pos) < 525 + gsoMyHero.boundingRadius then
              canCastQ = true
              champInfo.lastQNoBuff = gsoGetTickCount()
              champInfo.asQ = gsoMyHero.attackSpeed
            end
            if canCastQ and gsoCastSpell(HK_Q) then
              gsoSpellTimers.lq = gsoGetTickCount()
              gsoSpellCan.botrk = false
              return false
            end
          end
          --W
          if not isTarget or afterAttack then
            local wout = gsoMeMenu.wset.wout:Value()
            if not wout or not isTarget then
              local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
              if canW and gsoIsReady(_W, { q = 0, w = 1000, e = 75, r = 550 }) and (not isTarget or gsoSpellCan.w) then
                local wTarget = target
                if not isTarget then wTarget = gsoGetTarget(1450, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false) end
                if wTarget and gsoCastSpellSkillShot(HK_W, mePos, wTarget) then
                  gsoSpellTimers.lw = gsoGetTickCount()
                  gsoSpellCan.botrk = false
                  return false
                end
              end
            end
          end
        end
        return true
      end)
      
      --[[ on tick ]]
      gsoOrbwalker:OnTick(function()
        champInfo.hasQBuff = gsoHasBuff(gsoMyHero, "jinxq") == true
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
        if canQ and gsoIsReadyFast(_Q, { q = 650, w = 550, e = 75, r = 550 }) then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local canCastQ = false
          local extraQ = 25 * myHero:GetSpellData(_Q).level
          local qRange = 575 + extraQ
          local mePos = gsoMyHero.pos
          if not isTarget and not champInfo.hasQBuff and gsoCountEnemyHeroesInRange(mePos, qRange + 300, false) > 0 then
            canCastQ = true
            champInfo.lasQBuff = gsoGetTickCount()
          end
          if isTarget and champInfo.hasQBuff and gsoDistance(mePos, target.pos) < 525 + gsoMyHero.boundingRadius then
            canCastQ = true
            champInfo.lastQNoBuff = gsoGetTickCount()
            champInfo.asQ = gsoMyHero.attackSpeed
          end
          if canCastQ and gsoCastSpell(HK_Q) then
            gsoSpellTimers.lq = gsoGetTickCount()
            gsoSpellCan.botrk = false
            return false
          end
        end
        -- semi r
        if gsoMeMenu.rset.semirjinx.enabled:Value() and gsoIsReady(_R, { q = 0, w = 550, e = 75, r = 1000 }) then
          local enemyList = gsoObjects.enemyHeroes_spell
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
          local rTarget = gsoGetTarget(rrange, rTargets, gsoMyHero.pos, false, false)
          gsoSpellData.r.range = rrange
          if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget) then
            gsoSpellTimers.lr = GetTickCount()
            gsoSpellCan.botrk = false
          end
        end
        gsoObjects.comboTarget = nil
      end)
      gsoOrbwalker:CanChangeAnimationTime(function()
        if gsoGetTickCount() < champInfo.lasQBuff + 350 or champInfo.hasQBuff then
          return false
        elseif gsoGetTickCount() > champInfo.lastQNoBuff + 150 then
          return true
        end
      end)
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 0, w = 500, e = 0, r = 500 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 0, w = 600, e = 0, r = 600 }) end)
      
      --[[ custom attack speed ]]
      gsoOrbwalker:AttackSpeed(function()
        if gsoGetTickCount() < champInfo.lasQBuff + 100 then
          return champInfo.asQ
        end
        return gsoMyHero.attackSpeed
      end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
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
      
      --[[ set ap ]]
      gsoOrbwalker.IsAP()
      
      --[[ vars ]]
      local champInfo = { hasWBuff = false }
      
      --[[ menu ]]
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
      
      --[[ draw data ]]
      local _kogR = function()
        local rlvl = gsoMyHero:GetSpellData(_R).level
        if rlvl == 0 then
          return 1200
        else
          local extraR = 300 * rlvl
          return 900 + extraR
        end
      end
      gsoSpellDraw = { q = true, qr = 1175, e = true, er = 1280, r = true, rf = function() return _kogR() end }
      
      --[[ spell data ]]
      gsoSpellData.q = { delay = 0.25, range = 1175, width = 70, speed = 1650, sType = "line", col = true, hCol = true, mCol = true, out = true }
      gsoSpellData.e = { delay = 0.25, range = 1280, width = 120, speed = 1350, sType = "line", col = false, hCol = false, mCol = false, out = true }
      gsoSpellData.r = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false, hCol = false, mCol = false, out = false }
      
      --[[ on enemy hero load ]]
      gsoOrbwalker:OnEnemyHeroLoad(function(heroName)
        gsoMeMenu.rset.semirkog.useon:MenuElement({id = heroName, name = heroName, value = true})
      end)
      
      --[[ on move ]]
      gsoOrbwalker:OnMove(function(args)
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          --W
          local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                canW = canW and gsoIsReadyFast(_W, { q = 250, w = 1000, e = 250, r = 250 })
                canW = canW and gsoGameTimer() > gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.5 )
          local enemyList = gsoObjects.enemyHeroes_attack
          if canW then
            local mePos = gsoMyHero.pos
            for i = 1, #enemyList do
              local hero = enemyList[i]
              if gsoDistance(mePos, hero.pos) < 610 + ( 20 * gsoMyHero:GetSpellData(_W).level ) + gsoMyHero.boundingRadius + hero.boundingRadius and gsoCastSpell(HK_W) then
                gsoSpellTimers.lw = GetTickCount()
                gsoSpellCan.q = false
                gsoSpellCan.e = false
                gsoSpellCan.r = false
                gsoSpellCan.botrk = false
                return false
              end
            end
          end
          if not isTarget or afterAttack then
            local wMana = 40 - ( gsoMyHero:GetSpellData(_W).currentCd * gsoMyHero.mpRegen )
            local meMana = gsoMyHero.mana - wMana
            if not isTarget and gsoGetTickCount() - gsoSpellTimers.lw < 350 then
              return
            end
            --Q
            local stopQIfW = gsoMeMenu.wset.stopq:Value() and champInfo.hasWBuff
            local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                  canQ = canQ and not stopQIfW and meMana > gsoMyHero:GetSpellData(_Q).mana and (not isTarget or gsoSpellCan.q)
            if canQ and gsoIsReady(_Q, { q = 1000, w = 150, e = 350, r = 350 }) then
              local qTarget = isTarget and target or gsoGetTarget(1175, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false)
              if qTarget and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qTarget) then
                gsoSpellTimers.lq = GetTickCount()
                gsoSpellCan.e = false
                gsoSpellCan.r = false
                gsoSpellCan.botrk = false
                return false
              end
            end
            --E
            local stopEIfW = gsoMeMenu.wset.stope:Value() and champInfo.hasWBuff
            local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
                  canE = canE and not stopEIfW and meMana > gsoMyHero:GetSpellData(_E).mana and (not isTarget or gsoSpellCan.e)
                  canE = canE and ( myHero.mana * 100 ) / myHero.maxMana > gsoMeMenu.eset.emana:Value() and gsoIsReady(_E, { q = 350, w = 150, e = 1000, r = 350 }) 
            if canE then
              local eTarget = isTarget and target or gsoGetTarget(1280, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false)
              if eTarget and gsoCastSpellSkillShot(HK_E, gsoMyHero.pos, eTarget) then
                gsoSpellTimers.le = GetTickCount()
                gsoSpellCan.q = false
                gsoSpellCan.r = false
                gsoSpellCan.botrk = false
                return false
              end
            end
            --R
            local rStacks = gsoBuffCount(myHero, "kogmawlivingartillerycost") < gsoMeMenu.rset.stack:Value()
            local stopRIfW = gsoMeMenu.wset.stopr:Value() and champInfo.hasWBuff
            local canR = ( isCombo and gsoMeMenu.rset.combo:Value() ) or ( isHarass and gsoMeMenu.rset.harass:Value() )
                  canR = canR and rStacks and not stopRIfW and gsoIsReady(_R, { q = 350, w = 150, e = 350, r = 750 }) and (not isTarget or gsoSpellCan.r)
                  canR = canR and meMana > gsoMyHero:GetSpellData(_R).mana and ( gsoMyHero.mana * 100 ) / gsoMyHero.maxMana > gsoMeMenu.rset.rmana:Value()
            if canR then
              local rrange = 900 + ( 300 * gsoMyHero:GetSpellData(_R).level )
              local onlyLowR = gsoMeMenu.rset.onlylow:Value()
              if onlyLowR and isTarget and ( target.health * 100 ) / target.maxHealth > 39 then isTarget = false end
              local enemyList = gsoObjects.enemyHeroes_spell
              local rTargets = {}
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
              local rTarget = isTarget and target or gsoGetTarget(gsoSpellData.r.range + 110, rTargets, gsoMyHero.pos, true, false)
              if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget) then
                gsoSpellTimers.lr = GetTickCount()
                gsoSpellCan.q = false
                gsoSpellCan.e = false
                gsoSpellCan.botrk = false
                return false
              end
            end
          end
        end
        return true
      end)
      
      --[[ on tick ]]
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
          local enemyList = gsoObjects.enemyHeroes_spell
          local extraRRange = 300 * myHero:GetSpellData(_R).level 
          gsoSpellData.r.range = 900 + extraRRange
          local rStacks = gsoBuffCount(myHero, "kogmawlivingartillerycost") < gsoMeMenu.rset.stack:Value()
          local checkRStacksKS = gsoMeMenu.rset.ksmenu.csksr:Value()
          if gsoMeMenu.rset.ksmenu.ksr:Value() and ( not checkRStacksKS or rStacks ) then
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
            if gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, gsoGetTarget(gsoSpellData.r.range + 110, rTargets, gsoMyHero.pos, true, false)) then
              gsoSpellTimers.lr = GetTickCount()
              gsoSpellCan.q = false
              gsoSpellCan.e = false
              gsoSpellCan.botrk = false
              return
            end
          end
          local checkRStacksSemi = gsoMeMenu.rset.semirkog.semistacks:Value()
          if gsoMeMenu.rset.semirkog.semir:Value() and ( not checkRStacksSemi or rStacks ) then
            local onlyLowR = gsoMeMenu.rset.semirkog.semilow:Value()
            local enemyList = gsoObjects.enemyHeroes_spell
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
            if gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, gsoGetTarget(gsoSpellData.r.range + 110, rTargets, gsoMyHero.pos, true, false)) then
              gsoSpellTimers.lr = GetTickCount()
              gsoSpellCan.q = false
              gsoSpellCan.e = false
              gsoSpellCan.botrk = false
              return
            end
          end
        end
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 200, w = 0, e = 200, r = 200 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 350, w = 0, e = 350, r = 350 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
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
      gsoSpellDraw = { q = true, qr = 500+120, w = true, wr = 900+350, e = true, er = 425, r = true, rr = 1200 }
      gsoSpellData.w = { delay = 0.25, range = 1250, width = 75, speed = 1600, sType = "line", col = false, mCol = false, hCol = false, out = true }
      gsoOrbwalker:OnMove(function(args)
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          if not isTarget or afterAttack then
            local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
                  canE = canE and (not isTarget or (isTarget and gsoSpellCan.e)) and gsoIsReadyFast(_E, { q = 500, w = 250, e = 1000, r = 500 }) and not champInfo.hasRBuff
            if canE then
              local meRange = gsoMyHero.range + gsoMyHero.boundingRadius
              local enemyList = gsoObjects.enemyHeroes_attack
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
                  gsoSpellTimers.le = GetTickCount()
                  gsoSpellCan.q = false
                  gsoSpellCan.w = false
                  gsoSpellCan.r = false
                  gsoExtra.resetAttack = true
                  return false
                end
              end
            end
            local canQ = (isCombo and gsoMeMenu.qset.combo:Value()) or (isHarass and gsoMeMenu.qset.harass:Value())
                  canQ = canQ and isTarget and gsoSpellCan.q and gsoIsReady(_Q, { q = 1000, w = 400, e = 400, r = 500 }) and not champInfo.hasRBuff
            if canQ and isTarget and gsoCastSpellTarget(HK_Q, 500 + gsoMyHero.boundingRadius + target.boundingRadius, mePos, target) then
              gsoSpellTimers.lq = GetTickCount()
              gsoSpellCan.w = false
              gsoSpellCan.r = false
              return false
            end
            local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                  canW = canW and (not isTarget or gsoSpellCan.w) and gsoIsReady(_W, { q = 500, w = 350, e = 350, r = 500 }) and not champInfo.hasRBuff
            if canW then
              local wTarget = target
              if not isTarget then wTarget = gsoGetTarget(1350, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false) end
              if wTarget and gsoCastSpellSkillShot(HK_W, mePos, wTarget) then
                gsoSpellTimers.lw = GetTickCount()
                gsoSpellCan.q = false
                gsoSpellCan.r = false
                return false
              end
            end
          end
        end
        return true
      end)
      
      gsoOrbwalker:OnTick(function()
        if gsoHasBuff(gsoMyHero, "lucianr") then
          champInfo.hasRBuff = true
          gsoState.enabledAttack = false
        else
          champInfo.hasRBuff = false
          gsoState.enabledAttack = true
        end
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 350, w = 250, e = 450, r = 0 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 350, w = 200, e = 300, r = 0 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Nami = function()
      
      local eHeroes = {
        ["Ashe"] = true,
        ["Caitlyn"] = true,
        ["Corki"] = true,
        ["Draven"] = true,
        ["Ezreal"] = true,
        ["Jax"] = true,
        ["Jinx"] = true,
        ["Kalista"] = true,
        ["Kaisa"] = true,
        ["Kayle"] = true,
        ["Kindred"] = true,
        ["KogMaw"] = true,
        ["Lucian"] = true,
        ["MasterYi"] = true,
        ["MissFortune"] = true,
        ["Quinn"] = true,
        ["Sivir"] = true,
        ["Teemo"] = true,
        ["Tristana"] = true,
        ["Twitch"] = true,
        ["Tryndamere"] = true,
        ["Varus"] = true,
        ["Vayne"] = true,
        ["Xayah"] = true
      }
      
      --[[ set ap ]]
      gsoOrbwalker.IsAP()
      
      --[[ menu ]]
      local gsoMeMenu = gsoMenu:MenuElement({name = "Nami", id = "gsonami", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/namiSUh73d.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "immobile", name = "Auto Immobile", value = true})
          gsoMeMenu.qset:MenuElement({id = "immoallies", name = "Immobile - minimum allies near enemy", value = 1, min = 0, max = 4, step = 1})
          gsoMeMenu.qset:MenuElement({id = "immoxallies", name = "Immobile - ally distance to enemy", value = 1000, min = 500, max = 2000, step = 1})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo - W on enemy (priority is healing)", value = true})
          gsoMeMenu.wset:MenuElement({id = "healally", name = "Heal Ally", value = true})
          gsoMeMenu.wset:MenuElement({id = "healallyb", name = "Heal Ally only if can bounce", value = true})
          gsoMeMenu.wset:MenuElement({id = "xhealth", name = "X HP% - all allies (priority are allies from list)", value = 25, min = 0, max = 100, step = 1})
          gsoMeMenu.wset:MenuElement({id = "xhealthlist", name = "X HP% - allies from list", value = 75, min = 0, max = 100, step = 1})
          gsoMeMenu.wset:MenuElement({name = "list of allies:", id = "useon", type = MENU })
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo - E on self", value = false})
          gsoMeMenu.eset:MenuElement({id = "allyattack", name = "Only on ally attack on enemy", value = true})
          gsoMeMenu.eset:MenuElement({name = "list of allies:", id = "useon", type = MENU })
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
          gsoMeMenu.rset:MenuElement({id = "immobile", name = "Auto Immobile", value = true})
          gsoMeMenu.rset:MenuElement({id = "immodist", name = "Immobile - maximum distance", value = 1000, min = 500, max = 2700, step = 100})
          gsoMeMenu.rset:MenuElement({id = "immoallies", name = "Immobile - minimum allies near enemy", value = 1, min = 0, max = 4, step = 1})
          gsoMeMenu.rset:MenuElement({id = "immoxallies", name = "Immobile - ally distance to enemy", value = 1000, min = 500, max = 2000, step = 1})
          gsoMeMenu.rset:MenuElement({name = "R Semi Manual", id = "semirnami", type = MENU })
            gsoMeMenu.rset.semirnami:MenuElement({name = "Semi-Manual Key", id = "enabled", key = string.byte("T")})
            gsoMeMenu.rset.semirnami:MenuElement({name = "Only enemies with HP < X%", id = "semilow", value = true})
            gsoMeMenu.rset.semirnami:MenuElement({name = "X %", id = "semip", value = 100, min = 1, max = 100, step = 1 })
            gsoMeMenu.rset.semirnami:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 1000, min = 500, max = 2700, step = 100 })
            gsoMeMenu.rset.semirnami:MenuElement({name = "Use on:", id = "useon", type = MENU })
      
      --[[ draw ]]
      gsoSpellDraw = { q = true, qr = 875, w = true, wr = 725, e = true, er = 800, r = true, rr = 2750 }
      
      --[[ spell data ]]
      --radius = 200, diameter = 400
      gsoSpellData.q = { delay = 0.5, range = 875, width = 200, speed = 1750, sType = "circular", col = false, mCol = false, hCol = false, out = false }
      --width = 250 + enemyBoundingRadius, full width = 500 + 2 * enemyBoundingRadius
      gsoSpellData.w = { delay = 0.25, range = 725 }
      gsoSpellData.e = { delay = 0, range = 800 }
      gsoSpellData.r = { delay = 0.5, range = 2750, width = 250, speed = 850, sType = "line", col = false, mCol = false, hCol = false, out = true }
      
      --[[ on enemy hero load ]]
      gsoOrbwalker:OnEnemyHeroLoad(function(heroName)
        gsoMeMenu.rset.semirnami.useon:MenuElement({id = heroName, name = heroName, value = true})
      end)
      
      gsoOrbwalker:OnAllyHeroLoad(function(heroName)
        local eBoolean = eHeroes[heroName] ~= nil
        gsoMeMenu.wset.useon:MenuElement({id = heroName, name = heroName, value = true})
        gsoMeMenu.eset.useon:MenuElement({id = heroName, name = heroName, value = eBoolean})
      end)
      
      --Q COMBO
      local function castQCombo(target, isTarget)
        if gsoMeMenu.qset.combo:Value() and gsoMode.isCombo() then
          local qTarget = target
          if not isTarget then qTarget = gsoGetTarget(875, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false) end
          if qTarget and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qTarget) then
            return true
          end
        end
        return false
      end
      --Q AUTO IMMOBILE
      local function castQImmobile()
        if gsoMeMenu.qset.immobile:Value() then
          local allyList = gsoObjects.allyHeroes
          local enemyList = gsoObjects.enemyHeroes_spell
          for i = 1, #enemyList do
            local hero = enemyList[i]
            local heroPos = hero.pos
            local countAllies = 0
            if gsoDistance(heroPos, gsoMyHero.pos) < 875 then
              for j = 1, #allyList do
                local ally = allyList[j]
                if ally ~= myHero and gsoDistance(ally.pos, heroPos) < gsoMeMenu.qset.immoxallies:Value() then
                  countAllies = countAllies + 1
                end
              end
              if countAllies >= gsoMeMenu.qset.immoallies:Value() and gsoIsImmobile(hero, 0.5) and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, hero.pos) then
                return true
              end
            end
          end
        end
        return false
      end
      --W AUTO HEAL
      local function castWHeal()
        if gsoMeMenu.wset.healally:Value() then
          local min = 10000
          local minList = 10000
          local minObj = nil
          local minListObj = nil
          local mePos = gsoMyHero.pos
          local allyList = gsoObjects.allyHeroes
          local enemyListAll = gsoObjects.enemyHeroes_immortal
          for i = 1, #allyList do
            local ally = allyList[i]
            local allyName = ally.charName
            local hpPercent = ( ( ally.health + ( ally.hpRegen * 3 ) ) * 100 ) / ally.maxHealth
            if gsoDistance(ally.pos, mePos) < 720 then
              if gsoMeMenu.wset.useon[allyName] and gsoMeMenu.wset.useon[allyName]:Value() then
                if hpPercent <= gsoMeMenu.wset.xhealthlist:Value() and hpPercent < minList then
                  minList = hpPercent
                  minListObj = ally
                end
              else
                if hpPercent <= gsoMeMenu.wset.xhealth:Value() and hpPercent < min then
                  min = hpPercent
                  minObj = ally
                end
              end
            end
          end
          if minListObj then
            if gsoMeMenu.wset.healallyb:Value() then
              for i = 1, #enemyListAll do
                local enemy = enemyListAll[i]
                if gsoDistance(minListObj.pos, enemy.pos) < 790 and gsoCastSpellTarget(HK_W, 720, gsoMyHero.pos, minListObj) then
                  return true
                end
              end
            elseif gsoCastSpellTarget(HK_W, 720, gsoMyHero.pos, minListObj) then
              return true
            end
          end
          if minObj then
            if gsoMeMenu.wset.healallyb:Value() then
              for i = 1, #enemyListAll do
                local enemy = enemyListAll[i]
                if gsoDistance(minObj.pos, enemy.pos) < 790 and gsoCastSpellTarget(HK_W, 720, gsoMyHero.pos, minObj) then
                  return true
                end
              end
            elseif gsoCastSpellTarget(HK_W, 720, gsoMyHero.pos, minObj) then
              return true
            end
          end
        end
        return false
      end
      --W COMBO
      local function castWCombo(target, isTarget)
        if gsoMeMenu.wset.combo:Value() and gsoMode.isCombo() then
          local wTarget = target
          if not isTarget then wTarget = gsoGetTarget(720, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false) end
          if wTarget and gsoCastSpellTarget(HK_W, 720, gsoMyHero.pos, wTarget) then
            return true
          elseif not wTarget then
            local enemyList = gsoObjects.enemyHeroes_spell
            local mePos = gsoMyHero.pos
            for i = 1, #enemyList do
              local enemy = enemyList[i]
              if gsoDistance(mePos, enemy.pos) < 790 and gsoCastSpellTarget(HK_W, 720, gsoMyHero.pos, gsoMyHero) then
                return true
              end
            end
          end  
        end
        return false
      end
      --E AUTO ALLY
      local function castEAlly()
        local allyList = gsoObjects.allyHeroes
        local enemyList = gsoObjects.enemyHeroes_spell
        local mePos = gsoMyHero.pos
        for i = 1, #allyList do
          local ally = allyList[i]
          if gsoMeMenu.eset.useon[ally.charName] and gsoMeMenu.eset.useon[ally.charName]:Value() and gsoDistance(mePos, ally.pos) < 800 then
            local aaData = ally.attackData
            local endTime = aaData.endTime
            local windUpTime = aaData.windUpTime
            if endTime > Game.Timer() and endTime < Game.Timer() + (windUpTime * 0.75) then
              for j = 1, #enemyList do
                local enemy = enemyList[j]
                if enemy.handle == aaData.target and gsoDistance(ally.pos, enemy.pos) < ally.range + ally.boundingRadius + enemy.boundingRadius and gsoCastSpellTarget(HK_E, 800, gsoMyHero.pos, ally) then
                  return true
                end
              end
            end
          end
        end
        return false
      end
      --E COMBO
      local function castECombo()
        if gsoMeMenu.eset.combo:Value() and gsoMode.isCombo() and gsoState.isAttacking then
          local enemyList = gsoObjects.enemyHeroes_spell
          local aaData = gsoMyHero.attackData
          for i = 1, #enemyList do
            local enemy = enemyList[i]
            if enemy.handle == aaData.target and gsoDistance(gsoMyHero.pos, enemy.pos) < gsoMyHero.range + gsoMyHero.boundingRadius + enemy.boundingRadius and gsoCastSpellTarget(HK_E, 800, gsoMyHero.pos, gsoMyHero) then
              return true
            end
          end
        end
        return false
      end
      --R SEMI MANUAL
      local function castSemiR()
        if gsoMeMenu.rset.semirnami.enabled:Value() then
          local rTargets = {}
          local enemyList = gsoObjects.enemyHeroes_spell
          for i = 1, #enemyList do
            local hero = enemyList[i]
            local heroName = hero.charName
            local isFromList = gsoMeMenu.rset.semirnami.useon[heroName] and gsoMeMenu.rset.semirnami.useon[heroName]:Value()
            local hpPercent = gsoMeMenu.rset.semirnami.semilow:Value() and gsoMeMenu.rset.semirnami.semip:Value() or 100
            local isLowHP = isFromList and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if isLowHP then
              rTargets[#rTargets+1] = hero
            end
          end
          local rrange = gsoMeMenu.rset.semirnami.rrange:Value()
          local rTarget = gsoGetTarget(rrange, rTargets, gsoMyHero.pos, true, false)
          if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget) then
            return true
          end
        end
        return false
      end
      --R AUTO IMMOBILE
      local function castRImmobile()
        if gsoMeMenu.rset.immobile:Value() then
          local allyList = gsoObjects.allyHeroes
          local enemyList = gsoObjects.enemyHeroes_spell
          for i = 1, #enemyList do
            local hero = enemyList[i]
            local heroPos = hero.pos
            local countAllies = 0
            if gsoDistance(heroPos, gsoMyHero.pos) < gsoMeMenu.rset.immodist:Value() then
              for j = 1, #allyList do
                local ally = allyList[j]
                if ally ~= myHero and gsoDistance(ally.pos, heroPos) < gsoMeMenu.rset.immoxallies:Value() then
                  countAllies = countAllies + 1
                end
              end
              if countAllies >= gsoMeMenu.rset.immoallies:Value() and gsoIsImmobile(hero, 0.5) and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, hero.pos) then
                return true
              end
            end
          end
        end
        return false
      end
      
      gsoOrbwalker:OnTick(function()
        
        local target = gsoObjects.comboTarget; gsoObjects.comboTarget = nil
        local isTarget = target ~= nil
        local canCast = isTarget == false and Game.Timer() > gsoTimers.lastAttackSend + gsoTimers.windUpTime + gsoExtra.maxLatency + 0.05 and gsoState.canMove == true
        
        --E
        if gsoIsReady(_E, { q = 300, w = 300, e = 1000, r = 550 }) and (castEAlly() or castECombo()) then
          gsoSpellTimers.le = GetTickCount()
          return
        end
        
        if canCast == true or ( gsoState.canMove == true and gsoState.canAttack == false ) then
          --W
          if gsoIsReady(_W, { q = 300, w = 1000, e = 0, r = 550 }) and (castWHeal() or castWCombo(target, isTarget)) then
            gsoSpellTimers.lw = GetTickCount()
            return
          end
          
          --R
          if gsoSpellCan.r and gsoIsReady(_R, { q = 300, w = 300, e = 0, r = 1000 }) and (castRImmobile() or castSemiR()) then
            gsoSpellTimers.lr = GetTickCount()
            gsoSpellCan.q = false
            return
          end
          
          --Q
          if gsoSpellCan.q and gsoIsReady(_Q, { q = 1000, w = 300, e = 0, r = 550 }) and (castQImmobile() or castQCombo(target, isTarget)) then
            gsoSpellTimers.lq = GetTickCount()
            gsoSpellCan.r = false
            return
          end
        end
        
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 250, w = 250, e = 0, r = 500 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 300, w = 300, e = 0, r = 550 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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
      gsoSpellDraw = { q = true, qr = 1250, r = true, rr = 1000 }
      gsoSpellData.q = { delay = 0.25, range = 1250, width = 60, speed = 1350, sType = "line", col = false, mCol = false, hCol = false, out = true }
      gsoOrbwalker:AttackSpeed(function()
        local wDiff = gsoGetTickCount() - gsoSpellTimers.lwk - gsoExtra.minLatency
        if wDiff > 3500 and wDiff < 4500 then
          return champInfo.asNoW
        end
        return gsoMyHero.attackSpeed
      end)
      gsoOrbwalker:OnMove(function(args)
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          local enemyList = gsoObjects.enemyHeroes_spell
          --W
          local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                canW = canW and isTarget and gsoGameTimer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.5 )
                canW = canW and gsoIsReadyFast(_W, { q = 250, w = 1000, e = 0, r = 0 })
          if canW and gsoCastSpell(HK_W) then
            champInfo.asNoW = myHero.attackSpeed
            gsoSpellTimers.lw = GetTickCount()
            gsoSpellCan.q = false
            gsoActions({ func = function() gsoExtra.resetAttack = true end, startTime = gsoGameTimer() + 0.05 })
            return false
          end
          --Q
          if not isTarget or afterAttack then
            local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                  canQ = canQ and gsoIsReady(_Q, { q = 1000, w = 0, e = 0, r = 0 }) and (not isTarget or gsoSpellCan.q)
            if canQ then
              local qTarget = target
              if not isTarget then qTarget = gsoGetTarget(1250, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false) end
              if qTarget and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qTarget) then
                gsoSpellTimers.lq = GetTickCount()
                return false
              end
            end
          end
        end
        return true
      end)
      
      gsoOrbwalker:OnTick(function()
        gsoObjects.comboTarget = nil
      end)
    
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 250, w = 0, e = 0, r = 0 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 350, w = 0, e = 0, r = 0 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
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
      
      --[[ set ap ]]
      gsoOrbwalker.IsAP()
      
      --[[ menu ]]
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
      
      --[[ draw ]]
      local function _teemoR()
        local rLvl = gsoMyHero:GetSpellData(_R).level
        if rLvl == 0 then rLvl = 1 end
        return 150 + ( 250 * rLvl )
      end
      gsoSpellDraw = { q = true, qr = 680, r = true, rf = function() return _teemoR() end }
      
      --[[ spell data ]]
      gsoSpellData.r = { delay = 0.25, range = 0, width = 200, speed = 1000, sType = "circular", col = false, mCol = false, hCol = false, out = false }
      
      --[[ on move ]]
      gsoOrbwalker:OnMove(function(args)
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          local enemyList = gsoObjects.enemyHeroes_spell
          if not isTarget or afterAttack then
            --Q
            local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                  canQ = canQ and gsoIsReady(_Q, { q = 1000, w = 0, e = 0, r = 750 }) and (not isTarget or gsoSpellCan.q)
            if canQ then
              local qTarget = target
              if not isTarget then qTarget = gsoGetTarget(680, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false) end
              if qTarget and gsoCastSpellTarget(HK_Q, 680, mePos, qTarget) then
                gsoSpellCan.r = false
                gsoSpellTimers.lq = gsoGetTickCount()
                return false
              end
            end
            --R
            local canR = ( isCombo and gsoMeMenu.rset.combo:Value() ) or ( isHarass and gsoMeMenu.rset.harass:Value() )
                  canR = canR and gsoIsReady(_R, { q = 350, w = 0, e = 0, r = 1000 }) and (not isTarget or gsoSpellCan.r)
            if canR then
              local rRange = 150 + ( 250 * gsoMyHero:GetSpellData(_R).level )
              gsoSpellData.r.range = rRange
              local onlyImmobile = gsoMeMenu.rset.immo:Value()
              local rTarget = nil
              if onlyImmobile then rTarget = gsoGetImmobileEnemy(mePos, enemyList, rRange) end
              if not rTarget and not onlyImmobile then
                local isTeemoTarget = isTarget and gsoDistance(mePos, target.pos) < rRange
                if isTeemoTarget then
                  rTarget = target
                else
                  rTarget = gsoGetTarget(rRange, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false)
                end
              end
              if rTarget and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, rTarget) then
                gsoSpellCan.q = false
                gsoSpellTimers.lr = gsoGetTickCount()
                return false
              end
            end
            --W
            local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                  canW = canW and gsoIsReadyFast(_W, { q = 350, w = 1000, e = 0, r = 350 })
            if canW then
              for i = 1, #enemyList do
                local hero = enemyList[i]
                if gsoDistance(mePos, hero.pos) < gsoMeMenu.wset.mindist:Value() and gsoCastSpell(HK_W) then
                  gsoSpellTimers.lw = GetTickCount()
                  return false
                end
              end
            end
          end
        end
        return true
      end)
      
      gsoOrbwalker:OnTick(function()
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 250, w = 0, e = 0, r = 250 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 350, w = 0, e = 0, r = 350 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Thresh = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Tristana = function()
      
      --[[ VARS ]]
      local champInfo = { asNoQ = 0, tristanaETar = nil }
      
      --[[ MENU ]]
      local gsoMeMenu = gsoMenu:MenuElement({name = "Tristana", id = "gsotristana", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/tristana.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
          gsoMeMenu.rset:MenuElement({id = "ks", name = "KS", value = true})
          gsoMeMenu.rset:MenuElement({id = "kse", name = "KS only E + R", value = false})
      
      --[[ DRAW ]]
      gsoSpellDraw = { w = true, wr = 900 }
      
      local function gsoTristEDmgAD(stacks)
        local elvl = gsoMyHero:GetSpellData(_E).level
        local meDmg = gsoMyHero.totalDamage
        local meAP = gsoMyHero.ap
        local stacksDmg = 0
        local baseDmg = 50 + ( 10 * elvl ) + ( ( 0.4 + ( 0.1 * elvl ) ) * meDmg ) + ( 0.5 * meAP )
        if stacks > 0 then
          local stackDmg = 15 + ( 3 * elvl ) + ( ( 0.12 + ( 0.03 * elvl ) ) * meDmg ) + ( 0.15 * meAP )
          stacksDmg = stacks * stackDmg
        end
        return baseDmg + stacksDmg
      end
      
      local function gsoTristEDmgAP()
        return 
      end
      
      --[[ ON MOVE ]]
      gsoOrbwalker:OnMove(function()
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          --local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local beforeAttack = gsoGameTimer() > gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.5 )
          local mePos = gsoMyHero.pos
          --RKS
          local enemyList = gsoObjects.enemyHeroes_spell
          local canR = gsoMeMenu.rset.ks:Value() and isTarget and gsoIsReady(_R, { q = 0, w = 350, e = 250, r = 1000 })
          if canR then
            local meRange = gsoMyHero.range + gsoMyHero.boundingRadius
            for i = 1, #enemyList do
              local unit = enemyList[i]
              local rDmg = gsoCalcDmg(unit, { dmgAP = (200 + ( 100 * gsoMyHero:GetSpellData(_R).level ) + gsoMyHero.ap), dmgType = "ap" } )
              local checkEDmg = champInfo.tristanaETar and champInfo.tristanaETar.unit.networkID == unit.networkID
              local eDmg = 0
              if checkEDmg then
                eDmg = gsoCalcDmg(unit, { dmgAP = 25 + ( 25 * gsoMyHero:GetSpellData(_E).level ) + ( 0.25 * gsoMyHero.ap ), dmgAD = gsoTristEDmgAD(champInfo.tristanaETar.stacks), dmgType = "mixed" }) or 0
              end
              local unitKillable = eDmg + rDmg > unit.health + (unit.hpRegen * 2)
              if unitKillable and gsoCastSpellTarget(HK_R, gsoMyHero.range + gsoMyHero.boundingRadius + target.boundingRadius - 35, gsoMyHero.pos, target) then
                gsoSpellTimers.lr = gsoGetTickCount()
                gsoSpellCan.botrk = false
                return false
              end
            end
          end
          --Q
          local canQ = (isCombo and gsoMeMenu.qset.combo:Value()) or (isHarass and gsoMeMenu.qset.harass:Value())
                canQ = canQ and isTarget and beforeAttack and gsoIsReadyFast(_Q,{ q = 1000, w = 750, e = 0, r = 0 })
          if canQ and gsoCastSpell(HK_Q)then
            champInfo.asNoQ = myHero.attackSpeed
            gsoSpellTimers.lq = gsoGetTickCount()
            gsoSpellCan.botrk = false
            return false
          end
          --E
          local canE = (isCombo and gsoMeMenu.eset.combo:Value()) or (isHarass and gsoMeMenu.eset.harass:Value())
                canE = canE and isTarget and beforeAttack and gsoIsReady(_E, { q = 0, w = 350, e = 1000, r = 250 })
          if canE then
            local targetPos = target.pos
            local targetID = target.networkID
            if gsoCastSpellTarget(HK_E, gsoMyHero.range + gsoMyHero.boundingRadius + target.boundingRadius - 35, gsoMyHero.pos, target) then
              gsoSpellTimers.le = gsoGetTickCount()
              champInfo.tristanaETar = { id = targetID, stacks = 1, unit = target }
              gsoSpellCan.botrk = false
              return false
            end
          end
        end
        return true
      end)
      
      --[[ ON TICK ]]
      gsoOrbwalker:OnTick(function()
        local enemyList = gsoObjects.enemyHeroes_spell
        for i = 1, #enemyList do
          local hero = enemyList[i]
          for i = 0, hero.buffCount do
            local buff = hero:GetBuff(i)
            if buff and buff.count > 0 and buff.duration > 1 and buff.name:lower() == "tristanaechargesound" and champInfo.tristanaETar and not champInfo.tristanaETar.endTime then
              champInfo.tristanaETar.endTime = gsoGameTimer() + buff.duration - gsoExtra.minLatency
            end
          end
        end
        if champInfo.tristanaETar and champInfo.tristanaETar.endTime and gsoGameTimer() > champInfo.tristanaETar.endTime then
          champInfo.tristanaETar = nil
        end
        local getTick = gsoGetTickCount()
        if getTick - gsoSpellTimers.lw > 1000 and Game.CanUseSpell(_W) == 0 then
          for k,v in pairs(gsoDelayedSpell) do
            if k == 1 then
              if not gsoState.isChangingCursorPos then
                v[1]()
                gsoSetCursor({ endTime = GetTickCount() + 50, action = function() return end, active = true }, nil)
                gsoSpellTimers.lw = gsoGetTickCount()
                gsoDelayedSpell[k] = nil
                break
              end
              if GetTickCount() - v[2] > 125 then
                gsoDelayedSpell[k] = nil
              end
              break
            end
          end
        end
        gsoObjects.comboTarget = nil
      end)
      
      --[[ ATTACK SPEED ]]
      gsoOrbwalker:AttackSpeed(function()
        local qDiff = gsoGetTickCount() - gsoSpellTimers.lqk
        if qDiff > 7000 and qDiff < 8000 then
          return champInfo.asNoQ
        end
        return gsoMyHero.attackSpeed
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 0, w = 500, e = 100, r = 100 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 0, w = 800, e = 200, r = 200 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
      
      
      
      
      
      
      
      
      
      
      
      

      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
    
    __Trundle = function() end,
    __Tryndamere = function() end,
    __TwistedFate = function() end,
    
    
    
    
    
    
    
    
    
    __Twitch = function()
      
      --[[ VARS ]]
      local champInfo = { hasQBuff = false, QEndTime = 0, hasQASBuff = false, QASEndTime = 0, lastASCheck = 0, asNoQ = myHero.attackSpeed, windUpNoQ = myHero.attackData.windUpTime, eBuffs = {}, boolRecall = true }
      
      --[[ MENU ]]
      local gsoMeMenu = gsoMenu:MenuElement({name = "Twitch", id = "gsotwitch", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/twitch.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "recallkey", name = "Invisible Recall Key", key = string.byte("T"), value = false, toggle = true})
          gsoMeMenu.qset.recallkey:Value(false)
          gsoMeMenu.qset:MenuElement({id = "note1", name = "Note: Key should be diffrent than recall key", type = SPACE})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "stopq", name = "Stop if Q invisible", value = true})
          gsoMeMenu.wset:MenuElement({id = "stopwult", name = "Stop if R", value = false})
          gsoMeMenu.wset:MenuElement({id = "combo", name = "Use W Combo", value = true})
          gsoMeMenu.wset:MenuElement({id = "harass", name = "Use W Harass", value = false})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Use E Combo", value = true})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Use E Harass", value = false})
          gsoMeMenu.eset:MenuElement({id = "stacks", name = "X stacks", value = 6, min = 1, max = 6, step = 1 })
          gsoMeMenu.eset:MenuElement({id = "enemies", name = "X enemies", value = 1, min = 1, max = 5, step = 1 })
      
      --[[ DRAW ]]
      gsoSpellDraw = { w = true, wr = 950, e = true, er = 1200, r = true, rf = function() return gsoMyHero.range + 300 + ( gsoMyHero.boundingRadius * 2 ) end }
      Callback.Add('Draw', function()
        local mePos = myHero.pos
        if GetTickCount() < gsoSpellTimers.lqk + 16000 then
          local mePos2D = mePos:To2D()
          local posX = mePos2D.x - 50
          local posY = mePos2D.y
          local num1 = math.floor(1350-(gsoGetTickCount()-gsoSpellTimers.lqk))
          local timerEnabled = gsoMenu.gsodraw.texts1.enabletime:Value()
          local timerColor = gsoMenu.gsodraw.texts1.colortime:Value()
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
          elseif champInfo.hasQBuff then
            local num2 = math.floor(1000*(champInfo.QEndTime-gsoGameTimer()))
            if num2 > 1 then
              if gsoMenu.gsodraw.circle1.invenable:Value() then
                Draw.Circle(mePos, 500, 1, gsoMenu.gsodraw.circle1.invcolor:Value())
              end
              if gsoMenu.gsodraw.circle1.notenable:Value() then
                Draw.Circle(mePos, 800, 1, gsoMenu.gsodraw.circle1.notcolor:Value())
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
      end)
      
      --[[ SPELL DATA ]]
      gsoSpellData.w = { delay = 0.25, range = 950, width = 275, speed = 1400, sType = "circular", col = false, hCol = false, mCol = false, out = false }
      
      --[[ ATTACK SPEED ]]
      gsoOrbwalker:AttackSpeed(function()
        local num = gsoGameTimer() - champInfo.QASEndTime + gsoExtra.maxLatency
        if num > -champInfo.windUpNoQ and num < 2 then
          return champInfo.asNoQ
        end
        return gsoMyHero.attackSpeed
      end)
      
      --[[ ON MOVE ]]
      gsoOrbwalker:OnMove(function(args)
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local stopifQBuff = false
          local num = 1150 - (GetTickCount() - (gsoSpellTimers.lqk + (gsoExtra.maxLatency*1000)))
          if num > -50 and num < 350 then
            stopifQBuff = true
          end
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = gsoGameTimer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          local enemyList = gsoObjects.enemyHeroes_spell
          if not isTarget or afterAttack then
            --W:
            local stopWIfR = gsoMeMenu.wset.stopwult:Value() and gsoGetTickCount() < gsoSpellTimers.lrk + 5450
            local stopWIfQ = gsoMeMenu.wset.stopq:Value() and champInfo.hasQBuff
            local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                  canW = canW and not stopWIfR and not stopWIfQ and not stopifQBuff and (not isTarget or gsoSpellCan.w) and gsoIsReady(_W, { q = 0, w = 1000, e = 250, r = 0 })
            if canW then
              local wTarget = target
              if not isTarget then wTarget = gsoGetTarget(950, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false) end
              if wTarget and gsoCastSpellSkillShot(HK_W, gsoMyHero.pos, wTarget) then
                gsoSpellTimers.lw = GetTickCount()
                gsoSpellCan.e = false
                return false
              end
            end
            --E
            local canE = (isCombo and gsoMeMenu.eset.combo:Value()) or (isHarass and gsoMeMenu.eset.harass:Value())
                  canE = canE and not stopifQBuff and (not isTarget or gsoSpellCan.e) and gsoIsReady(_E, { q = 0, w = 250, e = 2500, r = 0 })
            if canE then
              local xStacks   = gsoMeMenu.eset.stacks:Value()
              local xEnemies  = gsoMeMenu.eset.enemies:Value()
              local countE    = 0
              for i = 1, #enemyList do
                local hero = enemyList[i]
                if hero and gsoDistance(mePos, hero.pos) < 1200 then
                  local nID = hero.networkID
                  if champInfo.eBuffs[nID] and champInfo.eBuffs[nID].count >= xStacks then
                    countE = countE + 1
                  end
                end
              end
              if countE >= xEnemies and gsoCastSpell(HK_E) then
                gsoSpellTimers.le = GetTickCount()
                gsoSpellCan.w = false
                return false
              end
            end
          end
        end
        return true
      end)
      
      --[[ ON TICK ]]
      gsoOrbwalker:OnTick(function()
        --q buff best orbwalker dps
        if gsoGetTickCount() - gsoSpellTimers.lqk < 500 and gsoGetTickCount() > champInfo.lastASCheck + 1000 then
          champInfo.asNoQ = gsoMyHero.attackSpeed
          champInfo.windUpNoQ = gsoTimers.windUpTime
          champInfo.lastASCheck = gsoGetTickCount()
        end
        --qrecall
        local boolRecall = gsoMeMenu.qset.recallkey:Value()
        if boolRecall == champInfo.boolRecall then
          Control.KeyDown(HK_Q)
          Control.KeyUp(HK_Q)
          Control.KeyDown(string.byte("B"))
          Control.KeyUp(string.byte("B"))
          champInfo.boolRecall = not boolRecall
        end
        --qbuff
        local qDuration = gsoBuffDuration(myHero, "globalcamouflage")--twitchhideinshadows
        champInfo.hasQBuff = qDuration > 0
        champInfo.QEndTime = qDuration > 0 and gsoGameTimer() + qDuration or champInfo.QEndTime
        --qasbuff
        local qasDuration = gsoBuffDuration(myHero, "twitchhideinshadowsbuff")
        champInfo.hasQASBuff = qasDuration > 0
        champInfo.QASEndTime = qasDuration > 0 and gsoGameTimer() + qasDuration or champInfo.QASEndTime
        local enemyList = gsoObjects.enemyHeroes_spell
        --handle e buffs
        for i = 1, #enemyList do
          local hero  = enemyList[i]
          local nID   = hero.networkID
          if not champInfo.eBuffs[nID] then
            champInfo.eBuffs[nID] = { count = 0, durT = 0 }
          end
          if not hero.dead then
            local hasB = false
            local cB = champInfo.eBuffs[nID].count
            local dB = champInfo.eBuffs[nID].durT
            for i = 0, hero.buffCount do
              local buff = hero:GetBuff(i)
              if buff and buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
                hasB = true
                if cB < 6 and buff.duration > dB then
                  champInfo.eBuffs[nID].count = cB + 1
                  champInfo.eBuffs[nID].durT = buff.duration
                else
                  champInfo.eBuffs[nID].durT = buff.duration
                end
                break
              end
            end
            if not hasB then
              champInfo.eBuffs[nID].count = 0
              champInfo.eBuffs[nID].durT = 0
            end
          end
        end
        --EKS
        local canE = gsoIsReadyFast(_E, { q = 0, w = 350, e = 2500, r = 0 })
        if canE then
          for i = 1, #enemyList do
            local hero  = enemyList[i]
            local nID   = hero and hero.networkID or nil
            if nID and champInfo.eBuffs[nID] and champInfo.eBuffs[nID].count > 0 and gsoDistance(myHero.pos, hero.pos) < 1200 then
              local elvl = myHero:GetSpellData(_E).level
              local basedmg = 10 + ( elvl * 10 )
              local cstacks = champInfo.eBuffs[nID].count
              local perstack = ( 10 + (5*elvl) ) * cstacks
              local bonusAD = myHero.bonusDamage * 0.25 * cstacks
              local bonusAP = myHero.ap * 0.2 * cstacks
              local edmg = basedmg + perstack + bonusAD + bonusAP
              if gsoCalcDmg(hero, { dmgType = "ad", dmgAD = edmg }) >= hero.health + (1.5*hero.hpRegen) and gsoCastSpell(HK_E) then
                gsoSpellTimers.le = gsoGetTickCount()
                gsoSpellCan.w = false
              end
            end
          end
        end
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 0, w = 200, e = 200, r = 0 }) end)
      gsoOrbwalker:CanAttack(function()
        local num = 1150 - (gsoGetTickCount() - (gsoSpellTimers.lqk + (gsoExtra.maxLatency*1000)))
        if num < (gsoTimers.windUpTime*1000)+50 and num > - 50 then
          return false
        end
        return gsoCheckTimers({ q = 0, w = 350, e = 350, r = 0 })
      end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    __Udyr = function() end,
    __Urgot = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Varus = function()
      --[[ vars ]]
      local champInfo = { isTarget = false, hasQBuff = false, lastQ2 = 0, enabled = true, qEndTime = 0, asNoQ = myHero.attackSpeed, oldWindUp = myHero.attackData.windUpTime }
      local gsoWStacks = {}
      
      --[[ menu ]]
      local gsoMeMenu = gsoMenu:MenuElement({id = "gsovarus", name = "Varus", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gsovarussf3f.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
          gsoMeMenu.qset:MenuElement({id = "onlystacks", name = "Only 3 stacks", value = false})
          gsoMeMenu.qset:MenuElement({id = "qload", name = "Minimum Q Loading Time X[ms]", value = 1000, min = 0, max = 2000, step = 100})
          gsoMeMenu.qset:MenuElement({id = "qloadaa", name = "Minimum Q Loading Time X[ms] in attack range", value = 0, min = 0, max = 2000, step = 100})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
          gsoMeMenu.eset:MenuElement({id = "onlystacks", name = "Only 3 stacks", value = false})
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
          gsoMeMenu.rset:MenuElement({id = "combo", name = "Use R Combo", value = true})
          gsoMeMenu.rset:MenuElement({id = "harass", name = "Use R Harass", value = false})
          gsoMeMenu.rset:MenuElement({id = "rci", name = "Use R if enemy isImmobile", value = true})
          gsoMeMenu.rset:MenuElement({id = "rcd", name = "Use R if enemy distance < X", value = true})
          gsoMeMenu.rset:MenuElement({id = "rdist", name = "use R if enemy distance < X", value = 500, min = 250, max = 1000, step = 50})
      
      --[[ draw ]]
      gsoSpellDraw = { q = true, qr = 1650, e = true, er = 950, r = true, rr = 1075 }
      
      --[[ spell data ]]
      gsoSpellData.q = { delay = 0.25, range = 1650, width = 70, speed = 1900, sType = "line", col = false, hCol = false, mCol = false, out = true }
      gsoSpellData.e = { delay = 0.5, range = 925, width = 235, speed = 1500, sType = "circular", col = false, hCol = false, mCol = false, out = false }
      gsoSpellData.r = { delay = 0.25, range = 1075, width = 120, speed = 1950, sType = "line", col = false, hCol = false, mCol = false, out = false }
      
      --[[ on move ]]
      gsoOrbwalker:OnMove(function()
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          local enemyList = gsoObjects.enemyHeroes_spell
          if not isTarget or afterAttack then
            --R
            local canR = ( isCombo and gsoMeMenu.rset.combo:Value() ) or ( isHarass and gsoMeMenu.rset.harass:Value() )
                  canR = canR and gsoIsReady(_R, { q = 250, w = 0, e = 350, r = 1000 })
            if canR and champInfo.enabled then
              if gsoMeMenu.rset.rcd:Value() then
                local t = gsoGetClosestEnemy(mePos, gsoObjects.enemyHeroes_spell, gsoMeMenu.rset.rdist:Value())
                if t and gsoCastSpellSkillShot(HK_R, mePos, t) then
                  gsoSpellTimers.lr = gsoGetTickCount()
                  gsoSpellCan.q = false
                  gsoSpellCan.e = false
                  gsoSpellCan.botrk = false
                  return false
                end
              end
              if gsoMeMenu.rset.rci:Value() then
                local t = gsoGetImmobileEnemy(mePos, gsoObjects.enemyHeroes_spell, 900)
                if t and gsoCastSpellSkillShot(HK_R, mePos, t.pos) then
                  gsoSpellTimers.lr = gsoGetTickCount()
                  gsoSpellCan.q = false
                  gsoSpellCan.e = false
                  gsoSpellCan.botrk = false
                  return false
                end
              end
            end
            --Q
            local onlyStacksQ = gsoMeMenu.qset.onlystacks:Value()
            local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                  canQ = canQ and (not isTarget or gsoSpellCan.q) and gsoIsReady(_Q, { q = 1500, w = 0, e = 1000, r = 250 })
            if canQ and champInfo.enabled and gsoGetTickCount() > champInfo.lastQ2 + 1500 then
              for i = 1, #enemyList do
                local hero  = enemyList[i]
                local hasStacks = gsoBuffCount(hero, "varuswdebuff") == 3
                local canQOnT = onlyStacksQ == false or hasStacks == true
                      canQOnT = canQOnT and gsoDistance(gsoMyHero.pos, hero.pos) < 1400
                if (isTarget == false or hasStacks == true or gsoMyHero:GetSpellData(_W).level == 0) and canQOnT == true then
                  champInfo.isTarget = isTarget
                  Control.KeyDown(HK_Q)
                  gsoSpellTimers.lq = GetTickCount() + Game.Latency()
                  gsoSpellCan.botrk = false
                  gsoState.enabledAttack = false
                  champInfo.enabled = false
                  gsoSpellCan.e = false
                  return false
                end
              end
            end
            --E
            local onlyStacksE = gsoMeMenu.eset.onlystacks:Value()
            local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
                  canE = canE and (not isTarget or gsoSpellCan.e) and gsoIsReady(_E, { q = 250, w = 0, e = 1000, r = 250 })
            if canE and champInfo.enabled then
              local eTargets = {}
              for i = 1, #enemyList do
                local hero  = enemyList[i]
                local hasStacks = gsoBuffCount(hero, "varuswdebuff") == 3
                local canEOnT = onlyStacksE == false or hasStacks == true
                      canEOnT = canEOnT and gsoDistance(gsoMyHero.pos, hero.pos) < 925
                if (isTarget == false or hasStacks == true or gsoMyHero:GetSpellData(_W).level == 0) and canEOnT == true then
                  eTargets[#eTargets+1] = hero
                end
              end
              local eTarget = gsoGetTarget(925, eTargets, gsoMyHero.pos, false, false)
              if eTarget and gsoCastSpellSkillShot(HK_E, mePos, eTarget) then
                gsoSpellTimers.le = GetTickCount()
                gsoSpellCan.botrk = false
                gsoSpellCan.q = false
                return false
              end
            end
          end
        end
        return true
      end)
      
      gsoOrbwalker:OnTick(function()
        local enemyList = gsoObjects.enemyHeroes_spell
        --Q
        local canQ = champInfo.enabled == false
        if canQ and gsoGetTickCount() > champInfo.lastQ2 + 1000 then
          local qTargets = {}
          for i = 1, #enemyList do
            local hero  = enemyList[i]
            if (not champInfo.isTarget or gsoBuffCount(hero, "varuswdebuff") == 3 or gsoMyHero:GetSpellData(_W).level == 0) and gsoDistance(myHero.pos, hero.pos) < 1650 then
              qTargets[#qTargets+1] = hero
            end
          end
          local qTimer = gsoGetTickCount() - gsoSpellTimers.lq
                qTimer = qTimer * 0.001
          local qExtraRange = qTimer < 2 and qTimer * 0.5 * 700 or 700
          local qInAA = gsoCountEnemyHeroesInRange(gsoMyHero.pos, gsoMyHero.range + gsoMyHero.boundingRadius, true) > 0 and qTimer > gsoMeMenu.qset.qloadaa:Value() * 0.001 
          if qTimer > gsoMeMenu.qset.qload:Value() * 0.001 or qInAA == true then
            local qRange = 925 + qExtraRange
            local qTarget1 = gsoGetTarget(qRange, qTargets, gsoMyHero.pos, false, false)
            if qTarget1 then
              local qPred1 = qTarget1:GetPrediction(1900,0.25+gsoExtra.maxLatency)
              if qPred1 and gsoDistance(qPred1, qTarget1.pos) < 500 and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qPred1) then
                champInfo.enabled = true
                gsoState.enabledAttack = true
                lastQ2 = GetTickCount()
                gsoSpellCan.botrk = false
                gsoSpellCan.e = false
                gsoState.enabledMove = false
              else
                local qTarget2 = gsoGetTarget(1550, qTargets, gsoMyHero.pos, false, false)
                local qPred2 = qTarget2:GetPrediction(1900,0.25+gsoExtra.maxLatency)
                if qPred2 and gsoDistance(qPred1, qTarget2.pos) < 500 and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qPred2) then
                  champInfo.enabled = true
                  gsoState.enabledAttack = true
                  lastQ2 = GetTickCount()
                  gsoSpellCan.botrk = false
                  gsoSpellCan.e = false
                  gsoState.enabledMove = false
                end
              end
            end
          end
        end
        champInfo.hasQBuff = gsoHasBuff(gsoMyHero, "varusq")
        if canQ and gsoGetTickCount() > gsoSpellTimers.lq + 500 and not champInfo.hasQBuff then
          champInfo.enabled = true
          gsoState.enabledAttack = true
          lastQ2 = GetTickCount()
          gsoSpellCan.botrk = false
          gsoSpellCan.e = false
        end
        if not gsoState.enabledMove and not canQ and GetTickCount() > lastQ2 + 100 then
          gsoState.enabledMove = true
        end
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 150, w = 0, e = 150, r = 150 }) end)
      gsoOrbwalker:CanAttack(function() return champInfo.hasQBuff == false and gsoCheckTimers({ q = 250, w = 0, e = 250, r = 250 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Vayne = function()
      
      require "MapPositionGOS"
      
      --[[ MENU ]]
      local gsoMeMenu = gsoMenu:MenuElement({name = "Vayne", id = "gsovayne", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/vayne.png" })
          gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
              gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
              gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
          gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
              gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = true})
              gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
      
      --[[ SPELL DRAW ]]
      gsoSpellDraw = { q = true, qr = 300, e = true, er = 550 }
      
      --[[ ON MOVE ]]
      gsoOrbwalker:OnMove(function(args)
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          local enemyList = gsoObjects.enemyHeroes_spell
          --E
          if isTarget and afterAttack then
            local canE = ( isCombo and gsoMeMenu.eset.combo:Value() ) or ( isHarass and gsoMeMenu.eset.harass:Value() )
                  canE = canE and gsoSpellCan.e and gsoIsReady(_E, { q = 400, w = 0, e = 1000, r = 0 })
            if canE then
              local ePred = target:GetPrediction(2000,0.15)
              local tPos = target.pos
              local canEonTarget = ePred and gsoDistance(ePred, tPos) < 500 and gsoCheckWall(mePos, ePred, 475) and gsoCheckWall(mePos, tPos, 475)
              if canEonTarget and gsoCastSpellTarget(HK_E, 500, mePos, target) then
                gsoSpellCan.q = false
                gsoSpellTimers.le = gsoGetTickCount()
                return false
              end
            end
          end
          --Q
          if not isTarget or afterAttack then
            local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
                  canQ = canQ and (not isTarget or gsoSpellCan.q) and gsoIsReadyFast(_Q, { q = 1000, w = 0, e = 750, r = 0 })
            if canQ then
              local meRange = myHero.range + myHero.boundingRadius
              for i = 1, #enemyList do
                local hero = enemyList[i]
                local heroPos = hero.pos
                local distToMouse = gsoDistance(mePos, mousePos)
                local distToHero = gsoDistance(mePos, heroPos)
                local distToEndPos = gsoDistance(mePos, hero.pathing.endPos)
                local extRange
                if distToEndPos > distToHero then
                  extRange = distToMouse > 200 and 200 or distToMouse
                else
                  extRange = distToMouse > 300 and 300 or distToMouse
                end
                local extPos = mePos + (mousePos-mePos):Normalized() * extRange
                local distEnemyToExt = gsoDistance(extPos, heroPos)
                if distEnemyToExt < meRange + hero.boundingRadius and gsoCastSpell(HK_Q) then
                  gsoSpellCan.e = false
                  gsoSpellTimers.lq = gsoGetTickCount()
                  gsoExtra.resetAttack = true
                  return false
                end
              end
            end
          end
        end
        return true
      end)
      
      gsoOrbwalker:OnTick(function()
        gsoObjects.comboTarget = nil
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 200, w = 0, e = 400, r = 0 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 300, w = 0, e = 500, r = 0 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,    

            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
    __Veigar = function() end,
    __Velkoz = function() end,
    __Vi = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Viktor = function()
      --[[ set ap ]]
      gsoOrbwalker.IsAP()
      
      --[[ menu ]]
      local gsoMeMenu = gsoMenu:MenuElement({name = "Viktor", id = "gsoviktor", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/viktorsDd3.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
          gsoMeMenu.wset:MenuElement({id = "immobile", name = "Auto Immobile", value = true})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "combo", name = "Combo", value = false})
          gsoMeMenu.eset:MenuElement({id = "harass", name = "Harass", value = false})
          gsoMeMenu.wset:MenuElement({id = "immobile", name = "Auto Immobile", value = true})
        gsoMeMenu:MenuElement({name = "R settings", id = "rset", type = MENU })
          gsoMeMenu.rset:MenuElement({id = "immobile", name = "Auto Immobile", value = true})
          gsoMeMenu.rset:MenuElement({id = "xhealthmin", name = "Minimum Enemy Health Percent", value = 10, min = 0, max = 100, step = 1})
          gsoMeMenu.rset:MenuElement({id = "xhealthmax", name = "Maximum Enemy Health Percent", value = 50, min = 0, max = 100, step = 1})
      
      --[[ draw ]]
      gsoSpellDraw = { q = true, qr = 600 + 2 * gsoMyHero.boundingRadius, w = true, wr = 700, e = true, er = 550 }
      
      --[[ spell data ]]
      gsoSpellData.q = { delay = 0.25, range = 600 + 2 * gsoMyHero.boundingRadius }
      --W radius = 325, diameter = 650
      gsoSpellData.w = { delay = 0.25, range = 700, width = 325 }
      --width = 250 + enemyBoundingRadius, full width = 500 + 2 * enemyBoundingRadius
      gsoSpellData.e = { delay = 0, range = 550 }
      gsoSpellData.r = { delay = 0.5, range = 2750, width = 250, speed = 850, sType = "line", col = false, mCol = false, hCol = false, out = true }
      
      --Q COMBO
      local function castQCombo()
        local canQCombo = gsoMeMenu.qset.combo:Value() == true and gsoMode.isCombo() == true
        local canQHarass = gsoMeMenu.qset.harass:Value() == true and gsoMode.isHarass() == true
        if canQCombo or canQHarass then
          local qTarget = gsoGetTarget(600+gsoMyHero.boundingRadius, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, true)
          if qTarget and gsoCastSpellTarget(HK_Q, 600+gsoMyHero.boundingRadius, gsoMyHero.pos, qTarget, true) then
            return true
          end
        end
        return false
      end
      --W COMBO
      local function castWCombo()
        local canQCombo = gsoMeMenu.wset.combo:Value() == true and gsoMode.isCombo() == true
        local canQHarass = gsoMeMenu.wset.harass:Value() == true and gsoMode.isHarass() == true
        if canQCombo or canQHarass then
          local wTarget = gsoGetTarget(700, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, true, false)
          if wTarget and gsoCastSpellSkillShot(HK_W, gsoMyHero.pos, wTarget) then
            return true
          end
        end
        return false
      end
      --W AUTO IMMOBILE
      local function castWImmobile()
        if gsoMeMenu.wset.immobile:Value() then
          local mePos = gsoMyHero.pos
          local enemyList = gsoObjects.enemyHeroes_immortal
          for i = 1, #enemyList do
            local enemy = enemyList[i]
            if gsoDistance(enemy.pos, mePos) < 700 and gsoIsImmobile(enemy, 0.5) and gsoCastSpellSkillShot(HK_W, gsoMyHero.pos, enemy.pos) then
              return true
            end
          end
        end
        return false
      end
      --E COMBO
      local function castECombo()
        if gsoMeMenu.eset.combo:Value() and gsoMode.isCombo() and gsoState.isAttacking then
          local enemyList = gsoObjects.enemyHeroes_spell
          local aaData = gsoMyHero.attackData
          for i = 1, #enemyList do
            local enemy = enemyList[i]
            if enemy.handle == aaData.target and gsoDistance(gsoMyHero.pos, enemy.pos) < gsoMyHero.range + gsoMyHero.boundingRadius + enemy.boundingRadius and gsoCastSpellTarget(HK_E, 800, gsoMyHero.pos, gsoMyHero) then
              return true
            end
          end
        end
        return false
      end
      --R AUTO IMMOBILE
      local function castRImmobile()
        if gsoMeMenu.rset.immobile:Value() then
          local enemyList = gsoObjects.enemyHeroes_spell
          for i = 1, #enemyList do
            local hero = enemyList[i]
            local heroPos = hero.pos
            local hpPercent = ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if hpPercent > gsoMeMenu.rset.xhealthmin:Value() and hpPercent < gsoMeMenu.rset.xhealthmax:Value() and gsoDistance(heroPos, gsoMyHero.pos) < 700 and gsoIsImmobile(hero, 0.5) and gsoCastSpellSkillShot(HK_R, gsoMyHero.pos, hero.pos) then
              return true
            end
          end
        end
        return false
      end
      
      gsoOrbwalker:OnTick(function()
        
        local target = gsoObjects.comboTarget; gsoObjects.comboTarget = nil
        local isTarget = target ~= nil
        local canCast = isTarget == false and Game.Timer() > gsoTimers.lastAttackSend + gsoTimers.windUpTime + gsoExtra.maxLatency + 0.05 and gsoState.canMove == true
        
        --E
        if gsoIsReady(_E, { q = 300, w = 300, e = 1000, r = 550 }) and (castEAlly() or castECombo()) then
          gsoSpellTimers.le = GetTickCount()
          return
        end
        
        if canCast == true or ( gsoState.canMove == true and gsoState.canAttack == false ) then
          --W
          if gsoSpellCan.w and gsoIsReady(_W, { q = 300, w = 1000, e = 0, r = 300 }) and (castWImmobile() or castWCombo() or castWHarass()) then
            gsoSpellTimers.lw = GetTickCount()
            return
          end
          
          --R
          if gsoSpellCan.r and gsoIsReady(_R, { q = 300, w = 300, e = 0, r = 1000 }) and castRImmobile() then
            gsoSpellTimers.lr = GetTickCount()
            return
          end
          
          --Q
          if gsoSpellCan.q and gsoIsReady(_Q, { q = 1000, w = 300, e = 0, r = 300 }) and (castQCombo() or castQHarass()) then
            gsoSpellTimers.lq = GetTickCount()
            return
          end
        end
        
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 250, w = 250, e = 0, r = 250 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 300, w = 300, e = 0, r = 300 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Vladimir = function() end,
    __Volibear = function() end,
    __Warwick = function() end,
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    __Xayah = function()
      
      --[[ vars ]]
      local champInfo = { wEndTime = 0, windUpOld = 0, asNoW = 0 }
      local xayahEPas = {}
      
      --[[ menu ]]
      local gsoMeMenu = gsoMenu:MenuElement({id = "gsoxayah", name = "Xayah", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gsoxayahysd2.png" })
        gsoMeMenu:MenuElement({name = "Q settings", id = "qset", type = MENU })
          gsoMeMenu.qset:MenuElement({id = "outaa", name = "Out of attack range", value = false})
          gsoMeMenu.qset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "W settings", id = "wset", type = MENU })
          gsoMeMenu.wset:MenuElement({id = "wonaa", name = "On Attack", value = false})
          gsoMeMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
          gsoMeMenu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoMeMenu:MenuElement({name = "E settings", id = "eset", type = MENU })
          gsoMeMenu.eset:MenuElement({id = "eroot", name = "Auto Root", value = true})
          gsoMeMenu.eset:MenuElement({id = "erootx", name = "X Enemies", value = 1, min = 1, max = 5})
          gsoMeMenu.eset:MenuElement({name = "Draw", id = "edraw", type = MENU })
            gsoMeMenu.eset.edraw:MenuElement({id = "enabled", name = "Enabled", value = true})
            gsoMeMenu.eset.edraw:MenuElement({id = "ecolor", name = "Color", color = Draw.Color(255, 144, 81, 160)})
            gsoMeMenu.eset.edraw:MenuElement({id = "ewidth", name = "Width", value = 1, min = 1, max = 10})
      
      --[[ draw data ]]
      gsoSpellDraw = { q = true, qr = 1100 }
      
      --[[ spell data ]]
      gsoSpellData.q = { delay = 0.15, range = 1100, width = 45, speed = 2075, sType = "line", col = false, hCol = false, mCol = false, out = true }
      gsoSpellData.e = { delay = 0, range = 2000, width = 45, speed = 5700, sType = "line", col = false, hCol = false, mCol = false, out = false }
      
      local function gsoUseE()
        --E
        if gsoMeMenu.eset.eroot:Value() and gsoIsReadyFast(_E, { q = 350, w = 0, e = 1000, r = 1000 }) then
          local enemyList = gsoObjects.enemyHeroes_spell
          local xEnemies = 0
          local mePos1 = gsoMyHero.pos
          local mePos2 = gsoExtended(mePos1, mePos1, gsoExtra.lastMovePos, gsoMyHero.ms * gsoExtra.maxLatency)
          for i = 1, #enemyList do
            local enemy = enemyList[i]
            local enemyPos1 = enemy.pos
            local enemyPos2 = enemy:GetPrediction(enemy.ms,0.1)
            local enemyBB = enemy.boundingRadius*0.75
            local xFeathers = 0
            local eWidth = 45 + enemyBB
            for k,v in pairs(xayahEPas) do
              if v and v.active and v.pos and v.pos.x then
                local vPos = v.pos
                local point1, onLineSegment1 = gsoClosestPointOnLineSegment(enemyPos1, mePos1, vPos)
                local point2, onLineSegment2 = gsoClosestPointOnLineSegment(enemyPos1, mePos2, vPos)
                local isHitable = true
                if onLineSegment1 and gsoDistance(point1, enemyPos1) > eWidth then
                  isHitable = false
                end
                if isHitable and not onLineSegment1 and gsoDistance(point1, enemyPos1) > enemyBB then
                  isHitable = false
                end
                if isHitable and onLineSegment2 and gsoDistance(point2, enemyPos1) > eWidth then
                  isHitable = false
                end
                if isHitable and not onLineSegment2 and gsoDistance(point2, enemyPos1) > enemyBB then
                  isHitable = false
                end
                if enemyPos2 and gsoDistance(enemyPos2, enemyPos1) < 500 then
                  local point3, onLineSegment3 = gsoClosestPointOnLineSegment(enemyPos2, mePos1, vPos)
                  local point4, onLineSegment4 = gsoClosestPointOnLineSegment(enemyPos2, mePos2, vPos)
                  if isHitable and onLineSegment3 and gsoDistance(point3, enemyPos2) > eWidth then
                    isHitable = false
                  end
                  if isHitable and not onLineSegment3 and gsoDistance(point3, enemyPos2) > enemyBB then
                    isHitable = false
                  end
                  if isHitable and onLineSegment4 and gsoDistance(point4, enemyPos2) > eWidth then
                    isHitable = false
                  end
                  if isHitable and not onLineSegment4 and gsoDistance(point4, enemyPos2) > enemyBB then
                    isHitable = false
                  end
                end
                if isHitable then
                  xFeathers = xFeathers + 1
                end
              end
            end
            if xFeathers >= 3 then
              xEnemies = xEnemies + 1
            end
          end
          if xEnemies >= gsoMeMenu.eset.erootx:Value() then
            Control.KeyDown(HK_E)
            Control.KeyUp(HK_E)
            gsoSpellTimers.le = gsoGetTickCount()
            return true
          end
        end
        return false
      end
      
      gsoOrbwalker:OnAttack(function()
        if gsoMeMenu.wset.wonaa:Value() and gsoUseE() == false then
          local isCombo = gsoMode.isCombo()
          local isHarass = gsoMode.isHarass()
          if isCombo or isHarass then
            local target = gsoObjects.comboTarget
            local isTarget = target ~= nil
            --W
            local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                  canW = canW and isTarget and gsoIsReadyFast(_W, { q = 250, w = 1000, e = 100, r = 500 })
            if canW and gsoCastSpell(HK_W) then
              champInfo.windUpOld = gsoTimers.windUpTime
              champInfo.asNoW = myHero.attackSpeed
              gsoSpellTimers.lw = gsoGetTickCount()
              gsoSpellCan.botrk = false
            end
          end
        end
        return true
      end)
      
      --[[ on move ]]
      gsoOrbwalker:OnMove(function()
        local isCombo = gsoMode.isCombo()
        local isHarass = gsoMode.isHarass()
        if gsoUseE() == true then return false end
        if isCombo or isHarass then
          local target = gsoObjects.comboTarget
          local isTarget = target ~= nil
          local afterAttack = Game.Timer() < gsoTimers.lastAttackSend + ( gsoTimers.animationTime * 0.75 )
          local mePos = gsoMyHero.pos
          --W
          local canW = ( isCombo and gsoMeMenu.wset.combo:Value() ) or ( isHarass and gsoMeMenu.wset.harass:Value() )
                canW = canW and isTarget and gsoIsReadyFast(_W, { q = 250, w = 1000, e = 100, r = 500 })
          if canW then
            local extraWAS = gsoMyHero:GetSpellData(_W).level * 0.05
            local aaSpeed = gsoMyHero.attackSpeed + 0.25 + extraWAS
                  aaSpeed = aaSpeed * gsoExtra.baseAttackSpeed
            local numAS   = aaSpeed >= 2.5 and 1 / 2.5 or 1 / aaSpeed
            if gsoGameTimer() > gsoTimers.lastAttackSend + numAS - gsoExtra.minLatency and gsoCastSpell(HK_W) then
              champInfo.windUpOld = gsoTimers.windUpTime
              champInfo.asNoW = myHero.attackSpeed
              gsoSpellTimers.lw = gsoGetTickCount()
              gsoActions({ func = function() gsoExtra.resetAttack = true end, startTime = gsoGameTimer() + gsoExtra.minLatency })
              gsoSpellCan.botrk = false
              return false
            end
          end
          --Q
          if not isTarget or afterAttack then
            local canQ = ( isCombo and gsoMeMenu.qset.combo:Value() ) or ( isHarass and gsoMeMenu.qset.harass:Value() )
            if canQ and gsoIsReady(_Q, { q = 1000, w = 0, e = 0, r = 600 }) then
              local qTarget = target
              if not isTarget then qTarget = gsoGetTarget(1100, gsoObjects.enemyHeroes_spell, gsoMyHero.pos, false, false) end
              if qTarget and (not gsoMeMenu.qset.outaa:Value() or not isTarget) and gsoCastSpellSkillShot(HK_Q, gsoMyHero.pos, qTarget) then
                gsoSpellTimers.lq = gsoGetTickCount()
                gsoSpellCan.botrk = false
                return false
              end
            end
          end
        end
        return true
      end)
      Callback.Add('Draw', function()
        for k,v in pairs(xayahEPas) do
          if v.active and gsoGameTimer() > v.endTime then
            v.active = false
          elseif not v.active and gsoGameTimer() > v.endTime + 10 then
            xayahEPas[k] = nil
          elseif v.active then
            local p1 = gsoMyHero.pos:To2D()
            local p2 = v.pos:To2D()
            Draw.Line(p1.x, p1.y, p2.x, p2.y,gsoMeMenu.eset.edraw.ewidth:Value(),gsoMeMenu.eset.edraw.ecolor:Value())
          end
        end
      end)
      Callback.Add('WndMsg', function(msg, wParam)
        local getTick = gsoGetTickCount()
        if wParam == HK_E and Game.CanUseSpell(_E) == 0 then
          for k,v in pairs(xayahEPas) do
            if v.active then
              v.active = false
            end
          end
        end
      end)
      --[[ on tick ]]
      gsoOrbwalker:OnTick(function()
        gsoUseE()
        local wDuration = gsoBuffDuration(gsoMyHero, "xayahw")
        if wDuration > 0 then
          champInfo.wEndTime = Game.Timer() + wDuration
        end
        --Feathers
        local featherName = "Xayah_Base_Passive_Dagger_indicator8s"
        --local featherName = "Xayah_Base_Passive_Dagger_Mark8s"
        local mePos = gsoMyHero.pos
        for i = 1, Game.ParticleCount() do
          local particle = Game.Particle(i)
          if particle and particle.name == featherName and gsoDistance(mePos, particle.pos) < 2500 then
            local particleID = particle.networkID
            if not xayahEPas[particleID] then
              xayahEPas[particleID] = { pos = particle.pos, endTime = gsoGameTimer() + 6 - gsoExtra.maxLatency, active = true }
            end
          end
        end
        gsoObjects.comboTarget = nil
      end)
      
      gsoOrbwalker:CanChangeAnimationTime(function()
        return champInfo.wEndTime - Game.Timer() > 0
      end)
      
      --[[ custom attack speed ]]
      gsoOrbwalker:AttackSpeed(function()
        local num = champInfo.wEndTime - Game.Timer()
        if num < champInfo.windUpOld and num > -2 then
          return champInfo.asNoW
        end
        return gsoMyHero.attackSpeed
      end)
      
      --[[ can move | attack ]]
      gsoOrbwalker:CanMove(function() return gsoCheckTimers({ q = 150, w = 0, e = 0, r = 500 }) end)
      gsoOrbwalker:CanAttack(function() return gsoCheckTimers({ q = 200, w = 0, e = 0, r = 600 }) end)
      
      --[[ on issue ]]
      gsoOrbwalker:OnIssue(function(issue) if issue == 1 then gsoSpellCan.q = true; gsoSpellCan.w = true; gsoSpellCan.e = true; gsoSpellCan.r = true; gsoSpellCan.botrk = true; return true end end)
    end,
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
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
 
  gsoOrbwalker:CanMove(function() if gsoGetTickCount() - gsoItems.lastBotrk < 100 then return false else return true end end)
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
      if gsoSpellDraw.q then
        gsoMenu.gsodraw.circle1.qrange:Hide(true)
        gsoMenu.gsodraw.circle1.qrangecolor:Hide(true)
        gsoMenu.gsodraw.circle1.qrangewidth:Hide(true) end
      if gsoSpellDraw.w then
        gsoMenu.gsodraw.circle1.wrange:Hide(true)
        gsoMenu.gsodraw.circle1.wrangecolor:Hide(true)
        gsoMenu.gsodraw.circle1.wrangewidth:Hide(true) end
      if gsoSpellDraw.e then
        gsoMenu.gsodraw.circle1.erange:Hide(true)
        gsoMenu.gsodraw.circle1.erangecolor:Hide(true)
        gsoMenu.gsodraw.circle1.erangewidth:Hide(true) end
      if gsoSpellDraw.r then
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
  if gsoSpellDraw.q then
    gsoMenu.gsodraw.circle1:MenuElement({name = "Q Range", id = "note5", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
        gsoMenu.gsodraw.circle1.qrange:Hide()
        gsoMenu.gsodraw.circle1.qrangecolor:Hide()
        gsoMenu.gsodraw.circle1.qrangewidth:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({id = "qrange", name = "        Enabled", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({id = "qrangecolor", name = "        Color", color = Draw.Color(255, 66, 134, 244)})
      gsoMenu.gsodraw.circle1:MenuElement({id = "qrangewidth", name = "        Width", value = 1, min = 1, max = 10}) end
  if gsoSpellDraw.w then
    gsoMenu.gsodraw.circle1:MenuElement({name = "W Range", id = "note6", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
        gsoMenu.gsodraw.circle1.wrange:Hide()
        gsoMenu.gsodraw.circle1.wrangecolor:Hide()
        gsoMenu.gsodraw.circle1.wrangewidth:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({id = "wrange", name = "        Enabled", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({id = "wrangecolor", name = "        Color", color = Draw.Color(255, 92, 66, 244)})
      gsoMenu.gsodraw.circle1:MenuElement({id = "wrangewidth", name = "        Width", value = 1, min = 1, max = 10}) end
  if gsoSpellDraw.e then
    gsoMenu.gsodraw.circle1:MenuElement({name = "E Range", id = "note7", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
      onclick = function()
          gsoMenu.gsodraw.circle1.erange:Hide()
          gsoMenu.gsodraw.circle1.erangecolor:Hide()
          gsoMenu.gsodraw.circle1.erangewidth:Hide() end })
      gsoMenu.gsodraw.circle1:MenuElement({id = "erange", name = "        Enabled", value = true})
      gsoMenu.gsodraw.circle1:MenuElement({id = "erangecolor", name = "        Color", color = Draw.Color(255, 66, 244, 149)})
      gsoMenu.gsodraw.circle1:MenuElement({id = "erangewidth", name = "        Width", value = 1, min = 1, max = 10}) end
  if gsoSpellDraw.r then
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
    if gsoSpellDraw.q and drawMenu.qrange:Value() then
        local qrange = gsoSpellDraw.qf and gsoSpellDraw.qf() or gsoSpellDraw.qr
        gsoDrawCircle(mePos, qrange, drawMenu.qrangewidth:Value(), drawMenu.qrangecolor:Value()) end
    if gsoSpellDraw.w and drawMenu.wrange:Value() then
        local wrange = gsoSpellDraw.wf and gsoSpellDraw.wf() or gsoSpellDraw.wr
        gsoDrawCircle(mePos, wrange, drawMenu.wrangewidth:Value(), drawMenu.wrangecolor:Value()) end
    if gsoSpellDraw.e and drawMenu.erange:Value() then
        local erange = gsoSpellDraw.ef and gsoSpellDraw.ef() or gsoSpellDraw.er
        gsoDrawCircle(mePos, erange, drawMenu.erangewidth:Value(), drawMenu.erangecolor:Value()) end
    if gsoSpellDraw.r and drawMenu.rrange:Value() then
        local rrange = gsoSpellDraw.rf and gsoSpellDraw.rf() or gsoSpellDraw.rr
        gsoDrawCircle(mePos, rrange, drawMenu.rrangewidth:Value(), drawMenu.rrangecolor:Value()) end
end
function OnWndMsg(msg, wParam)
  if not gsoLoaded then return end
  local getTick = gsoGetTickCount()
  local manualNum = -1
  if wParam == HK_Q and getTick > gsoSpellTimers.lqk + 1000 and Game.CanUseSpell(_Q) == 0 then gsoSpellTimers.lqk = getTick; manualNum = 0
  elseif wParam == HK_W and getTick > gsoSpellTimers.lwk + 1000 and Game.CanUseSpell(_W) == 0 then gsoSpellTimers.lwk = getTick; manualNum = 1
  elseif wParam == HK_E and getTick > gsoSpellTimers.lek + 1000 and Game.CanUseSpell(_E) == 0 then gsoSpellTimers.lek = getTick; manualNum = 2
  elseif wParam == HK_R and getTick > gsoSpellTimers.lrk + 1000 and Game.CanUseSpell(_R) == 0 then gsoSpellTimers.lrk = getTick; manualNum = 3 end
  if manualNum > -1 and not gsoDelayedSpell[manualNum] then if gsoMode.isCombo() or gsoMode.isHarass() or gsoMode.isLaneClear() or gsoMode.isLastHit() then gsoDelayedSpell[manualNum] = { function() Control.KeyDown(wParam);Control.KeyUp(wParam);Control.KeyDown(wParam);Control.KeyUp(wParam);Control.KeyDown(wParam);Control.KeyUp(wParam); end, getTick} end end
end
