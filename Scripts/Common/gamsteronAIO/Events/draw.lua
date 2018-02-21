
class "__gsoDraw"

function __gsoDraw:__init()
    if gsoAIO.Load.meTristana then   self.drawRanges = { w = true, wrange = 900 }
    elseif gsoAIO.Load.meSivir then  self.drawRanges = { q = true, qrange = 1250, r = true, rrange = 1000 }
    elseif gsoAIO.Load.meVayne then  self.drawRanges = { q = true, qrange = 300, e = true, erange = 550 }
    elseif gsoAIO.Load.meKog then    self.drawRanges = { q = true, qrange = 1175, e = true, erange = 1280, r = true, rfunc = function() return self:_kogR() end }
    elseif gsoAIO.Load.meTwitch then self.drawRanges = { w = true, wrange = 950, e = true, erange = 1200, r = true, rfunc = function() return self:_twitchR() end }
    elseif gsoAIO.Load.meAshe then   self.drawRanges = { w = true, wrange = 1200 }
    elseif gsoAIO.Load.meEzreal then self.drawRanges = { q = true, qrange = 1150, w = true, wrange = 1000, e = true, erange = 475 }
    elseif gsoAIO.Load.meDraven then self.drawRanges = { e = true, erange = 1050 }
    elseif gsoAIO.Load.meTeemo then  self.drawRanges = { q = true, qrange = 680, r = true, rfunc = function() return self:_teemoR() end }
    elseif gsoAIO.Load.meJinx then   self.drawRanges = { q = true, qfunc = function() return self:_jinxQ() end, w = true, wrange = 1450, e = true, erange = 900 } end
    Callback.Add('Draw', function() self:_draw() end)
end

function __gsoDraw:_kogR()
    local rlvl = myHero:GetSpellData(_R).level
    if rlvl == 0 then
        return 1200
    else
        return 900 + ( 300 * rlvl )
    end
end

function __gsoDraw:_twitchR()
    return myHero.range + 300 + ( myHero.boundingRadius * 2 )
end

function __gsoDraw:_teemoR()
    local rLvl = myHero:GetSpellData(_R).level
    if rLvl == 0 then rLvl = 1 end
    return 150 + ( 250 * rLvl )
end

function __gsoDraw:_jinxQ()
    if gsoAIO.Champ.hasQBuff then
        return 525 + ( myHero.boundingRadius * 2 )
    else
        return 575 + ( 25 * myHero:GetSpellData(_Q).level ) + ( myHero.boundingRadius * 2 )
    end
end

function __gsoDraw:_draw()
    if not gsoAIO.Menu.menu.gsodraw.enabled:Value() then
        return
    end
    for i = 1, #gsoAIO.Callbacks._draw do
        gsoAIO.Callbacks._draw[i]()
    end
    local mePos = myHero.pos
    if self.drawRanges.q and gsoAIO.Menu.menu.gsodraw.circle1.qrange:Value() then
        local qrange = self.drawRanges.qrange and self.drawRanges.qrange or self.drawRanges.qfunc()
        Draw.Circle(mePos, qrange, gsoAIO.Menu.menu.gsodraw.circle1.qrangewidth:Value(), gsoAIO.Menu.menu.gsodraw.circle1.qrangecolor:Value())
    end
    if self.drawRanges.w and gsoAIO.Menu.menu.gsodraw.circle1.wrange:Value() then
        local wrange = self.drawRanges.wrange and self.drawRanges.wrange or self.drawRanges.wfunc()
        Draw.Circle(mePos, wrange, gsoAIO.Menu.menu.gsodraw.circle1.wrangewidth:Value(), gsoAIO.Menu.menu.gsodraw.circle1.wrangecolor:Value())
    end
    if self.drawRanges.e and gsoAIO.Menu.menu.gsodraw.circle1.erange:Value() then
        local erange = self.drawRanges.erange and self.drawRanges.erange or self.drawRanges.efunc()
        Draw.Circle(mePos, erange, gsoAIO.Menu.menu.gsodraw.circle1.erangewidth:Value(), gsoAIO.Menu.menu.gsodraw.circle1.erangecolor:Value())
    end
    if self.drawRanges.r and gsoAIO.Menu.menu.gsodraw.circle1.rrange:Value() then
        local rrange = self.drawRanges.rrange and self.drawRanges.rrange or self.drawRanges.rfunc()
        Draw.Circle(mePos, rrange, gsoAIO.Menu.menu.gsodraw.circle1.rrangewidth:Value(), gsoAIO.Menu.menu.gsodraw.circle1.rrangecolor:Value())
    end
end