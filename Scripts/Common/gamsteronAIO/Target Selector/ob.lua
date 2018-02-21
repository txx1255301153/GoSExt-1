
class "__gsoOB"

function __gsoOB:__init()
    self.allyMinions  = {}
    self.enemyMinions = {}
    self.enemyHeroes  = {}
    self.enemyTurrets = {}
    self.meTeam       = myHero.team
end

function __gsoOB:_tick()
    local mePos = myHero.pos
    for i=1, #self.allyMinions do self.allyMinions[i]=nil end
    for i=1, #self.enemyMinions do self.enemyMinions[i]=nil end
    for i=1, #self.enemyHeroes do self.enemyHeroes[i]=nil end
    for i=1, #self.enemyTurrets do self.enemyTurrets[i]=nil end
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if minion and gsoAIO.Utils:_getDistance(mePos, minion.pos) < 2000 and not minion.dead and minion.isTargetable and minion.visible and minion.valid and not minion.isImmortal then
            if minion.team ~= self.meTeam then
                self.enemyMinions[#self.enemyMinions+1] = minion
            else
                self.allyMinions[#self.allyMinions+1] = minion
            end
        end
    end
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if hero and hero.team ~= self.meTeam and gsoAIO.Utils:_getDistance(mePos, hero.pos) < 10000 and not hero.dead and hero.isTargetable and hero.visible and hero.valid then
            self.enemyHeroes[#self.enemyHeroes+1] = hero
        end
    end
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret and turret.team ~= self.meTeam and gsoAIO.Utils:_getDistance(mePos, turret.pos) < 2000 and not turret.dead and turret.isTargetable and turret.visible and turret.valid and not turret.isImmortal then
            self.enemyTurrets[#self.enemyTurrets+1] = turret
        end
    end
end