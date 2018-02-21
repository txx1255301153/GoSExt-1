
class "__gsoMenu"

function __gsoMenu:__init()
    self.Icons = {
        ["arrow"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png",
        ["ashe"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ashe.png",
        ["botrk"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/botrk.png",
        ["draven"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/draven.png",
        ["circles"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/circles.png",
        ["ezreal"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ezreal.png",
        ["gsoaio"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gsoaio.png",
        ["item"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/item.png",
        ["kog"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kog.png",
        ["orb"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orb.png",
        ["sivir"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/sivir.png",
        ["teemo"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/teemo.png",
        ["timer"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/timer.png",
        ["tristana"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/tristana.png",
        ["ts"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ts.png",
        ["twitch"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/twitch.png",
        ["vayne"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/vayne.png",
        ["jinx"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/jinx.png",
        ["mpotion"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/mpotion.png"
    }
    self.menu = MenuElement({name = "Gamsteron AIO", id = "gamsteronaio", type = MENU, leftIcon = self.Icons["gsoaio"] })
end

function __gsoMenu:_menuChamp()
    if gsoAIO.Load.meTristana then self:_menuTristana()
    elseif gsoAIO.Load.meSivir then self:_menuSivir()
    elseif gsoAIO.Load.meVayne then self:_menuVayne()
    elseif gsoAIO.Load.meKog then self:_menuKog()
    elseif gsoAIO.Load.meTwitch then self:_menuTwitch()
    elseif gsoAIO.Load.meAshe then self:_menuAshe()
    elseif gsoAIO.Load.meEzreal then self:_menuEzreal()
    elseif gsoAIO.Load.meDraven then self:_menuDraven()
    elseif gsoAIO.Load.meTeemo then self:_menuTeemo()
    elseif gsoAIO.Load.meJinx then self:_menuJinx() end
end

function __gsoMenu:_menuTristana()
    self.menu:MenuElement({name = "Tristana", id = "gsotristana", type = MENU, leftIcon = self.Icons["tristana"] })
        self.menu.gsotristana:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsotristana.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotristana.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotristana:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsotristana.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotristana.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotristana:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsotristana.rset:MenuElement({id = "ks", name = "KS", value = true})
            self.menu.gsotristana.rset:MenuElement({id = "kse", name = "KS only E + R", value = false})
end

function __gsoMenu:_menuSivir()
    self.menu:MenuElement({name = "Sivir", id = "gsosivir", type = MENU, leftIcon = self.Icons["sivir"] })
        self.menu.gsosivir:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsosivir.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosivir.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosivir:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsosivir.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosivir.wset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuVayne()
    self.menu:MenuElement({name = "Vayne", id = "gsovayne", type = MENU, leftIcon = self.Icons["vayne"] })
        self.menu.gsovayne:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsovayne.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovayne.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovayne:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsovayne.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovayne.eset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKog()
    self.menu:MenuElement({name = "Kog'Maw", id = "gsokog", type = MENU, leftIcon = self.Icons["kog"] })
        self.menu.gsokog:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokog.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokog.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokog:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokog.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokog.wset:MenuElement({id = "harass", name = "Harass", value = false})
            self.menu.gsokog.wset:MenuElement({id = "stopq", name = "Stop Q if has W buff", value = false})
            self.menu.gsokog.wset:MenuElement({id = "stope", name = "Stop E if has W buff", value = false})
            self.menu.gsokog.wset:MenuElement({id = "stopr", name = "Stop R if has W buff", value = false})
        self.menu.gsokog:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokog.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokog.eset:MenuElement({id = "harass", name = "Harass", value = false})
            self.menu.gsokog.eset:MenuElement({id = "emana", name = "Minimum Mana %", value = 20, min = 1, max = 100, step = 1 })
        self.menu.gsokog:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokog.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokog.rset:MenuElement({id = "harass", name = "Harass", value = false})
            self.menu.gsokog.rset:MenuElement({id = "onlylow", name = "Only 0-40 % HP enemies", value = true})
            self.menu.gsokog.rset:MenuElement({id = "stack", name = "Stop at x stacks", value = 3, min = 1, max = 9, step = 1 })
            self.menu.gsokog.rset:MenuElement({id = "rmana", name = "Minimum Mana %", value = 20, min = 1, max = 100, step = 1 })
            self.menu.gsokog.rset:MenuElement({name = "KS", id = "ksmenu", type = MENU })
                self.menu.gsokog.rset.ksmenu:MenuElement({id = "ksr", name = "KS - Enabled", value = true})
                self.menu.gsokog.rset.ksmenu:MenuElement({id = "csksr", name = "KS -> Check R stacks", value = false})
            self.menu.gsokog.rset:MenuElement({name = "Semi Manual", id = "semirmenu", type = MENU })
                self.menu.gsokog.rset.semirmenu:MenuElement({name = "Semi-Manual Key", id = "semir", key = string.byte("T")})
                self.menu.gsokog.rset.semirmenu:MenuElement({name = "Check R stacks", id = "semistacks", value = false})
                self.menu.gsokog.rset.semirmenu:MenuElement({name = "Only 0-40 % HP enemies", id = "semilow",  value = false})
                self.menu.gsokog.rset.semirmenu:MenuElement({name = "Use on:", id = "useon", type = MENU })
end

function __gsoMenu:_menuTwitch()
    self.menu:MenuElement({name = "Twitch", id = "gsotwitch", type = MENU, leftIcon = self.Icons["twitch"] })
        self.menu.gsotwitch:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsotwitch.qset:MenuElement({id = "recallkey", name = "Invisible Recall Key", key = string.byte("T"), value = false, toggle = true})
            self.menu.gsotwitch.qset:MenuElement({id = "note1", name = "Note: Key should be diffrent than recall key", type = SPACE})
        self.menu.gsotwitch:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsotwitch.wset:MenuElement({id = "stopq", name = "Stop if Q invisible", value = true})
            self.menu.gsotwitch.wset:MenuElement({id = "stopwult", name = "Stop if R", value = false})
            self.menu.gsotwitch.wset:MenuElement({id = "combo", name = "Use W Combo", value = true})
            self.menu.gsotwitch.wset:MenuElement({id = "harass", name = "Use W Harass", value = false})
        self.menu.gsotwitch:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsotwitch.eset:MenuElement({id = "combo", name = "Use E Combo", value = true})
            self.menu.gsotwitch.eset:MenuElement({id = "harass", name = "Use E Harass", value = false})
            self.menu.gsotwitch.eset:MenuElement({id = "stacks", name = "X stacks", value = 6, min = 1, max = 6, step = 1 })
            self.menu.gsotwitch.eset:MenuElement({id = "enemies", name = "X enemies", value = 1, min = 1, max = 5, step = 1 })
self.menu.gsotwitch.qset.recallkey:Value(false)
end

function __gsoMenu:_menuAshe()
    self.menu:MenuElement({id = "gsoashe", name = "Ashe", type = MENU, leftIcon = self.Icons["ashe"] })
        self.menu.gsoashe:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoashe.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoashe.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoashe:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoashe.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoashe.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoashe:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoashe.rset:MenuElement({id = "combo", name = "Use R Combo", value = true})
            self.menu.gsoashe.rset:MenuElement({id = "harass", name = "Use R Harass", value = false})
            self.menu.gsoashe.rset:MenuElement({id = "rci", name = "Use R if enemy isImmobile", value = true})
            self.menu.gsoashe.rset:MenuElement({id = "rcd", name = "Use R if enemy distance < X", value = true})
            self.menu.gsoashe.rset:MenuElement({id = "rdist", name = "use R if enemy distance < X", value = 500, min = 250, max = 1000, step = 50})
            self.menu.gsoashe.rset:MenuElement({name = "R Semi Manual", id = "semirmenu", type = MENU })
                self.menu.gsoashe.rset.semirmenu:MenuElement({name = "Semi-Manual Key", id = "semir", key = string.byte("T")})
                self.menu.gsoashe.rset.semirmenu:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
                self.menu.gsoashe.rset.semirmenu:MenuElement({name = "Use on:", id = "useon", type = MENU })
end

function __gsoMenu:_menuEzreal()
    self.menu:MenuElement({name = "Ezreal", id = "gsoezreal", type = MENU, leftIcon = self.Icons["ezreal"] })
        self.menu.gsoezreal:MenuElement({name = "Auto Q", id = "autoq", type = MENU })
            self.menu.gsoezreal.autoq:MenuElement({id = "enable", name = "Enable", value = true, key = string.byte("T"), toggle = true})
            self.menu.gsoezreal.autoq:MenuElement({id = "mana", name = "Q Auto min. mana percent", value = 50, min = 0, max = 100, step = 1 })
        self.menu.gsoezreal:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoezreal.qset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            self.menu.gsoezreal.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoezreal.qset:MenuElement({id = "harass", name = "Harass", value = false})
            self.menu.gsoezreal.qset:MenuElement({id = "laneclear", name = "LaneClear", value = false})
            self.menu.gsoezreal.qset:MenuElement({id = "lasthit", name = "LastHit", value = true})
            self.menu.gsoezreal.qset:MenuElement({id = "qlh", name = "Q LastHit min. mana percent", value = 10, min = 0, max = 100, step = 1 })
            self.menu.gsoezreal.qset:MenuElement({id = "qlc", name = "Q LaneClear min. mana percent", value = 50, min = 0, max = 100, step = 1 })
        self.menu.gsoezreal:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoezreal.wset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            self.menu.gsoezreal.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoezreal.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoezreal:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoezreal.rset:MenuElement({name = "Semi-Manual Key", id = "semir", key = string.byte("I")})
            self.menu.gsoezreal.rset:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
            self.menu.gsoezreal.rset:MenuElement({name = "Use on:", id = "useon", type = MENU })
end

function __gsoMenu:_menuDraven()
    self.menu:MenuElement({name = "Draven", id = "gsodraven", type = MENU, leftIcon = self.Icons["draven"] })
        self.menu.gsodraven:MenuElement({name = "AXE settings", id = "aset", type = MENU })
            self.menu.gsodraven.aset:MenuElement({id = "catch", name = "Catch axes", value = true})
            self.menu.gsodraven.aset:MenuElement({id = "catcht", name = "stop under turret", value = true})
            self.menu.gsodraven.aset:MenuElement({id = "catcho", name = "[combo] stop if no enemy in range", value = true})
            self.menu.gsodraven.aset:MenuElement({name = "Distance", id = "dist", type = MENU })
                self.menu.gsodraven.aset.dist:MenuElement({id = "mode", name = "Axe Mode", value = 1, drop = {"closest to mousePos", "closest to heroPos"} })
                self.menu.gsodraven.aset.dist:MenuElement({id = "extradur", name = "extra axe duration time", value = 100, min = 0, max = 300, step = 10 })
                self.menu.gsodraven.aset.dist:MenuElement({id = "stopmove", name = "axePos in distance < X | Hold radius", value = 75, min = 50, max = 125, step = 5 })
                self.menu.gsodraven.aset.dist:MenuElement({id = "cdist", name = "max distance from axePos to cursorPos", value = 750, min = 500, max = 1500, step = 50 })
        self.menu.gsodraven:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsodraven.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodraven.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodraven:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsodraven.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodraven.wset:MenuElement({id = "harass", name = "Harass", value = false})
            self.menu.gsodraven.wset:MenuElement({id = "hdist", name = "max enemy distance", value = 750, min = 500, max = 2000, step = 50 })
        self.menu.gsodraven:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsodraven.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodraven.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodraven:MenuElement({name = "R Semi Manual", id = "rset", type = MENU })
            self.menu.gsodraven.rset:MenuElement({name = "Semi-Manual Key", id = "semir", key = string.byte("T")})
            self.menu.gsodraven.rset:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
            self.menu.gsodraven.rset:MenuElement({name = "Use on:", id = "useon", type = MENU })
end

function __gsoMenu:_menuTeemo()
    self.menu:MenuElement({name = "Teemo", id = "gsoteemo", type = MENU, leftIcon = self.Icons["teemo"] })
        self.menu.gsoteemo:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoteemo.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoteemo.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoteemo:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoteemo.wset:MenuElement({id = "mindist", name = "Min. distance to enemy", value = 850, min = 680, max = 1250, step = 10 })
            self.menu.gsoteemo.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoteemo.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoteemo:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoteemo.rset:MenuElement({id = "immo", name = "only if enemy isImmobile", value = true})
            self.menu.gsoteemo.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoteemo.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuJinx()
    self.menu:MenuElement({name = "Jinx", id = "gsojinx", type = MENU, leftIcon = self.Icons["jinx"] })
        self.menu.gsojinx:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsojinx.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojinx.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojinx:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsojinx.wset:MenuElement({id = "wout", name = "W only if enemy out of attack range", value = false})
            self.menu.gsojinx.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojinx.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojinx:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsojinx.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojinx.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojinx:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsojinx.rset:MenuElement({name = "Semi-Manual Key", id = "semir", key = string.byte("T")})
            self.menu.gsojinx.rset:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
            self.menu.gsojinx.rset:MenuElement({name = "Use on:", id = "useon", type = MENU })
end

function __gsoMenu:_menuDraw()
    self.menu.gsodraw:MenuElement({name = "Circles", id = "circle1", type = MENU,
        onclick = function()
            self.menu.gsodraw.circle1.merange:Hide(true)
            self.menu.gsodraw.circle1.mecolor:Hide(true)
            self.menu.gsodraw.circle1.mewidth:Hide(true)
            self.menu.gsodraw.circle1.herange:Hide(true)
            self.menu.gsodraw.circle1.hecolor:Hide(true)
            self.menu.gsodraw.circle1.hewidth:Hide(true)
            self.menu.gsodraw.circle1.cpos:Hide(true)
            self.menu.gsodraw.circle1.cposcolor:Hide(true)
            self.menu.gsodraw.circle1.cposwidth:Hide(true)
            self.menu.gsodraw.circle1.cposradius:Hide(true)
            self.menu.gsodraw.circle1.seltar:Hide(true)
            self.menu.gsodraw.circle1.seltarcolor:Hide(true)
            self.menu.gsodraw.circle1.seltarwidth:Hide(true)
            self.menu.gsodraw.circle1.seltarradius:Hide(true)
            if gsoAIO.Load.meTwitch then
                self.menu.gsodraw.circle1.invenable:Hide(true)
                self.menu.gsodraw.circle1.invcolor:Hide(true)
                self.menu.gsodraw.circle1.notenable:Hide(true)
                self.menu.gsodraw.circle1.notcolor:Hide(true)
            end
            if gsoAIO.Load.meDraven then
                self.menu.gsodraw.circle1.aaxeenable:Hide(true)
                self.menu.gsodraw.circle1.aaxecolor:Hide(true)
                self.menu.gsodraw.circle1.aaxewidth:Hide(true)
                self.menu.gsodraw.circle1.aaxeradius:Hide(true)
                self.menu.gsodraw.circle1.iaxeenable:Hide(true)
                self.menu.gsodraw.circle1.iaxecolor:Hide(true)
                self.menu.gsodraw.circle1.iaxewidth:Hide(true)
                self.menu.gsodraw.circle1.iaxeradius:Hide(true)
            end
            if gsoAIO.Draw.drawRanges.q then
                self.menu.gsodraw.circle1.qrange:Hide(true)
                self.menu.gsodraw.circle1.qrangecolor:Hide(true)
                self.menu.gsodraw.circle1.qrangewidth:Hide(true)
            end
            if gsoAIO.Draw.drawRanges.w then
                self.menu.gsodraw.circle1.wrange:Hide(true)
                self.menu.gsodraw.circle1.wrangecolor:Hide(true)
                self.menu.gsodraw.circle1.wrangewidth:Hide(true)
            end
            if gsoAIO.Draw.drawRanges.e then
                self.menu.gsodraw.circle1.erange:Hide(true)
                self.menu.gsodraw.circle1.erangecolor:Hide(true)
                self.menu.gsodraw.circle1.erangewidth:Hide(true)
            end
            if gsoAIO.Draw.drawRanges.r then
                self.menu.gsodraw.circle1.rrange:Hide(true)
                self.menu.gsodraw.circle1.rrangecolor:Hide(true)
                self.menu.gsodraw.circle1.rrangewidth:Hide(true)
            end
        end
    })
        self.menu.gsodraw.circle1:MenuElement({name = "MyHero attack range", id = "note1", icon = self.Icons["arrow"], type = SPACE,
            onclick = function()
                self.menu.gsodraw.circle1.merange:Hide()
                self.menu.gsodraw.circle1.mecolor:Hide()
                self.menu.gsodraw.circle1.mewidth:Hide()
            end
        })
            self.menu.gsodraw.circle1:MenuElement({name = "        Enabled",  id = "merange", value = true})
            self.menu.gsodraw.circle1:MenuElement({name = "        Color",  id = "mecolor", color = Draw.Color(150, 49, 210, 0)})
            self.menu.gsodraw.circle1:MenuElement({name = "        Width",  id = "mewidth", value = 1, min = 1, max = 10})

        self.menu.gsodraw.circle1:MenuElement({name = "Enemy attack range", id = "note2", icon = self.Icons["arrow"], type = SPACE,
            onclick = function()
                self.menu.gsodraw.circle1.herange:Hide()
                self.menu.gsodraw.circle1.hecolor:Hide()
                self.menu.gsodraw.circle1.hewidth:Hide()
            end
        })
            self.menu.gsodraw.circle1:MenuElement({name = "        Enabled",  id = "herange", value = true})
            self.menu.gsodraw.circle1:MenuElement({name = "        Color",  id = "hecolor", color = Draw.Color(150, 255, 0, 0)})
            self.menu.gsodraw.circle1:MenuElement({name = "        Width",  id = "hewidth", value = 1, min = 1, max = 10})

        self.menu.gsodraw.circle1:MenuElement({name = "Cursor Position", id = "note3", icon = self.Icons["arrow"], type = SPACE,
            onclick = function()
                self.menu.gsodraw.circle1.cpos:Hide()
                self.menu.gsodraw.circle1.cposcolor:Hide()
                self.menu.gsodraw.circle1.cposwidth:Hide()
                self.menu.gsodraw.circle1.cposradius:Hide()
            end
        })
            self.menu.gsodraw.circle1:MenuElement({name = "        Enabled",  id = "cpos", value = true})
            self.menu.gsodraw.circle1:MenuElement({name = "        Color",  id = "cposcolor", color = Draw.Color(150, 153, 0, 76)})
            self.menu.gsodraw.circle1:MenuElement({name = "        Width",  id = "cposwidth", value = 5, min = 1, max = 10})
            self.menu.gsodraw.circle1:MenuElement({name = "        Radius",  id = "cposradius", value = 250, min = 1, max = 300})

        self.menu.gsodraw.circle1:MenuElement({name = "Selected Target", id = "note4", icon = self.Icons["arrow"], type = SPACE,
            onclick = function()
                self.menu.gsodraw.circle1.seltar:Hide()
                self.menu.gsodraw.circle1.seltarcolor:Hide()
                self.menu.gsodraw.circle1.seltarwidth:Hide()
                self.menu.gsodraw.circle1.seltarradius:Hide()
            end
        })
            self.menu.gsodraw.circle1:MenuElement({name = "        Enabled",  id = "seltar", value = true})
            self.menu.gsodraw.circle1:MenuElement({name = "        Color",  id = "seltarcolor", color = Draw.Color(255, 204, 0, 0)})
            self.menu.gsodraw.circle1:MenuElement({name = "        Width",  id = "seltarwidth", value = 3, min = 1, max = 10})
            self.menu.gsodraw.circle1:MenuElement({name = "        Radius",  id = "seltarradius", value = 150, min = 1, max = 300})
        
        if gsoAIO.Load.meTwitch then
            self.menu.gsodraw.circle1:MenuElement({name = "Q Invisible Range", id = "note9", icon = self.Icons["arrow"], type = SPACE,
                onclick = function()
                    self.menu.gsodraw.circle1.invenable:Hide()
                    self.menu.gsodraw.circle1.invcolor:Hide()
                end
            })
                self.menu.gsodraw.circle1:MenuElement({id = "invenable", name = "        Enabled", value = true})
                self.menu.gsodraw.circle1:MenuElement({id = "invcolor", name = "        Color ", color = Draw.Color(200, 255, 0, 0)})

            self.menu.gsodraw.circle1:MenuElement({name = "Q Notification Range", id = "note10", icon = self.Icons["arrow"], type = SPACE,
                onclick = function()
                    self.menu.gsodraw.circle1.notenable:Hide()
                    self.menu.gsodraw.circle1.notcolor:Hide()
                end
            })
                self.menu.gsodraw.circle1:MenuElement({id = "notenable", name = "        Enabled", value = true})
                self.menu.gsodraw.circle1:MenuElement({id = "notcolor", name = "        Color", color = Draw.Color(200, 188, 77, 26)})
        end
        
        if gsoAIO.Draw.drawRanges.q then
            self.menu.gsodraw.circle1:MenuElement({name = "Q Range", id = "note5", icon = self.Icons["arrow"], type = SPACE,
                onclick = function()
                    self.menu.gsodraw.circle1.qrange:Hide()
                    self.menu.gsodraw.circle1.qrangecolor:Hide()
                    self.menu.gsodraw.circle1.qrangewidth:Hide()
                end
            })
                self.menu.gsodraw.circle1:MenuElement({id = "qrange", name = "        Enabled", value = true})
                self.menu.gsodraw.circle1:MenuElement({id = "qrangecolor", name = "        Color", color = Draw.Color(255, 66, 134, 244)})
                self.menu.gsodraw.circle1:MenuElement({id = "qrangewidth", name = "        Width", value = 1, min = 1, max = 10})
        end
        
        if gsoAIO.Draw.drawRanges.w then
            self.menu.gsodraw.circle1:MenuElement({name = "W Range", id = "note6", icon = self.Icons["arrow"], type = SPACE,
                onclick = function()
                    self.menu.gsodraw.circle1.wrange:Hide()
                    self.menu.gsodraw.circle1.wrangecolor:Hide()
                    self.menu.gsodraw.circle1.wrangewidth:Hide()
                end
            })
                self.menu.gsodraw.circle1:MenuElement({id = "wrange", name = "        Enabled", value = true})
                self.menu.gsodraw.circle1:MenuElement({id = "wrangecolor", name = "        Color", color = Draw.Color(255, 92, 66, 244)})
                self.menu.gsodraw.circle1:MenuElement({id = "wrangewidth", name = "        Width", value = 1, min = 1, max = 10})
        end
        
        if gsoAIO.Draw.drawRanges.e then
            self.menu.gsodraw.circle1:MenuElement({name = "E Range", id = "note7", icon = self.Icons["arrow"], type = SPACE,
                onclick = function()
                    self.menu.gsodraw.circle1.erange:Hide()
                    self.menu.gsodraw.circle1.erangecolor:Hide()
                    self.menu.gsodraw.circle1.erangewidth:Hide()
                end
            })
                self.menu.gsodraw.circle1:MenuElement({id = "erange", name = "        Enabled", value = true})
                self.menu.gsodraw.circle1:MenuElement({id = "erangecolor", name = "        Color", color = Draw.Color(255, 66, 244, 149)})
                self.menu.gsodraw.circle1:MenuElement({id = "erangewidth", name = "        Width", value = 1, min = 1, max = 10})
        end
        
        if gsoAIO.Draw.drawRanges.r then
            self.menu.gsodraw.circle1:MenuElement({name = "R Range", id = "note8", icon = self.Icons["arrow"], type = SPACE,
                onclick = function()
                    self.menu.gsodraw.circle1.rrange:Hide()
                    self.menu.gsodraw.circle1.rrangecolor:Hide()
                    self.menu.gsodraw.circle1.rrangewidth:Hide()
                end
            })
                self.menu.gsodraw.circle1:MenuElement({id = "rrange", name = "        Enabled", value = true})
                self.menu.gsodraw.circle1:MenuElement({id = "rrangecolor", name = "        Color", color = Draw.Color(255, 244, 182, 66)})
                self.menu.gsodraw.circle1:MenuElement({id = "rrangewidth", name = "        Width", value = 1, min = 1, max = 10})
        end
        
        if gsoAIO.Load.meDraven then
            self.menu.gsodraw.circle1:MenuElement({name = "Active Axe", id = "note9", icon = self.Icons["arrow"], type = SPACE,
                onclick = function()
                    self.menu.gsodraw.circle1.aaxeenable:Hide()
                    self.menu.gsodraw.circle1.aaxecolor:Hide()
                    self.menu.gsodraw.circle1.aaxewidth:Hide()
                    self.menu.gsodraw.circle1.aaxeradius:Hide()
                end
            })
                self.menu.gsodraw.circle1:MenuElement({name = "        Enabled",  id = "aaxeenable", value = true})
                self.menu.gsodraw.circle1:MenuElement({name = "        Color",  id = "aaxecolor", color = Draw.Color(255, 49, 210, 0)})
                self.menu.gsodraw.circle1:MenuElement({name = "        Width",  id = "aaxewidth", value = 1, min = 1, max = 10})
                self.menu.gsodraw.circle1:MenuElement({name = "        Radius",  id = "aaxeradius", value = 170, min = 50, max = 300, step = 10})
            
            self.menu.gsodraw.circle1:MenuElement({name = "InActive Axes", id = "note10", icon = self.Icons["arrow"], type = SPACE,
                onclick = function()
                    self.menu.gsodraw.circle1.iaxeenable:Hide()
                    self.menu.gsodraw.circle1.iaxecolor:Hide()
                    self.menu.gsodraw.circle1.iaxewidth:Hide()
                    self.menu.gsodraw.circle1.iaxeradius:Hide()
                end
            })
                self.menu.gsodraw.circle1:MenuElement({name = "        Enabled",  id = "iaxeenable", value = true})
                self.menu.gsodraw.circle1:MenuElement({name = "        Color",  id = "iaxecolor", color = Draw.Color(255, 153, 0, 0)})
                self.menu.gsodraw.circle1:MenuElement({name = "        Width",  id = "iaxewidth", value = 1, min = 1, max = 10})
                self.menu.gsodraw.circle1:MenuElement({name = "        Radius",  id = "iaxeradius", value = 170, min = 50, max = 300, step = 10})
        end
    if gsoAIO.Load.meTwitch or gsoAIO.Load.meEzreal then
        self.menu.gsodraw:MenuElement({name = "Texts", id = "texts1", type = MENU,
            onclick = function()
                if gsoAIO.Load.meTwitch then
                    self.menu.gsodraw.texts1.enabletime:Hide(true)
                    self.menu.gsodraw.texts1.colortime:Hide(true)
                end
                if gsoAIO.Load.meEzreal then
                    self.menu.gsodraw.texts1.enableautoq:Hide(true)
                    self.menu.gsodraw.texts1.colorautoqe:Hide(true)
                    self.menu.gsodraw.texts1.colorautoqd:Hide(true)
                    self.menu.gsodraw.texts1.sizeautoq:Hide(true)
                    self.menu.gsodraw.texts1.customautoq:Hide(true)
                    self.menu.gsodraw.texts1.xautoq:Hide(true)
                    self.menu.gsodraw.texts1.yautoq:Hide(true)
                end
            end
        })
            if gsoAIO.Load.meTwitch then
                self.menu.gsodraw.texts1:MenuElement({name = "Q Timer", id = "note11", icon = self.Icons["arrow"], type = SPACE,
                    onclick = function()
                        self.menu.gsodraw.texts1.enabletime:Hide()
                        self.menu.gsodraw.texts1.colortime:Hide()
                    end
                })
                    self.menu.gsodraw.texts1:MenuElement({id = "enabletime", name = "        Enabled", value = true})
                    self.menu.gsodraw.texts1:MenuElement({id = "colortime", name = "        Color", color = Draw.Color(200, 65, 255, 100)})
                    
            end
            if gsoAIO.Load.meEzreal then
                self.menu.gsodraw.texts1:MenuElement({name = "Auto Q", id = "note9", icon = self.Icons["arrow"], type = SPACE,
                    onclick = function()
                        self.menu.gsodraw.texts1.enableautoq:Hide()
                        self.menu.gsodraw.texts1.colorautoqe:Hide()
                        self.menu.gsodraw.texts1.colorautoqd:Hide()
                        self.menu.gsodraw.texts1.sizeautoq:Hide()
                        self.menu.gsodraw.texts1.customautoq:Hide()
                        self.menu.gsodraw.texts1.xautoq:Hide()
                        self.menu.gsodraw.texts1.yautoq:Hide()
                    end
                })
                    self.menu.gsodraw.texts1:MenuElement({id = "enableautoq", name = "        Enabled", value = true})
                    self.menu.gsodraw.texts1:MenuElement({id = "colorautoqe", name = "        Color If Enabled", color = Draw.Color(255, 000, 255, 000)})
                    self.menu.gsodraw.texts1:MenuElement({id = "colorautoqd", name = "        Color If Disabled", color = Draw.Color(255, 255, 000, 000)})
                    self.menu.gsodraw.texts1:MenuElement({id = "sizeautoq", name = "        Text Size", value = 25, min = 1, max = 64, step = 1 })
            end
    end
end

function __gsoMenu:_menu()
    
    self.menu:MenuElement({name = "Target Selector", id = "ts", type = MENU, leftIcon = self.Icons["ts"] })
        self.menu.ts:MenuElement({ id = "Mode", name = "Mode", value = 1, drop = { "Auto", "Closest", "Least Health", "Least Priority" } })
        if gsoAIO.Load.meTristana then
            self.menu.ts:MenuElement({ id = "tristE", name = "Tristana E Target", type = MENU })
                self.menu.ts.tristE:MenuElement({ id = "enable", name = "Enable", value = true })
                self.menu.ts.tristE:MenuElement({ id = "stacks", name = "Min. Stacks", value = 3, min = 1, max = 4})
        end
        self.menu.ts:MenuElement({ id = "priority", name = "Priorities", type = MENU })
        self.menu.ts:MenuElement({ id = "selected", name = "Selected Target", type = MENU })
            self.menu.ts.selected:MenuElement({ id = "enable", name = "Enable", value = true })
            self.menu.ts.selected:MenuElement({ id = "only", name = "Only Selected Target", value = false })
    
    self.menu:MenuElement({name = "Orbwalker", id = "orb", type = MENU, leftIcon = self.Icons["orb"] })
        self.menu.orb:MenuElement({name = "Delays", id = "delays", type = MENU})
            self.menu.orb.delays:MenuElement({name = "Extra Kite Delay", id = "windup", value = 0, min = -25, max = 25, step = 1 })
            self.menu.orb.delays:MenuElement({name = "Extra LastHit Delay", id = "lhDelay", value = 0, min = 0, max = 50, step = 1 })
            self.menu.orb.delays:MenuElement({name = "Extra Move Delay", id = "humanizer", value = 200, min = 120, max = 300, step = 10 })
        self.menu.orb:MenuElement({name = "Keys", id = "keys", type = MENU})
            self.menu.orb.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
            self.menu.orb.keys:MenuElement({name = "Harass Key", id = "harass", key = string.byte("C")})
            self.menu.orb.keys:MenuElement({name = "LastHit Key", id = "lastHit", key = string.byte("X")})
            self.menu.orb.keys:MenuElement({name = "LaneClear Key", id = "laneClear", key = string.byte("V")})
    
    self.menu:MenuElement({name = "Items", id = "gsoitem", type = MENU, leftIcon = self.Icons["item"] })
        self.menu.gsoitem:MenuElement({id = "botrk", name = "        botrk", value = true, leftIcon = self.Icons["botrk"] })
    
    self.menu:MenuElement({name = "Drawings", id = "gsodraw", leftIcon = self.Icons["circles"], type = MENU })
        self.menu.gsodraw:MenuElement({name = "Enabled",  id = "enabled", value = true})

    if self.menu.orb.delays.windup:Value() < 0 then self.menu.orb.delays.windup:Value(0) end
end