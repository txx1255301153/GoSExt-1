
local version = "0.6451"
local heroName = myHero.charName:lower()
local supportedChampions = {
    ["aatrox"] = false,
    ["ahri"] = false,
    ["akali"] = false,
    ["alistar"] = false,
    ["amumu"] = false,
    ["anivia"] = false,
    ["annie"] = false,
    ["ashe"] = true,
    ["aurelionsol"] = false,
    ["azir"] = false,
    ["bard"] = false,
    ["blitzcrank"] = false,
    ["brand"] = false,
    ["braum"] = false,
    ["caitlyn"] = false,
    ["camille"] = false,
    ["cassiopeia"] = false,
    ["chogath"] = false,
    ["corki"] = false,
    ["darius"] = false,
    ["diana"] = false,
    ["drmundo"] = false,
    ["draven"] = true,
    ["ekko"] = false,
    ["elise"] = false,
    ["evelynn"] = false,
    ["ezreal"] = true,
    ["fiddlesticks"] = false,
    ["fiora"] = false,
    ["fizz"] = false,
    ["galio"] = false,
    ["gangplank"] = false,
    ["garen"] = false,
    ["gnar"] = false,
    ["gragas"] = false,
    ["graves"] = false,
    ["hecarim"] = false,
    ["heimerdinger"] = false,
    ["illaoi"] = false,
    ["irelia"] = false,
    ["ivern"] = false,
    ["janna"] = false,
    ["jarvaniv"] = false,
    ["jax"] = false,
    ["jayce"] = false,
    ["jhin"] = false,
    ["jinx"] = true,
    ["kalista"] = false,
    ["karma"] = false,
    ["karthus"] = false,
    ["kassadin"] = false,
    ["katarina"] = false,
    ["kayle"] = false,
    ["kayn"] = false,
    ["kennen"] = false,
    ["khazix"] = false,
    ["kindred"] = false,
    ["kled"] = false,
    ["kogmaw"] = true,
    ["leblanc"] = false,
    ["leesin"] = false,
    ["leona"] = false,
    ["lissandra"] = false,
    ["lucian"] = true,
    ["lulu"] = false,
    ["lux"] = false,
    ["malphite"] = false,
    ["malzahar"] = false,
    ["maokai"] = false,
    ["masteryi"] = false,
    ["missfortune"] = false,
    ["monkeyking"] = false,
    ["mordekaiser"] = false,
    ["morgana"] = false,
    ["nami"] = false,
    ["nasus"] = false,
    ["nautilus"] = false,
    ["nidalee"] = false,
    ["nocturne"] = false,
    ["nunu"] = false,
    ["olaf"] = false,
    ["orianna"] = false,
    ["ornn"] = false,
    ["pantheon"] = false,
    ["poppy"] = false,
    ["quinn"] = false,
    ["rakan"] = false,
    ["rammus"] = false,
    ["reksai"] = false,
    ["renekton"] = false,
    ["rengar"] = false,
    ["riven"] = false,
    ["rumble"] = false,
    ["ryze"] = false,
    ["sejuani"] = false,
    ["shaco"] = false,
    ["shen"] = false,
    ["shyvana"] = false,
    ["singed"] = false,
    ["sion"] = false,
    ["sivir"] = true,
    ["skarner"] = false,
    ["sona"] = false,
    ["soraka"] = false,
    ["swain"] = false,
    ["syndra"] = false,
    ["tahmkench"] = false,
    ["taliyah"] = false,
    ["talon"] = false,
    ["taric"] = false,
    ["teemo"] = true,
    ["thresh"] = false,
    ["tristana"] = true,
    ["trundle"] = false,
    ["tryndamere"] = false,
    ["twistedfate"] = false,
    ["twitch"] = true,
    ["udyr"] = false,
    ["urgot"] = false,
    ["varus"] = false,
    ["vayne"] = true,
    ["veigar"] = false,
    ["velkoz"] = false,
    ["vi"] = false,
    ["viktor"] = false,
    ["vladimir"] = false,
    ["volibear"] = false,
    ["warwick"] = false,
    ["xayah"] = false,
    ["xerath"] = false,
    ["xinzhao"] = false,
    ["yasuo"] = false,
    ["yorick"] = false,
    ["zac"] = false,
    ["zed"] = false,
    ["ziggs"] = false,
    ["zilean"] = false,
    ["zoe"] = false,
    ["zyra"] = false
}
if not supportedChampions[heroName] then
    print("gamsteronAIO "..version.." | hero not supported !")
    return
end

local mathSqrt = math.sqrt
local myHero = myHero

class "__gsoDmg"

function __gsoDmg:__init()
    self.Damages =
    {
        ["Tristana"] =
        {
            e =
            {
                dmgAP =
                    function()
                        return 25 + ( 25 * myHero:GetSpellData(_E).level ) + ( 0.25 * myHero.ap )
                    end,
                dmgAD =
                    function(stacks)
                        local elvl = myHero:GetSpellData(_E).level
                        local meDmg = myHero.totalDamage
                        local meAP = myHero.ap
                        local stacksDmg = 0
                        local baseDmg = 50 + ( 10 * elvl ) + ( ( 0.4 + ( 0.1 * elvl ) ) * meDmg ) + ( 0.5 * meAP )
                        if stacks > 0 then
                            local stackDmg = 15 + ( 3 * elvl ) + ( ( 0.12 + ( 0.03 * elvl ) ) * meDmg ) + ( 0.15 * meAP )
                            stacksDmg = stacks * stackDmg
                        end
                        return baseDmg + stacksDmg
                    end,
                dmgType = "mixed"
            },
            r =
            {
                dmgAP =
                    function()
                        return (200 + ( 100 * myHero:GetSpellData(_R).level ) + myHero.ap)
                    end,
                dmgType = "ap"
            }
        },
        ["KogMaw"] =
        {
            r =
            {
                dmgAP =
                    function()
                        return 60 + ( 40 * myHero:GetSpellData(_R).level ) + myHero.ap
                    end,
                dmgType = "ap"
            }
        }
    }
    self.CalcDmg =
        function(unit, dmg, isAP)
            if unit == nil or dmg == nil or isAP == nil then return 0 end
            if dmg > 0 then
                local def = isAP and unit.magicResist - myHero.magicPen or unit.armor - myHero.armorPen
                if def > 0 then
                    def = isAP and myHero.magicPenPercent * def or myHero.bonusArmorPenPercent * def
                end
                local result = def > 0 and dmg * ( 100 / ( 100 + def ) ) or dmg * ( 2 - ( 100 / ( 100 - def ) ) )
                local unitShield = isAP and unit.shieldAP or 0
                result = result - unitShield
                return result < 0 and 0 or result
            else
                return 0
            end
        end
    self.PredHP =
        function(unit, spellData)
            if unit == nil or spellData == nil then return 0 end
            local dmgAP = spellData.dmgAP and spellData.dmgAP or 0
            local dmgAD = spellData.dmgAD and spellData.dmgAD or 0
            local dmgTrue = spellData.dmgTrue and spellData.dmgTrue or 0
            local dmgType = spellData.dmgType and spellData.dmgType or ""
            if dmgType == "ad" then
                return self.CalcDmg(unit, dmgAD, false) - unit.shieldAD
            end
            if dmgType == "ap" then
                return self.CalcDmg(unit, dmgAP, true) - unit.shieldAD
            end
            if dmgType == "true" then
                return dmgTrue - unit.shieldAD
            end
            if dmgType == "mixed" then
                return self.CalcDmg(unit, dmgAP, true) + self.CalcDmg(unit, dmgAD, false) - unit.shieldAD
            end
            return 0
        end
end

class "__gsoItems"

function __gsoItems:__init()
    self.itemList = {
        [3144] = { i = nil, hk = nil },
        [3153] = { i = nil, hk = nil }
    }
    self.lastBotrk = 0
    self.performance = 0
    Callback.Add('Tick', function() self:_tick() end)
end

function __gsoItems:_botrk(unit)
    local hkKey = nil
    if GetTickCount() < self.lastBotrk + 1000 then return false end
    local itmSlot1 = self.itemList[3144].i
    local itmSlot2 = self.itemList[3153].i
    if itmSlot1 and myHero:GetSpellData(itmSlot1).currentCd == 0 then
        hkKey = self.itemList[3144].hk
    elseif itmSlot2 and myHero:GetSpellData(itmSlot2).currentCd == 0 then
        hkKey = self.itemList[3153].hk
    end
    if hkKey and gsoAIO.Menu.menu.orb.keys.combo:Value() and gsoAIO.Menu.menu.gsoitem.botrk:Value() then
        local unitPos = unit.pos
        if gsoAIO.Utils:_getDistance(myHero.pos, unitPos) < 520 then
            local cPos = cursorPos
            Control.SetCursorPos(unitPos)
            gsoAIO.Orb.setCursor = unitPos
            Control.KeyDown(hkKey)
            Control.KeyUp(hkKey)
            gsoAIO.Items.lastBotrk = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end

function __gsoItems:_tick()
    local getTick = GetTickCount()
    if getTick > self.performance + 500 then
        self.performance = GetTickCount()
        local t = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7 }
        local t2 = { [3153] = 0, [3144] = 0 }
        for i = 1, #t do
            local item = t[i]
            local itemID = myHero:GetItemData(item).itemID
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
end

class "__gsoMenu"

function __gsoMenu:__init()
    self.Icons = {
        ["arrow"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png",
        ["botrk"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/botrk.png",
        ["circles"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/circles.png",
        ["gsoaio"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gsoaio.png",
        ["item"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/item.png",
        ["orb"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orb.png",
        ["timer"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/timer.png",
        ["ts"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ts.png",
        ["mpotion"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/mpotion.png",
        ["aatrox"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/aatrox.png",
        ["ahri"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ahri.png",
        ["akali"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/akali.png",
        ["alistar"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/alistar.png",
        ["amumu"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/amumu.png",
        ["anivia"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/anivia.png",
        ["annie"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/annie.png",
        ["ashe"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ashe.png",
        ["aurelionsol"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/aurelionsol.png",
        ["azir"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/azir.png",
        ["bard"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/bard.png",
        ["blitzcrank"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/blitzcrank.png",
        ["brand"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/brand.png",
        ["braum"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/braum.png",
        ["caitlyn"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/caitlyn.png",
        ["camille"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/camille.png",
        ["cassiopeia"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/cassiopeia.png",
        ["chogath"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/chogath.png",
        ["corki"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/corki.png",
        ["darius"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/darius.png",
        ["diana"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/diana.png",
        ["drmundo"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/drmundo.png",
        ["draven"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/draven.png",
        ["ekko"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ekko.png",
        ["elise"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/elise.png",
        ["evelynn"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/evelynn.png",
        ["ezreal"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ezreal.png",
        ["fiddlesticks"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/fiddlesticks.png",
        ["fiora"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/fiora.png",
        ["fizz"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/fizz.png",
        ["galio"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/galio.png",
        ["gangplank"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gangplank.png",
        ["garen"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/garen.png",
        ["gnar"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gnar.png",
        ["gragas"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gragas.png",
        ["graves"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/graves.png",
        ["hecarim"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/hecarim.png",
        ["heimerdinger"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/heimerdinger.png",
        ["illaoi"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/illaoi.png",
        ["irelia"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/irelia.png",
        ["ivern"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ivern.png",
        ["janna"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/janna.png",
        ["jarvaniv"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/jarvaniv.png",
        ["jax"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/jax.png",
        ["jayce"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/jayce.png",
        ["jhin"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/jhin.png",
        ["jinx"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/jinx.png",
        ["kalista"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kalista.png",
        ["karma"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/karma.png",
        ["karthus"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/karthus.png",
        ["kassadin"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kassadin.png",
        ["katarina"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/katarina.png",
        ["kayle"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kayle.png",
        ["kayn"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kayn.png",
        ["kennen"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kennen.png",
        ["khazix"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/khazix.png",
        ["kindred"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kindred.png",
        ["kled"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kled.png",
        ["kog"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kog.png",
        ["leblanc"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/leblanc.png",
        ["leesin"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/leesin.png",
        ["leona"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/leona.png",
        ["lissandra"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/lissandra.png",
        ["lucian"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/lucian.png",
        ["lulu"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/lulu.png",
        ["lux"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/lux.png",
        ["malphite"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/malphite.png",
        ["malzahar"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/malzahar.png",
        ["maokai"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/maokai.png",
        ["masteryi"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/masteryi.png",
        ["missfortune"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/missfortune.png",
        ["monkeyking"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/monkeyking.png",
        ["mordekaiser"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/mordekaiser.png",
        ["morgana"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/morgana.png",
        ["nami"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/nami.png",
        ["nasus"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/nasus.png",
        ["nautilus"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/nautilus.png",
        ["nidalee"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/nidalee.png",
        ["nocturne"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/nocturne.png",
        ["nunu"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/nunu.png",
        ["olaf"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/olaf.png",
        ["orianna"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orianna.png",
        ["ornn"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ornn.png",
        ["pantheon"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/pantheon.png",
        ["poppy"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/poppy.png",
        ["quinn"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/quinn.png",
        ["rakan"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/rakan.png",
        ["rammus"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/rammus.png",
        ["reksai"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/reksai.png",
        ["renekton"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/renekton.png",
        ["rengar"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/rengar.png",
        ["riven"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/riven.png",
        ["rumble"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/rumble.png",
        ["ryze"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ryze.png",
        ["sejuani"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/sejuani.png",
        ["shaco"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/shaco.png",
        ["shen"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/shen.png",
        ["shyvana"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/shyvana.png",
        ["singed"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/singed.png",
        ["sion"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/sion.png",
        ["sivir"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/sivir.png",
        ["skarner"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/skarner.png",
        ["sona"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/sona.png",
        ["soraka"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/soraka.png",
        ["swain"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/swain.png",
        ["syndra"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/syndra.png",
        ["tahmkench"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/tahmkench.png",
        ["taliyah"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/taliyah.png",
        ["talon"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/talon.png",
        ["taric"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/taric.png",
        ["teemo"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/teemo.png",
        ["thresh"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/thresh.png",
        ["tristana"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/tristana.png",
        ["trundle"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/trundle.png",
        ["tryndamere"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/tryndamere.png",
        ["twistedfate"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/twistedfate.png",
        ["twitch"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/twitch.png",
        ["udyr"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/udyr.png",
        ["urgot"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/urgot.png",
        ["varus"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/varus.png",
        ["vayne"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/vayne.png",
        ["veigar"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/veigar.png",
        ["velkoz"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/velkoz.png",
        ["vi"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/vi.png",
        ["viktor"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/viktor.png",
        ["vladimir"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/vladimir.png",
        ["volibear"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/volibear.png",
        ["warwick"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/warwick.png",
        ["xayah"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/xayah.png",
        ["xerath"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/xerath.png",
        ["xinzhao"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/xinzhao.png",
        ["yasuo"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/yasuo.png",
        ["yorick"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/yorick.png",
        ["zac"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/zac.png",
        ["zed"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/zed.png",
        ["ziggs"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ziggs.png",
        ["zilean"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/zilean.png",
        ["zoe"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/zoe.png",
        ["zyra"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/zyra.png"
    }
    self.menu = MenuElement({name = "Gamsteron AIO", id = "gamsteronaio", type = MENU, leftIcon = self.Icons["gsoaio"] })
end

function __gsoMenu:_menuChamp()
    if gsoAIO.Load.meAatrox then self:_menuAatrox()
    elseif gsoAIO.Load.meAhri then self:_menuAhri()
    elseif gsoAIO.Load.meAkali then self:_menuAkali()
    elseif gsoAIO.Load.meAlistar then self:_menuAlistar()
    elseif gsoAIO.Load.meAmumu then self:_menuAmumu()
    elseif gsoAIO.Load.meAnivia then self:_menuAnivia()
    elseif gsoAIO.Load.meAnnie then self:_menuAnnie()
    elseif gsoAIO.Load.meAshe then self:_menuAshe()
    elseif gsoAIO.Load.meAurelionSol then self:_menuAurelionSol()
    elseif gsoAIO.Load.meAzir then self:_menuAzir()
    elseif gsoAIO.Load.meBard then self:_menuBard()
    elseif gsoAIO.Load.meBlitzcrank then self:_menuBlitzcrank()
    elseif gsoAIO.Load.meBrand then self:_menuBrand()
    elseif gsoAIO.Load.meBraum then self:_menuBraum()
    elseif gsoAIO.Load.meCaitlyn then self:_menuCaitlyn()
    elseif gsoAIO.Load.meCamille then self:_menuCamille()
    elseif gsoAIO.Load.meCassiopeia then self:_menuCassiopeia()
    elseif gsoAIO.Load.meChogath then self:_menuChogath()
    elseif gsoAIO.Load.meCorki then self:_menuCorki()
    elseif gsoAIO.Load.meDarius then self:_menuDarius()
    elseif gsoAIO.Load.meDiana then self:_menuDiana()
    elseif gsoAIO.Load.meDrMundo then self:_menuDrMundo()
    elseif gsoAIO.Load.meDraven then self:_menuDraven()
    elseif gsoAIO.Load.meEkko then self:_menuEkko()
    elseif gsoAIO.Load.meElise then self:_menuElise()
    elseif gsoAIO.Load.meEvelynn then self:_menuEvelynn()
    elseif gsoAIO.Load.meEzreal then self:_menuEzreal()
    elseif gsoAIO.Load.meFiddlesticks then self:_menuFiddlesticks()
    elseif gsoAIO.Load.meFiora then self:_menuFiora()
    elseif gsoAIO.Load.meFizz then self:_menuFizz()
    elseif gsoAIO.Load.meGalio then self:_menuGalio()
    elseif gsoAIO.Load.meGangplank then self:_menuGangplank()
    elseif gsoAIO.Load.meGaren then self:_menuGaren()
    elseif gsoAIO.Load.meGnar then self:_menuGnar()
    elseif gsoAIO.Load.meGragas then self:_menuGragas()
    elseif gsoAIO.Load.meGraves then self:_menuGraves()
    elseif gsoAIO.Load.meHecarim then self:_menuHecarim()
    elseif gsoAIO.Load.meHeimerdinger then self:_menuHeimerdinger()
    elseif gsoAIO.Load.meIllaoi then self:_menuIllaoi()
    elseif gsoAIO.Load.meIrelia then self:_menuIrelia()
    elseif gsoAIO.Load.meIvern then self:_menuIvern()
    elseif gsoAIO.Load.meJanna then self:_menuJanna()
    elseif gsoAIO.Load.meJarvanIV then self:_menuJarvanIV()
    elseif gsoAIO.Load.meJax then self:_menuJax()
    elseif gsoAIO.Load.meJayce then self:_menuJayce()
    elseif gsoAIO.Load.meJhin then self:_menuJhin()
    elseif gsoAIO.Load.meJinx then self:_menuJinx()
    elseif gsoAIO.Load.meKalista then self:_menuKalista()
    elseif gsoAIO.Load.meKarma then self:_menuKarma()
    elseif gsoAIO.Load.meKarthus then self:_menuKarthus()
    elseif gsoAIO.Load.meKassadin then self:_menuKassadin()
    elseif gsoAIO.Load.meKatarina then self:_menuKatarina()
    elseif gsoAIO.Load.meKayle then self:_menuKayle()
    elseif gsoAIO.Load.meKayn then self:_menuKayn()
    elseif gsoAIO.Load.meKennen then self:_menuKennen()
    elseif gsoAIO.Load.meKhazix then self:_menuKhazix()
    elseif gsoAIO.Load.meKindred then self:_menuKindred()
    elseif gsoAIO.Load.meKled then self:_menuKled()
    elseif gsoAIO.Load.meKogMaw then self:_menuKogMaw()
    elseif gsoAIO.Load.meLeblanc then self:_menuLeblanc()
    elseif gsoAIO.Load.meLeeSin then self:_menuLeeSin()
    elseif gsoAIO.Load.meLeona then self:_menuLeona()
    elseif gsoAIO.Load.meLissandra then self:_menuLissandra()
    elseif gsoAIO.Load.meLucian then self:_menuLucian()
    elseif gsoAIO.Load.meLulu then self:_menuLulu()
    elseif gsoAIO.Load.meLux then self:_menuLux()
    elseif gsoAIO.Load.meMalphite then self:_menuMalphite()
    elseif gsoAIO.Load.meMalzahar then self:_menuMalzahar()
    elseif gsoAIO.Load.meMaokai then self:_menuMaokai()
    elseif gsoAIO.Load.meMasterYi then self:_menuMasterYi()
    elseif gsoAIO.Load.meMissFortune then self:_menuMissFortune()
    elseif gsoAIO.Load.meMonkeyKing then self:_menuMonkeyKing()
    elseif gsoAIO.Load.meMordekaiser then self:_menuMordekaiser()
    elseif gsoAIO.Load.meMorgana then self:_menuMorgana()
    elseif gsoAIO.Load.meNami then self:_menuNami()
    elseif gsoAIO.Load.meNasus then self:_menuNasus()
    elseif gsoAIO.Load.meNautilus then self:_menuNautilus()
    elseif gsoAIO.Load.meNidalee then self:_menuNidalee()
    elseif gsoAIO.Load.meNocturne then self:_menuNocturne()
    elseif gsoAIO.Load.meNunu then self:_menuNunu()
    elseif gsoAIO.Load.meOlaf then self:_menuOlaf()
    elseif gsoAIO.Load.meOrianna then self:_menuOrianna()
    elseif gsoAIO.Load.meOrnn then self:_menuOrnn()
    elseif gsoAIO.Load.mePantheon then self:_menuPantheon()
    elseif gsoAIO.Load.mePoppy then self:_menuPoppy()
    elseif gsoAIO.Load.meQuinn then self:_menuQuinn()
    elseif gsoAIO.Load.meRakan then self:_menuRakan()
    elseif gsoAIO.Load.meRammus then self:_menuRammus()
    elseif gsoAIO.Load.meRekSai then self:_menuRekSai()
    elseif gsoAIO.Load.meRenekton then self:_menuRenekton()
    elseif gsoAIO.Load.meRengar then self:_menuRengar()
    elseif gsoAIO.Load.meRiven then self:_menuRiven()
    elseif gsoAIO.Load.meRumble then self:_menuRumble()
    elseif gsoAIO.Load.meRyze then self:_menuRyze()
    elseif gsoAIO.Load.meSejuani then self:_menuSejuani()
    elseif gsoAIO.Load.meShaco then self:_menuShaco()
    elseif gsoAIO.Load.meShen then self:_menuShen()
    elseif gsoAIO.Load.meShyvana then self:_menuShyvana()
    elseif gsoAIO.Load.meSinged then self:_menuSinged()
    elseif gsoAIO.Load.meSion then self:_menuSion()
    elseif gsoAIO.Load.meSivir then self:_menuSivir()
    elseif gsoAIO.Load.meSkarner then self:_menuSkarner()
    elseif gsoAIO.Load.meSona then self:_menuSona()
    elseif gsoAIO.Load.meSoraka then self:_menuSoraka()
    elseif gsoAIO.Load.meSwain then self:_menuSwain()
    elseif gsoAIO.Load.meSyndra then self:_menuSyndra()
    elseif gsoAIO.Load.meTahmKench then self:_menuTahmKench()
    elseif gsoAIO.Load.meTaliyah then self:_menuTaliyah()
    elseif gsoAIO.Load.meTalon then self:_menuTalon()
    elseif gsoAIO.Load.meTaric then self:_menuTaric()
    elseif gsoAIO.Load.meTeemo then self:_menuTeemo()
    elseif gsoAIO.Load.meThresh then self:_menuThresh()
    elseif gsoAIO.Load.meTristana then self:_menuTristana()
    elseif gsoAIO.Load.meTrundle then self:_menuTrundle()
    elseif gsoAIO.Load.meTryndamere then self:_menuTryndamere()
    elseif gsoAIO.Load.meTwistedFate then self:_menuTwistedFate()
    elseif gsoAIO.Load.meTwitch then self:_menuTwitch()
    elseif gsoAIO.Load.meUdyr then self:_menuUdyr()
    elseif gsoAIO.Load.meUrgot then self:_menuUrgot()
    elseif gsoAIO.Load.meVarus then self:_menuVarus()
    elseif gsoAIO.Load.meVayne then self:_menuVayne()
    elseif gsoAIO.Load.meVeigar then self:_menuVeigar()
    elseif gsoAIO.Load.meVelkoz then self:_menuVelkoz()
    elseif gsoAIO.Load.meVi then self:_menuVi()
    elseif gsoAIO.Load.meViktor then self:_menuViktor()
    elseif gsoAIO.Load.meVladimir then self:_menuVladimir()
    elseif gsoAIO.Load.meVolibear then self:_menuVolibear()
    elseif gsoAIO.Load.meWarwick then self:_menuWarwick()
    elseif gsoAIO.Load.meXayah then self:_menuXayah()
    elseif gsoAIO.Load.meXerath then self:_menuXerath()
    elseif gsoAIO.Load.meXinZhao then self:_menuXinZhao()
    elseif gsoAIO.Load.meYasuo then self:_menuYasuo()
    elseif gsoAIO.Load.meYorick then self:_menuYorick()
    elseif gsoAIO.Load.meZac then self:_menuZac()
    elseif gsoAIO.Load.meZed then self:_menuZed()
    elseif gsoAIO.Load.meZiggs then self:_menuZiggs()
    elseif gsoAIO.Load.meZilean then self:_menuZilean()
    elseif gsoAIO.Load.meZoe then self:_menuZoe()
    elseif gsoAIO.Load.meZyra then self:_menuZyra() end
end

function __gsoMenu:_menuAatrox()
    self.menu:MenuElement({name = "Aatrox", id = "gsoaatrox", type = MENU, leftIcon = self.Icons["aatrox"] })
        self.menu.gsoaatrox:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoaatrox.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoaatrox.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoaatrox:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoaatrox.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoaatrox.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoaatrox:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoaatrox.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoaatrox.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoaatrox:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoaatrox.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoaatrox.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuAhri()
    self.menu:MenuElement({name = "Ahri", id = "gsoahri", type = MENU, leftIcon = self.Icons["ahri"] })
        self.menu.gsoahri:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoahri.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoahri.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoahri:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoahri.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoahri.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoahri:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoahri.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoahri.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoahri:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoahri.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoahri.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuAkali()
    self.menu:MenuElement({name = "Akali", id = "gsoakali", type = MENU, leftIcon = self.Icons["akali"] })
        self.menu.gsoakali:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoakali.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoakali.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoakali:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoakali.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoakali.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoakali:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoakali.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoakali.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoakali:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoakali.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoakali.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuAlistar()
    self.menu:MenuElement({name = "Alistar", id = "gsoalistar", type = MENU, leftIcon = self.Icons["alistar"] })
        self.menu.gsoalistar:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoalistar.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoalistar.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoalistar:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoalistar.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoalistar.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoalistar:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoalistar.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoalistar.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoalistar:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoalistar.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoalistar.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuAmumu()
    self.menu:MenuElement({name = "Amumu", id = "gsoamumu", type = MENU, leftIcon = self.Icons["amumu"] })
        self.menu.gsoamumu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoamumu.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoamumu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoamumu:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoamumu.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoamumu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoamumu:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoamumu.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoamumu.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoamumu:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoamumu.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoamumu.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuAnivia()
    self.menu:MenuElement({name = "Anivia", id = "gsoanivia", type = MENU, leftIcon = self.Icons["anivia"] })
        self.menu.gsoanivia:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoanivia.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoanivia.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoanivia:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoanivia.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoanivia.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoanivia:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoanivia.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoanivia.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoanivia:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoanivia.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoanivia.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuAnnie()
    self.menu:MenuElement({name = "Annie", id = "gsoannie", type = MENU, leftIcon = self.Icons["annie"] })
        self.menu.gsoannie:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoannie.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoannie.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoannie:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoannie.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoannie.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoannie:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoannie.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoannie.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoannie:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoannie.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoannie.rset:MenuElement({id = "harass", name = "Harass", value = false})
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
            self.menu.gsoashe.rset:MenuElement({name = "R Semi Manual", id = "semirashe", type = MENU })
                self.menu.gsoashe.rset.semirashe:MenuElement({name = "Semi-Manual Key", id = "enabled", key = string.byte("T")})
                self.menu.gsoashe.rset.semirashe:MenuElement({name = "Only enemies with HP < X%", id = "semilow", value = true})
                self.menu.gsoashe.rset.semirashe:MenuElement({name = "X %", id = "semip", value = 100, min = 1, max = 100, step = 1 })
                self.menu.gsoashe.rset.semirashe:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
                self.menu.gsoashe.rset.semirashe:MenuElement({name = "Use on:", id = "useon", type = MENU })
end

function __gsoMenu:_menuAurelionSol()
    self.menu:MenuElement({name = "AurelionSol", id = "gsoaurelionsol", type = MENU, leftIcon = self.Icons["aurelionsol"] })
        self.menu.gsoaurelionsol:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoaurelionsol.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoaurelionsol.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoaurelionsol:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoaurelionsol.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoaurelionsol.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoaurelionsol:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoaurelionsol.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoaurelionsol.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoaurelionsol:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoaurelionsol.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoaurelionsol.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuAzir()
    self.menu:MenuElement({name = "Azir", id = "gsoazir", type = MENU, leftIcon = self.Icons["azir"] })
        self.menu.gsoazir:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoazir.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoazir.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoazir:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoazir.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoazir.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoazir:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoazir.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoazir.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoazir:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoazir.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoazir.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuBard()
    self.menu:MenuElement({name = "Bard", id = "gsobard", type = MENU, leftIcon = self.Icons["bard"] })
        self.menu.gsobard:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsobard.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobard.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsobard:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsobard.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobard.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsobard:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsobard.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobard.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsobard:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsobard.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobard.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuBlitzcrank()
    self.menu:MenuElement({name = "Blitzcrank", id = "gsoblitzcrank", type = MENU, leftIcon = self.Icons["blitzcrank"] })
        self.menu.gsoblitzcrank:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoblitzcrank.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoblitzcrank.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoblitzcrank:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoblitzcrank.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoblitzcrank.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoblitzcrank:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoblitzcrank.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoblitzcrank.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoblitzcrank:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoblitzcrank.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoblitzcrank.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuBrand()
    self.menu:MenuElement({name = "Brand", id = "gsobrand", type = MENU, leftIcon = self.Icons["brand"] })
        self.menu.gsobrand:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsobrand.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobrand.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsobrand:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsobrand.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobrand.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsobrand:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsobrand.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobrand.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsobrand:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsobrand.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobrand.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuBraum()
    self.menu:MenuElement({name = "Braum", id = "gsobraum", type = MENU, leftIcon = self.Icons["braum"] })
        self.menu.gsobraum:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsobraum.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobraum.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsobraum:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsobraum.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobraum.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsobraum:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsobraum.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobraum.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsobraum:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsobraum.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsobraum.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuCaitlyn()
    self.menu:MenuElement({name = "Caitlyn", id = "gsocaitlyn", type = MENU, leftIcon = self.Icons["caitlyn"] })
        self.menu.gsocaitlyn:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsocaitlyn.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocaitlyn.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocaitlyn:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsocaitlyn.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocaitlyn.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocaitlyn:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsocaitlyn.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocaitlyn.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocaitlyn:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsocaitlyn.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocaitlyn.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuCamille()
    self.menu:MenuElement({name = "Camille", id = "gsocamille", type = MENU, leftIcon = self.Icons["camille"] })
        self.menu.gsocamille:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsocamille.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocamille.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocamille:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsocamille.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocamille.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocamille:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsocamille.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocamille.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocamille:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsocamille.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocamille.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuCassiopeia()
    self.menu:MenuElement({name = "Cassiopeia", id = "gsocassiopeia", type = MENU, leftIcon = self.Icons["cassiopeia"] })
        self.menu.gsocassiopeia:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsocassiopeia.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocassiopeia.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocassiopeia:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsocassiopeia.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocassiopeia.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocassiopeia:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsocassiopeia.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocassiopeia.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocassiopeia:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsocassiopeia.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocassiopeia.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuChogath()
    self.menu:MenuElement({name = "Chogath", id = "gsochogath", type = MENU, leftIcon = self.Icons["chogath"] })
        self.menu.gsochogath:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsochogath.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsochogath.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsochogath:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsochogath.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsochogath.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsochogath:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsochogath.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsochogath.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsochogath:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsochogath.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsochogath.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuCorki()
    self.menu:MenuElement({name = "Corki", id = "gsocorki", type = MENU, leftIcon = self.Icons["corki"] })
        self.menu.gsocorki:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsocorki.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocorki.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocorki:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsocorki.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocorki.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocorki:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsocorki.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocorki.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsocorki:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsocorki.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsocorki.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuDarius()
    self.menu:MenuElement({name = "Darius", id = "gsodarius", type = MENU, leftIcon = self.Icons["darius"] })
        self.menu.gsodarius:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsodarius.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodarius.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodarius:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsodarius.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodarius.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodarius:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsodarius.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodarius.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodarius:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsodarius.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodarius.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuDiana()
    self.menu:MenuElement({name = "Diana", id = "gsodiana", type = MENU, leftIcon = self.Icons["diana"] })
        self.menu.gsodiana:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsodiana.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodiana.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodiana:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsodiana.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodiana.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodiana:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsodiana.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodiana.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodiana:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsodiana.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodiana.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuDrMundo()
    self.menu:MenuElement({name = "DrMundo", id = "gsodrmundo", type = MENU, leftIcon = self.Icons["drmundo"] })
        self.menu.gsodrmundo:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsodrmundo.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodrmundo.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodrmundo:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsodrmundo.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodrmundo.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodrmundo:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsodrmundo.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodrmundo.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsodrmundo:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsodrmundo.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsodrmundo.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuDraven()
    self.menu:MenuElement({name = "Draven", id = "gsodraven", type = MENU, leftIcon = self.Icons["draven"] })
        self.menu.gsodraven:MenuElement({name = "AXE settings", id = "aset", type = MENU })
            self.menu.gsodraven.aset:MenuElement({id = "stopmove", name = "Hold radius", value = 100, min = 100, max = 125, step = 5 })
            self.menu.gsodraven.aset:MenuElement({id = "cdist", name = "distance from axe to cursor", value = 750, min = 500, max = 1500, step = 50 })
            self.menu.gsodraven.aset:MenuElement({id = "catch", name = "Catch axes", value = true})
            self.menu.gsodraven.aset:MenuElement({id = "catcht", name = "stop under turret", value = true})
            self.menu.gsodraven.aset:MenuElement({id = "catcho", name = "[combo] stop if no enemy in range", value = true})
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
            self.menu.gsodraven.rset:MenuElement({name = "Semi Manual", id = "semirdraven", type = MENU })
                self.menu.gsodraven.rset.semirdraven:MenuElement({name = "Semi-Manual Key", id = "enabled", key = string.byte("T")})
                self.menu.gsodraven.rset.semirdraven:MenuElement({name = "Only enemies with HP < X%", id = "semilow", value = true})
                self.menu.gsodraven.rset.semirdraven:MenuElement({name = "X %", id = "semip", value = 35, min = 1, max = 100, step = 1 })
                self.menu.gsodraven.rset.semirdraven:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
                self.menu.gsodraven.rset.semirdraven:MenuElement({name = "Use on:", id = "useon", type = MENU })
end

function __gsoMenu:_menuEkko()
    self.menu:MenuElement({name = "Ekko", id = "gsoekko", type = MENU, leftIcon = self.Icons["ekko"] })
        self.menu.gsoekko:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoekko.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoekko.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoekko:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoekko.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoekko.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoekko:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoekko.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoekko.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoekko:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoekko.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoekko.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuElise()
    self.menu:MenuElement({name = "Elise", id = "gsoelise", type = MENU, leftIcon = self.Icons["elise"] })
        self.menu.gsoelise:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoelise.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoelise.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoelise:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoelise.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoelise.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoelise:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoelise.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoelise.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoelise:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoelise.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoelise.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuEvelynn()
    self.menu:MenuElement({name = "Evelynn", id = "gsoevelynn", type = MENU, leftIcon = self.Icons["evelynn"] })
        self.menu.gsoevelynn:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoevelynn.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoevelynn.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoevelynn:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoevelynn.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoevelynn.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoevelynn:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoevelynn.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoevelynn.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoevelynn:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoevelynn.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoevelynn.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuEzreal()
    self.menu:MenuElement({name = "Ezreal", id = "gsoezreal", type = MENU, leftIcon = self.Icons["ezreal"] })
        self.menu.gsoezreal:MenuElement({name = "Auto Q", id = "autoq", type = MENU })
            self.menu.gsoezreal.autoq:MenuElement({id = "enable", name = "Enable", value = true, key = string.byte("T"), toggle = true})
            self.menu.gsoezreal.autoq:MenuElement({id = "autoqout", name = "Only if enemy out of attack range", value = true})
            self.menu.gsoezreal.autoq:MenuElement({id = "mana", name = "Q Auto min. mana percent", value = 50, min = 0, max = 100, step = 1 })
            self.menu.gsoezreal.autoq:MenuElement({name = "Use on:", id = "useon", type = MENU })
        self.menu.gsoezreal:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoezreal.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoezreal.qset:MenuElement({id = "harass", name = "Harass", value = false})
            self.menu.gsoezreal.qset:MenuElement({id = "laneclear", name = "LaneClear", value = false})
            self.menu.gsoezreal.qset:MenuElement({id = "lasthit", name = "LastHit", value = true})
            self.menu.gsoezreal.qset:MenuElement({id = "qout", name = "Only if enemy out of attack range", value = false})
            self.menu.gsoezreal.qset:MenuElement({id = "qlh", name = "Q LastHit min. mana percent", value = 10, min = 0, max = 100, step = 1 })
            self.menu.gsoezreal.qset:MenuElement({id = "qlc", name = "Q LaneClear min. mana percent", value = 50, min = 0, max = 100, step = 1 })
        self.menu.gsoezreal:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoezreal.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoezreal.wset:MenuElement({id = "harass", name = "Harass", value = false})
            self.menu.gsoezreal.wset:MenuElement({id = "wout", name = "Only if enemy out of attack range", value = false})
        self.menu.gsoezreal:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoezreal.rset:MenuElement({name = "Semi Manual", id = "semirez", type = MENU })
                self.menu.gsoezreal.rset.semirez:MenuElement({name = "Semi-Manual Key", id = "enabled", key = string.byte("T")})
                self.menu.gsoezreal.rset.semirez:MenuElement({name = "Only enemies with HP < X%", id = "semilow", value = true})
                self.menu.gsoezreal.rset.semirez:MenuElement({name = "X %", id = "semip", value = 35, min = 1, max = 100, step = 1 })
                self.menu.gsoezreal.rset.semirez:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
                self.menu.gsoezreal.rset.semirez:MenuElement({name = "Use on:", id = "useon", type = MENU })
end

function __gsoMenu:_menuFiddlesticks()
    self.menu:MenuElement({name = "Fiddlesticks", id = "gsofiddlesticks", type = MENU, leftIcon = self.Icons["fiddlesticks"] })
        self.menu.gsofiddlesticks:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsofiddlesticks.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofiddlesticks.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsofiddlesticks:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsofiddlesticks.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofiddlesticks.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsofiddlesticks:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsofiddlesticks.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofiddlesticks.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsofiddlesticks:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsofiddlesticks.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofiddlesticks.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuFiora()
    self.menu:MenuElement({name = "Fiora", id = "gsofiora", type = MENU, leftIcon = self.Icons["fiora"] })
        self.menu.gsofiora:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsofiora.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofiora.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsofiora:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsofiora.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofiora.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsofiora:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsofiora.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofiora.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsofiora:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsofiora.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofiora.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuFizz()
    self.menu:MenuElement({name = "Fizz", id = "gsofizz", type = MENU, leftIcon = self.Icons["fizz"] })
        self.menu.gsofizz:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsofizz.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofizz.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsofizz:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsofizz.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofizz.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsofizz:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsofizz.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofizz.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsofizz:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsofizz.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsofizz.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuGalio()
    self.menu:MenuElement({name = "Galio", id = "gsogalio", type = MENU, leftIcon = self.Icons["galio"] })
        self.menu.gsogalio:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsogalio.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogalio.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogalio:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsogalio.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogalio.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogalio:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsogalio.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogalio.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogalio:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsogalio.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogalio.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuGangplank()
    self.menu:MenuElement({name = "Gangplank", id = "gsogangplank", type = MENU, leftIcon = self.Icons["gangplank"] })
        self.menu.gsogangplank:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsogangplank.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogangplank.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogangplank:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsogangplank.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogangplank.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogangplank:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsogangplank.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogangplank.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogangplank:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsogangplank.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogangplank.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuGaren()
    self.menu:MenuElement({name = "Garen", id = "gsogaren", type = MENU, leftIcon = self.Icons["garen"] })
        self.menu.gsogaren:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsogaren.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogaren.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogaren:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsogaren.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogaren.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogaren:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsogaren.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogaren.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogaren:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsogaren.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogaren.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuGnar()
    self.menu:MenuElement({name = "Gnar", id = "gsognar", type = MENU, leftIcon = self.Icons["gnar"] })
        self.menu.gsognar:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsognar.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsognar.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsognar:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsognar.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsognar.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsognar:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsognar.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsognar.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsognar:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsognar.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsognar.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuGragas()
    self.menu:MenuElement({name = "Gragas", id = "gsogragas", type = MENU, leftIcon = self.Icons["gragas"] })
        self.menu.gsogragas:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsogragas.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogragas.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogragas:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsogragas.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogragas.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogragas:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsogragas.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogragas.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsogragas:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsogragas.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsogragas.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuGraves()
    self.menu:MenuElement({name = "Graves", id = "gsograves", type = MENU, leftIcon = self.Icons["graves"] })
        self.menu.gsograves:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsograves.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsograves.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsograves:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsograves.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsograves.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsograves:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsograves.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsograves.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsograves:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsograves.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsograves.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuHecarim()
    self.menu:MenuElement({name = "Hecarim", id = "gsohecarim", type = MENU, leftIcon = self.Icons["hecarim"] })
        self.menu.gsohecarim:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsohecarim.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsohecarim.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsohecarim:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsohecarim.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsohecarim.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsohecarim:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsohecarim.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsohecarim.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsohecarim:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsohecarim.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsohecarim.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuHeimerdinger()
    self.menu:MenuElement({name = "Heimerdinger", id = "gsoheimerdinger", type = MENU, leftIcon = self.Icons["heimerdinger"] })
        self.menu.gsoheimerdinger:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoheimerdinger.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoheimerdinger.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoheimerdinger:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoheimerdinger.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoheimerdinger.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoheimerdinger:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoheimerdinger.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoheimerdinger.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoheimerdinger:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoheimerdinger.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoheimerdinger.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuIllaoi()
    self.menu:MenuElement({name = "Illaoi", id = "gsoillaoi", type = MENU, leftIcon = self.Icons["illaoi"] })
        self.menu.gsoillaoi:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoillaoi.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoillaoi.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoillaoi:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoillaoi.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoillaoi.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoillaoi:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoillaoi.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoillaoi.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoillaoi:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoillaoi.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoillaoi.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuIrelia()
    self.menu:MenuElement({name = "Irelia", id = "gsoirelia", type = MENU, leftIcon = self.Icons["irelia"] })
        self.menu.gsoirelia:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoirelia.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoirelia.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoirelia:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoirelia.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoirelia.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoirelia:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoirelia.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoirelia.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoirelia:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoirelia.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoirelia.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuIvern()
    self.menu:MenuElement({name = "Ivern", id = "gsoivern", type = MENU, leftIcon = self.Icons["ivern"] })
        self.menu.gsoivern:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoivern.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoivern.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoivern:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoivern.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoivern.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoivern:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoivern.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoivern.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoivern:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoivern.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoivern.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuJanna()
    self.menu:MenuElement({name = "Janna", id = "gsojanna", type = MENU, leftIcon = self.Icons["janna"] })
        self.menu.gsojanna:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsojanna.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojanna.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojanna:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsojanna.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojanna.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojanna:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsojanna.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojanna.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojanna:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsojanna.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojanna.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuJarvanIV()
    self.menu:MenuElement({name = "JarvanIV", id = "gsojarvaniv", type = MENU, leftIcon = self.Icons["jarvaniv"] })
        self.menu.gsojarvaniv:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsojarvaniv.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojarvaniv.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojarvaniv:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsojarvaniv.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojarvaniv.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojarvaniv:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsojarvaniv.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojarvaniv.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojarvaniv:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsojarvaniv.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojarvaniv.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuJax()
    self.menu:MenuElement({name = "Jax", id = "gsojax", type = MENU, leftIcon = self.Icons["jax"] })
        self.menu.gsojax:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsojax.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojax.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojax:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsojax.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojax.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojax:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsojax.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojax.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojax:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsojax.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojax.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuJayce()
    self.menu:MenuElement({name = "Jayce", id = "gsojayce", type = MENU, leftIcon = self.Icons["jayce"] })
        self.menu.gsojayce:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsojayce.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojayce.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojayce:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsojayce.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojayce.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojayce:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsojayce.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojayce.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojayce:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsojayce.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojayce.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuJhin()
    self.menu:MenuElement({name = "Jhin", id = "gsojhin", type = MENU, leftIcon = self.Icons["jhin"] })
        self.menu.gsojhin:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsojhin.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojhin.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojhin:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsojhin.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojhin.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojhin:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsojhin.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojhin.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsojhin:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsojhin.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsojhin.rset:MenuElement({id = "harass", name = "Harass", value = false})
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
            self.menu.gsojinx.rset:MenuElement({name = "Semi Manual", id = "semirjinx", type = MENU })
                self.menu.gsojinx.rset.semirjinx:MenuElement({name = "Semi-Manual Key", id = "enabled", key = string.byte("T")})
                self.menu.gsojinx.rset.semirjinx:MenuElement({name = "Only enemies with HP < X%", id = "semilow",  value = true})
                self.menu.gsojinx.rset.semirjinx:MenuElement({name = "X %", id = "semip", value = 35, min = 1, max = 100, step = 1 })
                self.menu.gsojinx.rset.semirjinx:MenuElement({name = "Semi-Manual Max. Range", id = "rrange", value = 2000, min = 1000, max = 15000, step = 100 })
                self.menu.gsojinx.rset.semirjinx:MenuElement({name = "Use on:", id = "useon", type = MENU })
end

function __gsoMenu:_menuKalista()
    self.menu:MenuElement({name = "Kalista", id = "gsokalista", type = MENU, leftIcon = self.Icons["kalista"] })
        self.menu.gsokalista:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokalista.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokalista.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokalista:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokalista.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokalista.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokalista:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokalista.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokalista.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokalista:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokalista.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokalista.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKarma()
    self.menu:MenuElement({name = "Karma", id = "gsokarma", type = MENU, leftIcon = self.Icons["karma"] })
        self.menu.gsokarma:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokarma.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokarma.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokarma:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokarma.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokarma.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokarma:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokarma.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokarma.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokarma:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokarma.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokarma.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKarthus()
    self.menu:MenuElement({name = "Karthus", id = "gsokarthus", type = MENU, leftIcon = self.Icons["karthus"] })
        self.menu.gsokarthus:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokarthus.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokarthus.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokarthus:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokarthus.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokarthus.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokarthus:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokarthus.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokarthus.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokarthus:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokarthus.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokarthus.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKassadin()
    self.menu:MenuElement({name = "Kassadin", id = "gsokassadin", type = MENU, leftIcon = self.Icons["kassadin"] })
        self.menu.gsokassadin:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokassadin.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokassadin.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokassadin:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokassadin.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokassadin.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokassadin:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokassadin.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokassadin.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokassadin:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokassadin.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokassadin.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKatarina()
    self.menu:MenuElement({name = "Katarina", id = "gsokatarina", type = MENU, leftIcon = self.Icons["katarina"] })
        self.menu.gsokatarina:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokatarina.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokatarina.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokatarina:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokatarina.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokatarina.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokatarina:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokatarina.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokatarina.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokatarina:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokatarina.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokatarina.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKayle()
    self.menu:MenuElement({name = "Kayle", id = "gsokayle", type = MENU, leftIcon = self.Icons["kayle"] })
        self.menu.gsokayle:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokayle.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokayle.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokayle:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokayle.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokayle.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokayle:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokayle.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokayle.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokayle:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokayle.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokayle.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKayn()
    self.menu:MenuElement({name = "Kayn", id = "gsokayn", type = MENU, leftIcon = self.Icons["kayn"] })
        self.menu.gsokayn:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokayn.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokayn.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokayn:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokayn.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokayn.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokayn:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokayn.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokayn.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokayn:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokayn.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokayn.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKennen()
    self.menu:MenuElement({name = "Kennen", id = "gsokennen", type = MENU, leftIcon = self.Icons["kennen"] })
        self.menu.gsokennen:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokennen.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokennen.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokennen:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokennen.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokennen.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokennen:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokennen.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokennen.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokennen:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokennen.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokennen.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKhazix()
    self.menu:MenuElement({name = "Khazix", id = "gsokhazix", type = MENU, leftIcon = self.Icons["khazix"] })
        self.menu.gsokhazix:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokhazix.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokhazix.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokhazix:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokhazix.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokhazix.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokhazix:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokhazix.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokhazix.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokhazix:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokhazix.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokhazix.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKindred()
    self.menu:MenuElement({name = "Kindred", id = "gsokindred", type = MENU, leftIcon = self.Icons["kindred"] })
        self.menu.gsokindred:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokindred.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokindred.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokindred:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokindred.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokindred.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokindred:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokindred.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokindred.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokindred:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokindred.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokindred.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKled()
    self.menu:MenuElement({name = "Kled", id = "gsokled", type = MENU, leftIcon = self.Icons["kled"] })
        self.menu.gsokled:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsokled.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokled.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokled:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsokled.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokled.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokled:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsokled.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokled.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsokled:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsokled.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsokled.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuKogMaw()
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

function __gsoMenu:_menuLeblanc()
    self.menu:MenuElement({name = "Leblanc", id = "gsoleblanc", type = MENU, leftIcon = self.Icons["leblanc"] })
        self.menu.gsoleblanc:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoleblanc.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleblanc.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoleblanc:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoleblanc.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleblanc.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoleblanc:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoleblanc.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleblanc.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoleblanc:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoleblanc.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleblanc.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuLeeSin()
    self.menu:MenuElement({name = "LeeSin", id = "gsoleesin", type = MENU, leftIcon = self.Icons["leesin"] })
        self.menu.gsoleesin:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoleesin.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleesin.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoleesin:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoleesin.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleesin.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoleesin:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoleesin.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleesin.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoleesin:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoleesin.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleesin.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuLeona()
    self.menu:MenuElement({name = "Leona", id = "gsoleona", type = MENU, leftIcon = self.Icons["leona"] })
        self.menu.gsoleona:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoleona.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleona.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoleona:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoleona.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleona.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoleona:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoleona.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleona.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoleona:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoleona.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoleona.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuLissandra()
    self.menu:MenuElement({name = "Lissandra", id = "gsolissandra", type = MENU, leftIcon = self.Icons["lissandra"] })
        self.menu.gsolissandra:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsolissandra.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolissandra.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolissandra:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsolissandra.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolissandra.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolissandra:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsolissandra.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolissandra.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolissandra:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsolissandra.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolissandra.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuLucian()
    self.menu:MenuElement({name = "Lucian", id = "gsolucian", type = MENU, leftIcon = self.Icons["lucian"] })
        self.menu.gsolucian:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsolucian.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolucian.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolucian:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsolucian.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolucian.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolucian:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsolucian.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolucian.eset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuLulu()
    self.menu:MenuElement({name = "Lulu", id = "gsolulu", type = MENU, leftIcon = self.Icons["lulu"] })
        self.menu.gsolulu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsolulu.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolulu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolulu:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsolulu.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolulu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolulu:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsolulu.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolulu.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolulu:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsolulu.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolulu.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuLux()
    self.menu:MenuElement({name = "Lux", id = "gsolux", type = MENU, leftIcon = self.Icons["lux"] })
        self.menu.gsolux:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsolux.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolux.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolux:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsolux.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolux.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolux:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsolux.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolux.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsolux:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsolux.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsolux.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuMalphite()
    self.menu:MenuElement({name = "Malphite", id = "gsomalphite", type = MENU, leftIcon = self.Icons["malphite"] })
        self.menu.gsomalphite:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsomalphite.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomalphite.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomalphite:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsomalphite.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomalphite.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomalphite:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsomalphite.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomalphite.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomalphite:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsomalphite.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomalphite.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuMalzahar()
    self.menu:MenuElement({name = "Malzahar", id = "gsomalzahar", type = MENU, leftIcon = self.Icons["malzahar"] })
        self.menu.gsomalzahar:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsomalzahar.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomalzahar.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomalzahar:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsomalzahar.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomalzahar.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomalzahar:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsomalzahar.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomalzahar.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomalzahar:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsomalzahar.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomalzahar.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuMaokai()
    self.menu:MenuElement({name = "Maokai", id = "gsomaokai", type = MENU, leftIcon = self.Icons["maokai"] })
        self.menu.gsomaokai:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsomaokai.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomaokai.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomaokai:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsomaokai.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomaokai.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomaokai:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsomaokai.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomaokai.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomaokai:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsomaokai.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomaokai.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuMasterYi()
    self.menu:MenuElement({name = "MasterYi", id = "gsomasteryi", type = MENU, leftIcon = self.Icons["masteryi"] })
        self.menu.gsomasteryi:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsomasteryi.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomasteryi.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomasteryi:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsomasteryi.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomasteryi.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomasteryi:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsomasteryi.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomasteryi.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomasteryi:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsomasteryi.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomasteryi.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuMissFortune()
    self.menu:MenuElement({name = "MissFortune", id = "gsomissfortune", type = MENU, leftIcon = self.Icons["missfortune"] })
        self.menu.gsomissfortune:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsomissfortune.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomissfortune.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomissfortune:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsomissfortune.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomissfortune.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomissfortune:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsomissfortune.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomissfortune.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomissfortune:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsomissfortune.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomissfortune.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuMonkeyKing()
    self.menu:MenuElement({name = "MonkeyKing", id = "gsomonkeyking", type = MENU, leftIcon = self.Icons["monkeyking"] })
        self.menu.gsomonkeyking:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsomonkeyking.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomonkeyking.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomonkeyking:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsomonkeyking.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomonkeyking.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomonkeyking:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsomonkeyking.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomonkeyking.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomonkeyking:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsomonkeyking.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomonkeyking.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuMordekaiser()
    self.menu:MenuElement({name = "Mordekaiser", id = "gsomordekaiser", type = MENU, leftIcon = self.Icons["mordekaiser"] })
        self.menu.gsomordekaiser:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsomordekaiser.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomordekaiser.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomordekaiser:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsomordekaiser.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomordekaiser.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomordekaiser:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsomordekaiser.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomordekaiser.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomordekaiser:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsomordekaiser.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomordekaiser.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuMorgana()
    self.menu:MenuElement({name = "Morgana", id = "gsomorgana", type = MENU, leftIcon = self.Icons["morgana"] })
        self.menu.gsomorgana:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsomorgana.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomorgana.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomorgana:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsomorgana.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomorgana.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomorgana:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsomorgana.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomorgana.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsomorgana:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsomorgana.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsomorgana.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuNami()
    self.menu:MenuElement({name = "Nami", id = "gsonami", type = MENU, leftIcon = self.Icons["nami"] })
        self.menu.gsonami:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsonami.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonami.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonami:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsonami.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonami.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonami:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsonami.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonami.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonami:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsonami.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonami.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuNasus()
    self.menu:MenuElement({name = "Nasus", id = "gsonasus", type = MENU, leftIcon = self.Icons["nasus"] })
        self.menu.gsonasus:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsonasus.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonasus.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonasus:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsonasus.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonasus.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonasus:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsonasus.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonasus.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonasus:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsonasus.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonasus.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuNautilus()
    self.menu:MenuElement({name = "Nautilus", id = "gsonautilus", type = MENU, leftIcon = self.Icons["nautilus"] })
        self.menu.gsonautilus:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsonautilus.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonautilus.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonautilus:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsonautilus.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonautilus.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonautilus:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsonautilus.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonautilus.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonautilus:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsonautilus.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonautilus.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuNidalee()
    self.menu:MenuElement({name = "Nidalee", id = "gsonidalee", type = MENU, leftIcon = self.Icons["nidalee"] })
        self.menu.gsonidalee:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsonidalee.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonidalee.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonidalee:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsonidalee.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonidalee.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonidalee:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsonidalee.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonidalee.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonidalee:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsonidalee.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonidalee.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuNocturne()
    self.menu:MenuElement({name = "Nocturne", id = "gsonocturne", type = MENU, leftIcon = self.Icons["nocturne"] })
        self.menu.gsonocturne:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsonocturne.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonocturne.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonocturne:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsonocturne.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonocturne.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonocturne:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsonocturne.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonocturne.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonocturne:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsonocturne.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonocturne.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuNunu()
    self.menu:MenuElement({name = "Nunu", id = "gsonunu", type = MENU, leftIcon = self.Icons["nunu"] })
        self.menu.gsonunu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsonunu.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonunu.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonunu:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsonunu.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonunu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonunu:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsonunu.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonunu.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsonunu:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsonunu.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsonunu.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuOlaf()
    self.menu:MenuElement({name = "Olaf", id = "gsoolaf", type = MENU, leftIcon = self.Icons["olaf"] })
        self.menu.gsoolaf:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoolaf.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoolaf.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoolaf:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoolaf.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoolaf.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoolaf:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoolaf.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoolaf.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoolaf:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoolaf.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoolaf.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuOrianna()
    self.menu:MenuElement({name = "Orianna", id = "gsoorianna", type = MENU, leftIcon = self.Icons["orianna"] })
        self.menu.gsoorianna:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoorianna.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoorianna.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoorianna:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoorianna.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoorianna.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoorianna:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoorianna.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoorianna.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoorianna:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoorianna.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoorianna.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuOrnn()
    self.menu:MenuElement({name = "Ornn", id = "gsoornn", type = MENU, leftIcon = self.Icons["ornn"] })
        self.menu.gsoornn:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoornn.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoornn.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoornn:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoornn.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoornn.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoornn:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoornn.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoornn.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoornn:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoornn.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoornn.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuPantheon()
    self.menu:MenuElement({name = "Pantheon", id = "gsopantheon", type = MENU, leftIcon = self.Icons["pantheon"] })
        self.menu.gsopantheon:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsopantheon.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsopantheon.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsopantheon:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsopantheon.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsopantheon.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsopantheon:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsopantheon.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsopantheon.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsopantheon:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsopantheon.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsopantheon.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuPoppy()
    self.menu:MenuElement({name = "Poppy", id = "gsopoppy", type = MENU, leftIcon = self.Icons["poppy"] })
        self.menu.gsopoppy:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsopoppy.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsopoppy.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsopoppy:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsopoppy.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsopoppy.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsopoppy:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsopoppy.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsopoppy.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsopoppy:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsopoppy.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsopoppy.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuQuinn()
    self.menu:MenuElement({name = "Quinn", id = "gsoquinn", type = MENU, leftIcon = self.Icons["quinn"] })
        self.menu.gsoquinn:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoquinn.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoquinn.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoquinn:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoquinn.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoquinn.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoquinn:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoquinn.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoquinn.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoquinn:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoquinn.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoquinn.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuRakan()
    self.menu:MenuElement({name = "Rakan", id = "gsorakan", type = MENU, leftIcon = self.Icons["rakan"] })
        self.menu.gsorakan:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsorakan.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorakan.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorakan:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsorakan.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorakan.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorakan:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsorakan.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorakan.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorakan:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsorakan.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorakan.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuRammus()
    self.menu:MenuElement({name = "Rammus", id = "gsorammus", type = MENU, leftIcon = self.Icons["rammus"] })
        self.menu.gsorammus:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsorammus.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorammus.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorammus:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsorammus.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorammus.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorammus:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsorammus.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorammus.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorammus:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsorammus.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorammus.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuRekSai()
    self.menu:MenuElement({name = "RekSai", id = "gsoreksai", type = MENU, leftIcon = self.Icons["reksai"] })
        self.menu.gsoreksai:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoreksai.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoreksai.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoreksai:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoreksai.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoreksai.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoreksai:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoreksai.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoreksai.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoreksai:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoreksai.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoreksai.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuRenekton()
    self.menu:MenuElement({name = "Renekton", id = "gsorenekton", type = MENU, leftIcon = self.Icons["renekton"] })
        self.menu.gsorenekton:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsorenekton.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorenekton.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorenekton:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsorenekton.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorenekton.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorenekton:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsorenekton.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorenekton.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorenekton:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsorenekton.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorenekton.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuRengar()
    self.menu:MenuElement({name = "Rengar", id = "gsorengar", type = MENU, leftIcon = self.Icons["rengar"] })
        self.menu.gsorengar:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsorengar.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorengar.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorengar:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsorengar.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorengar.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorengar:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsorengar.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorengar.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorengar:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsorengar.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorengar.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuRiven()
    self.menu:MenuElement({name = "Riven", id = "gsoriven", type = MENU, leftIcon = self.Icons["riven"] })
        self.menu.gsoriven:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoriven.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoriven.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoriven:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoriven.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoriven.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoriven:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoriven.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoriven.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoriven:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoriven.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoriven.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuRumble()
    self.menu:MenuElement({name = "Rumble", id = "gsorumble", type = MENU, leftIcon = self.Icons["rumble"] })
        self.menu.gsorumble:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsorumble.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorumble.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorumble:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsorumble.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorumble.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorumble:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsorumble.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorumble.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsorumble:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsorumble.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsorumble.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuRyze()
    self.menu:MenuElement({name = "Ryze", id = "gsoryze", type = MENU, leftIcon = self.Icons["ryze"] })
        self.menu.gsoryze:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoryze.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoryze.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoryze:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoryze.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoryze.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoryze:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoryze.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoryze.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoryze:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoryze.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoryze.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuSejuani()
    self.menu:MenuElement({name = "Sejuani", id = "gsosejuani", type = MENU, leftIcon = self.Icons["sejuani"] })
        self.menu.gsosejuani:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsosejuani.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosejuani.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosejuani:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsosejuani.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosejuani.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosejuani:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsosejuani.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosejuani.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosejuani:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsosejuani.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosejuani.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuShaco()
    self.menu:MenuElement({name = "Shaco", id = "gsoshaco", type = MENU, leftIcon = self.Icons["shaco"] })
        self.menu.gsoshaco:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoshaco.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshaco.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoshaco:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoshaco.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshaco.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoshaco:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoshaco.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshaco.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoshaco:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoshaco.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshaco.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuShen()
    self.menu:MenuElement({name = "Shen", id = "gsoshen", type = MENU, leftIcon = self.Icons["shen"] })
        self.menu.gsoshen:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoshen.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshen.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoshen:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoshen.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshen.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoshen:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoshen.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshen.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoshen:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoshen.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshen.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuShyvana()
    self.menu:MenuElement({name = "Shyvana", id = "gsoshyvana", type = MENU, leftIcon = self.Icons["shyvana"] })
        self.menu.gsoshyvana:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoshyvana.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshyvana.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoshyvana:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoshyvana.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshyvana.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoshyvana:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoshyvana.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshyvana.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoshyvana:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoshyvana.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoshyvana.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuSinged()
    self.menu:MenuElement({name = "Singed", id = "gsosinged", type = MENU, leftIcon = self.Icons["singed"] })
        self.menu.gsosinged:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsosinged.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosinged.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosinged:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsosinged.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosinged.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosinged:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsosinged.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosinged.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosinged:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsosinged.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosinged.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuSion()
    self.menu:MenuElement({name = "Sion", id = "gsosion", type = MENU, leftIcon = self.Icons["sion"] })
        self.menu.gsosion:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsosion.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosion.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosion:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsosion.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosion.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosion:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsosion.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosion.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosion:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsosion.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosion.rset:MenuElement({id = "harass", name = "Harass", value = false})
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

function __gsoMenu:_menuSkarner()
    self.menu:MenuElement({name = "Skarner", id = "gsoskarner", type = MENU, leftIcon = self.Icons["skarner"] })
        self.menu.gsoskarner:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoskarner.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoskarner.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoskarner:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoskarner.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoskarner.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoskarner:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoskarner.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoskarner.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoskarner:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoskarner.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoskarner.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuSona()
    self.menu:MenuElement({name = "Sona", id = "gsosona", type = MENU, leftIcon = self.Icons["sona"] })
        self.menu.gsosona:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsosona.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosona.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosona:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsosona.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosona.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosona:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsosona.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosona.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosona:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsosona.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosona.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuSoraka()
    self.menu:MenuElement({name = "Soraka", id = "gsosoraka", type = MENU, leftIcon = self.Icons["soraka"] })
        self.menu.gsosoraka:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsosoraka.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosoraka.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosoraka:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsosoraka.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosoraka.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosoraka:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsosoraka.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosoraka.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosoraka:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsosoraka.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosoraka.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuSwain()
    self.menu:MenuElement({name = "Swain", id = "gsoswain", type = MENU, leftIcon = self.Icons["swain"] })
        self.menu.gsoswain:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoswain.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoswain.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoswain:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoswain.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoswain.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoswain:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoswain.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoswain.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoswain:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoswain.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoswain.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuSyndra()
    self.menu:MenuElement({name = "Syndra", id = "gsosyndra", type = MENU, leftIcon = self.Icons["syndra"] })
        self.menu.gsosyndra:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsosyndra.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosyndra.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosyndra:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsosyndra.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosyndra.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosyndra:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsosyndra.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosyndra.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsosyndra:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsosyndra.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsosyndra.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuTahmKench()
    self.menu:MenuElement({name = "TahmKench", id = "gsotahmkench", type = MENU, leftIcon = self.Icons["tahmkench"] })
        self.menu.gsotahmkench:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsotahmkench.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotahmkench.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotahmkench:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsotahmkench.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotahmkench.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotahmkench:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsotahmkench.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotahmkench.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotahmkench:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsotahmkench.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotahmkench.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuTaliyah()
    self.menu:MenuElement({name = "Taliyah", id = "gsotaliyah", type = MENU, leftIcon = self.Icons["taliyah"] })
        self.menu.gsotaliyah:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsotaliyah.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotaliyah.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotaliyah:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsotaliyah.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotaliyah.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotaliyah:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsotaliyah.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotaliyah.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotaliyah:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsotaliyah.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotaliyah.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuTalon()
    self.menu:MenuElement({name = "Talon", id = "gsotalon", type = MENU, leftIcon = self.Icons["talon"] })
        self.menu.gsotalon:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsotalon.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotalon.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotalon:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsotalon.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotalon.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotalon:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsotalon.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotalon.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotalon:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsotalon.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotalon.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuTaric()
    self.menu:MenuElement({name = "Taric", id = "gsotaric", type = MENU, leftIcon = self.Icons["taric"] })
        self.menu.gsotaric:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsotaric.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotaric.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotaric:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsotaric.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotaric.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotaric:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsotaric.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotaric.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotaric:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsotaric.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotaric.rset:MenuElement({id = "harass", name = "Harass", value = false})
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

function __gsoMenu:_menuThresh()
    self.menu:MenuElement({name = "Thresh", id = "gsothresh", type = MENU, leftIcon = self.Icons["thresh"] })
        self.menu.gsothresh:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsothresh.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsothresh.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsothresh:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsothresh.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsothresh.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsothresh:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsothresh.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsothresh.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsothresh:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsothresh.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsothresh.rset:MenuElement({id = "harass", name = "Harass", value = false})
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

function __gsoMenu:_menuTrundle()
    self.menu:MenuElement({name = "Trundle", id = "gsotrundle", type = MENU, leftIcon = self.Icons["trundle"] })
        self.menu.gsotrundle:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsotrundle.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotrundle.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotrundle:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsotrundle.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotrundle.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotrundle:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsotrundle.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotrundle.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotrundle:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsotrundle.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotrundle.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuTryndamere()
    self.menu:MenuElement({name = "Tryndamere", id = "gsotryndamere", type = MENU, leftIcon = self.Icons["tryndamere"] })
        self.menu.gsotryndamere:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsotryndamere.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotryndamere.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotryndamere:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsotryndamere.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotryndamere.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotryndamere:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsotryndamere.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotryndamere.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotryndamere:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsotryndamere.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotryndamere.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuTwistedFate()
    self.menu:MenuElement({name = "TwistedFate", id = "gsotwistedfate", type = MENU, leftIcon = self.Icons["twistedfate"] })
        self.menu.gsotwistedfate:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsotwistedfate.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotwistedfate.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotwistedfate:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsotwistedfate.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotwistedfate.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotwistedfate:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsotwistedfate.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotwistedfate.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsotwistedfate:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsotwistedfate.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsotwistedfate.rset:MenuElement({id = "harass", name = "Harass", value = false})
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

function __gsoMenu:_menuUdyr()
    self.menu:MenuElement({name = "Udyr", id = "gsoudyr", type = MENU, leftIcon = self.Icons["udyr"] })
        self.menu.gsoudyr:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoudyr.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoudyr.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoudyr:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoudyr.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoudyr.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoudyr:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoudyr.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoudyr.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoudyr:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoudyr.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoudyr.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuUrgot()
    self.menu:MenuElement({name = "Urgot", id = "gsourgot", type = MENU, leftIcon = self.Icons["urgot"] })
        self.menu.gsourgot:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsourgot.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsourgot.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsourgot:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsourgot.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsourgot.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsourgot:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsourgot.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsourgot.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsourgot:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsourgot.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsourgot.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuVarus()
    self.menu:MenuElement({name = "Varus", id = "gsovarus", type = MENU, leftIcon = self.Icons["varus"] })
        self.menu.gsovarus:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsovarus.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovarus.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovarus:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsovarus.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovarus.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovarus:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsovarus.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovarus.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovarus:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsovarus.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovarus.rset:MenuElement({id = "harass", name = "Harass", value = false})
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

function __gsoMenu:_menuVeigar()
    self.menu:MenuElement({name = "Veigar", id = "gsoveigar", type = MENU, leftIcon = self.Icons["veigar"] })
        self.menu.gsoveigar:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoveigar.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoveigar.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoveigar:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoveigar.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoveigar.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoveigar:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoveigar.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoveigar.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoveigar:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoveigar.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoveigar.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuVelkoz()
    self.menu:MenuElement({name = "Velkoz", id = "gsovelkoz", type = MENU, leftIcon = self.Icons["velkoz"] })
        self.menu.gsovelkoz:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsovelkoz.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovelkoz.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovelkoz:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsovelkoz.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovelkoz.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovelkoz:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsovelkoz.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovelkoz.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovelkoz:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsovelkoz.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovelkoz.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuVi()
    self.menu:MenuElement({name = "Vi", id = "gsovi", type = MENU, leftIcon = self.Icons["vi"] })
        self.menu.gsovi:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsovi.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovi.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovi:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsovi.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovi.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovi:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsovi.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovi.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovi:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsovi.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovi.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuViktor()
    self.menu:MenuElement({name = "Viktor", id = "gsoviktor", type = MENU, leftIcon = self.Icons["viktor"] })
        self.menu.gsoviktor:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoviktor.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoviktor.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoviktor:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoviktor.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoviktor.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoviktor:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoviktor.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoviktor.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoviktor:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoviktor.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoviktor.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuVladimir()
    self.menu:MenuElement({name = "Vladimir", id = "gsovladimir", type = MENU, leftIcon = self.Icons["vladimir"] })
        self.menu.gsovladimir:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsovladimir.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovladimir.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovladimir:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsovladimir.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovladimir.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovladimir:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsovladimir.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovladimir.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovladimir:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsovladimir.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovladimir.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuVolibear()
    self.menu:MenuElement({name = "Volibear", id = "gsovolibear", type = MENU, leftIcon = self.Icons["volibear"] })
        self.menu.gsovolibear:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsovolibear.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovolibear.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovolibear:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsovolibear.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovolibear.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovolibear:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsovolibear.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovolibear.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsovolibear:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsovolibear.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsovolibear.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuWarwick()
    self.menu:MenuElement({name = "Warwick", id = "gsowarwick", type = MENU, leftIcon = self.Icons["warwick"] })
        self.menu.gsowarwick:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsowarwick.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsowarwick.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsowarwick:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsowarwick.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsowarwick.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsowarwick:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsowarwick.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsowarwick.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsowarwick:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsowarwick.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsowarwick.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuXayah()
    self.menu:MenuElement({name = "Xayah", id = "gsoxayah", type = MENU, leftIcon = self.Icons["xayah"] })
        self.menu.gsoxayah:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoxayah.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxayah.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoxayah:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoxayah.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxayah.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoxayah:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoxayah.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxayah.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoxayah:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoxayah.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxayah.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuXerath()
    self.menu:MenuElement({name = "Xerath", id = "gsoxerath", type = MENU, leftIcon = self.Icons["xerath"] })
        self.menu.gsoxerath:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoxerath.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxerath.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoxerath:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoxerath.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxerath.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoxerath:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoxerath.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxerath.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoxerath:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoxerath.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxerath.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuXinZhao()
    self.menu:MenuElement({name = "XinZhao", id = "gsoxinzhao", type = MENU, leftIcon = self.Icons["xinzhao"] })
        self.menu.gsoxinzhao:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoxinzhao.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxinzhao.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoxinzhao:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoxinzhao.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxinzhao.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoxinzhao:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoxinzhao.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxinzhao.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoxinzhao:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoxinzhao.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoxinzhao.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuYasuo()
    self.menu:MenuElement({name = "Yasuo", id = "gsoyasuo", type = MENU, leftIcon = self.Icons["yasuo"] })
        self.menu.gsoyasuo:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoyasuo.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoyasuo.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoyasuo:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoyasuo.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoyasuo.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoyasuo:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoyasuo.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoyasuo.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoyasuo:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoyasuo.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoyasuo.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuYorick()
    self.menu:MenuElement({name = "Yorick", id = "gsoyorick", type = MENU, leftIcon = self.Icons["yorick"] })
        self.menu.gsoyorick:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoyorick.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoyorick.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoyorick:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoyorick.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoyorick.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoyorick:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoyorick.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoyorick.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoyorick:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoyorick.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoyorick.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuZac()
    self.menu:MenuElement({name = "Zac", id = "gsozac", type = MENU, leftIcon = self.Icons["zac"] })
        self.menu.gsozac:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsozac.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozac.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozac:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsozac.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozac.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozac:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsozac.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozac.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozac:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsozac.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozac.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuZed()
    self.menu:MenuElement({name = "Zed", id = "gsozed", type = MENU, leftIcon = self.Icons["zed"] })
        self.menu.gsozed:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsozed.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozed.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozed:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsozed.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozed.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozed:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsozed.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozed.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozed:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsozed.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozed.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuZiggs()
    self.menu:MenuElement({name = "Ziggs", id = "gsoziggs", type = MENU, leftIcon = self.Icons["ziggs"] })
        self.menu.gsoziggs:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsoziggs.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoziggs.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoziggs:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsoziggs.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoziggs.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoziggs:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsoziggs.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoziggs.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsoziggs:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsoziggs.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsoziggs.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuZilean()
    self.menu:MenuElement({name = "Zilean", id = "gsozilean", type = MENU, leftIcon = self.Icons["zilean"] })
        self.menu.gsozilean:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsozilean.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozilean.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozilean:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsozilean.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozilean.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozilean:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsozilean.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozilean.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozilean:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsozilean.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozilean.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuZoe()
    self.menu:MenuElement({name = "Zoe", id = "gsozoe", type = MENU, leftIcon = self.Icons["zoe"] })
        self.menu.gsozoe:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsozoe.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozoe.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozoe:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsozoe.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozoe.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozoe:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsozoe.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozoe.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozoe:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsozoe.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozoe.rset:MenuElement({id = "harass", name = "Harass", value = false})
end

function __gsoMenu:_menuZyra()
    self.menu:MenuElement({name = "Zyra", id = "gsozyra", type = MENU, leftIcon = self.Icons["zyra"] })
        self.menu.gsozyra:MenuElement({name = "Q settings", id = "qset", type = MENU })
            self.menu.gsozyra.qset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozyra.qset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozyra:MenuElement({name = "W settings", id = "wset", type = MENU })
            self.menu.gsozyra.wset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozyra.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozyra:MenuElement({name = "E settings", id = "eset", type = MENU })
            self.menu.gsozyra.eset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozyra.eset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.gsozyra:MenuElement({name = "R settings", id = "rset", type = MENU })
            self.menu.gsozyra.rset:MenuElement({id = "combo", name = "Combo", value = true})
            self.menu.gsozyra.rset:MenuElement({id = "harass", name = "Harass", value = false})
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
            self.menu.orb.delays:MenuElement({name = "Extra LastHit Delay", id = "lhDelay", value = 0, min = -50, max = 50, step = 1 })
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

class "__gsoCallbacks"

function __gsoCallbacks:__init()
    self._tick          = {}
    self._draw          = {}
    self._wndMsg        = {}
    self._aaSpeed       = function() return myHero.attackSpeed end
    self._champMenu     = function() return 0 end
    self._bonusDmg      = function() return 0 end
    self._bonusDmgUnit  = function() return 0 end
    self._onTick        = function() return 0 end
    self._mousePos      = function() return nil end
    self._canMove       = function(target) return true end
    self._canAttack     = function(target) return true end
    self._onMove        = function(target) return 0 end
    self._onAttack      = function(target) return 0 end
end
function __gsoCallbacks:_setTick(func) self._tick[#self._tick+1] = func end
function __gsoCallbacks:_setDraw(func) self._draw[#self._draw+1] = func end
function __gsoCallbacks:_setWndMsg(func) self._wndMsg[#self._wndMsg+1] = func end
function __gsoCallbacks:_setAASpeed(func) self._aaSpeed = func end
function __gsoCallbacks:_setChampMenu(func) self._champMenu = func end
function __gsoCallbacks:_setBonusDmg(func) self._bonusDmg = func end
function __gsoCallbacks:_setBonusDmgUnit(func) self._bonusDmgUnit = func end
function __gsoCallbacks:_setOnTick(func) self._onTick = func end
function __gsoCallbacks:_setMousePos(func) self._mousePos = func end
function __gsoCallbacks:_setCanMove(func) self._canMove = func end
function __gsoCallbacks:_setCanAttack(func) self._canAttack = func end
function __gsoCallbacks:_setOnMove(func) self._onMove = func end
function __gsoCallbacks:_setOnAttack(func) self._onAttack = func end

class "__gsoFarm"

function __gsoFarm:__init()
    self.aaDmg          = myHero.totalDamage
    self.lastHit        = {}
    self.almostLH       = {}
    self.laneClear      = {}
    self.aAttacks       = {}
    self.shouldWaitT    = 0
    self.shouldWait     = false
end

function __gsoFarm:_tick()
    self.aaDmg   = myHero.totalDamage + gsoAIO.Callbacks._bonusDmg()
    if self.shouldWait == true and Game.Timer() > self.shouldWaitT + 0.5 then
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
        local distUP  = gsoAIO.Utils:_getDistance(pPos, uPos)
        local distEP  = gsoAIO.Utils:_getDistance(pPos, ePos)
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
    for i = 1, #gsoAIO.OB.allyMinions do
        local aMin = gsoAIO.OB.allyMinions[i]
        local aaData  = aMin.attackData
        local aDmg    = (aMin.totalDamage*(1+aMin.bonusDamagePercent))
        if aaData.target == eMin.handle then
            local endT    = aaData.endTime
            local animT   = aaData.animationTime
            local windUpT = aaData.windUpTime
            local pSpeed  = aaData.projectileSpeed
            local pFlyT   = pSpeed > 0 and gsoAIO.Utils:_getDistance(aMin.pos, eMin.pos) / pSpeed or 0
            local pStartT = endT - animT
            local pEndT   = pStartT + pFlyT + windUpT
            local checkT  = Game.Timer()
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
    for i = 1, #gsoAIO.OB.enemyMinions do
        local eMinion = gsoAIO.OB.enemyMinions[i]
        local eMinion_handle	= eMinion.handle
        local distance = gsoAIO.Utils:_getDistance(myHero.pos, eMinion.pos)
        if distance < myHero.range + myHero.boundingRadius + eMinion.boundingRadius then
            local eMinion_health	= eMinion.health
            local myHero_aaData		= myHero.attackData
            local myHero_pFlyTime	= myHero_aaData.windUpTime + (distance / myHero_aaData.projectileSpeed) - (gsoAIO.Menu.menu.orb.delays.lhDelay:Value()*0.001)
            for k1,v1 in pairs(self.aAttacks) do
                for k2,v2 in pairs(self.aAttacks[k1]) do
                    if v2.canceled == false and eMinion_handle == v2.to.handle then
                        local checkT	= Game.Timer()
                        local pEndTime	= v2.startTime + v2.pTime
                        if pEndTime > checkT and  pEndTime - checkT < myHero_pFlyTime then
                            eMinion_health = eMinion_health - v2.dmg
                        end
                    end
                end
            end
            local myHero_dmg = self.aaDmg + gsoAIO.Callbacks._bonusDmgUnit(eMinion)
            if eMinion_health - myHero_dmg < 0 then
                self.lastHit[#self.lastHit+1] = { eMinion, eMinion_health }
            else
                if eMinion.health - self:_possibleDmg(eMinion, myHero.attackData.animationTime*3) - myHero_dmg < 0 then
                    self.shouldWait = true
                    self.shouldWaitT = Game.Timer()
                    self.almostLH[#self.almostLH+1] = eMinion
                else
                    self.laneClear[#self.laneClear+1] = eMinion
                end
            end
        end
    end
end

function __gsoFarm:_setActiveAA()
    for i = 1, #gsoAIO.OB.allyMinions do
        local aMinion = gsoAIO.OB.allyMinions[i]
        local aHandle	= aMinion.handle
        local aAAData	= aMinion.attackData
        if aAAData.endTime > Game.Timer() then
            for i = 1, #gsoAIO.OB.enemyMinions do
                local eMinion = gsoAIO.OB.enemyMinions[i]
                local eHandle	= eMinion.handle
                if eHandle == aAAData.target then
                    local checkT		= Game.Timer()
                    -- p -> projectile
                    local pSpeed  = aAAData.projectileSpeed
                    local aMPos   = aMinion.pos
                    local eMPos   = eMinion.pos
                    local pFlyT		= pSpeed > 0 and gsoAIO.Utils:_getDistance(aMPos, eMPos) / pSpeed or 0
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
        local checkT	= Game.Timer()
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
                    self.aAttacks[k1][k2].pTime = gsoAIO.Utils:_getDistance(v2.fromPos, self:_predPos(v2.speed, v2.pos, v2.to)) / v2.speed
                end
                if checkT > v2.startTime + self.aAttacks[k1][k2].pTime or not v2.to or v2.to.dead then
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
    
    --[[ issue ]]
    self.afterAAIssue = false
    
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
    
    if self.baseAASpeed == 0 then
        self.baseAASpeed  = 1 / myHero.attackData.animationTime / myHero.attackSpeed
    end
    if self.baseWindUp == 0 then
        self.baseWindUp = myHero.attackData.windUpTime / myHero.attackData.animationTime
    end
    
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
    if gsoAIO.Load.meDraven then
        local hasWBuff = GetTickCount() - gsoAIO.Champ.lastW > 100 and GetTickCount() - gsoAIO.WndMsg.lastW < 1000
        self.animT = hasWBuff and animT or self.animT
    end
    if gsoAIO.Load.meJinx then
        self.animT = animT
    end
    
    self.canAA    = self.dActionsC == 0 and gsoAIO.Callbacks._canAttack(unit) and not gsoAIO.TS.isBlinded
    self.canAA    = self.canAA and (self.aaReset or Game.Timer() > self.serverStart - windUpAA + self.animT - gsoAIO.Utils.minPing - 0.05 )
    self.canMove  = self.dActionsC == 0 and gsoAIO.Callbacks._canMove(unit)
    self.canMove  = self.canMove and Game.Timer() > self.serverStart + extraWindUp - ( gsoAIO.Utils.minPing * 0.5 )
    
    unit = unit ~= nil and unit or self.lastMinion
    local unitValid = unit ~= nil and not unit.dead and unit.isTargetable and unit.visible and unit.valid and unit.health > 0
    if unitValid and unit.type == Obj_AI_Hero then
        unitValid = gsoAIO.Utils:_isImmortal(unit, true) == false
    end
    if unitValid and self.canAA then
        self:_attack(unit)
        self.afterAAIssue = true
    elseif self.canMove then
        local afterAAIssue = false
        if self.afterAAIssue then
            afterAAIssue = true
            self.afterAAIssue = false
        end
        if gsoAIO.Callbacks._onMove(unit) then
            return
        end
        if self.lastMinion then
            self.lastMinion = nil
        end
        if unitValid and Game.Timer() > self.lAttack + ( gsoAIO.Orb.animT * 0.5 ) and Game.Timer() < self.lAttack + ( self.animT * 0.75 ) and gsoAIO.Items:_botrk(unit) then
            return
        end
        if Game.Timer() > self.lMove + (gsoAIO.Menu.menu.orb.delays.humanizer:Value()*0.001) and GetTickCount() > gsoAIO.Items.lastBotrk + 100 then
            self:_move(afterAAIssue)
            return
        end
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

function __gsoOrb:_move(afterAAIssue)
    local mPos = gsoAIO.Callbacks._mousePos()
    if mPos ~= nil then
        if gsoAIO.Load.meDraven and afterAAIssue and (gsoAIO.Utils:_hasBuff(myHero, "dravenspinning") or gsoAIO.Utils:_hasBuff(myHero, "dravenspinningattack")) then
            if ExtLibEvade and ExtLibEvade.Evading then return end
            if Control.IsKeyDown(2) then self.lastKey = GetTickCount() end
            Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
            Control.mouse_event(MOUSEEVENTF_RIGHTUP)
            self.lMove = Game.Timer()
            gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() self.lMove = 0 end, endTime = Game.Timer() + 0.075 }
        elseif gsoAIO.Utils:_getDistance(myHero.pos, mPos) > 125 then
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
            self.lMove = Game.Timer() + 0.33
        end
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

class "__gsoDraw"

function __gsoDraw:__init()
    if gsoAIO.Load.meAatrox then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meAhri then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meAkali then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meAlistar then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meAmumu then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meAnivia then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meAnnie then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meAshe then
        self.drawRanges = { w = true, wrange = 1200 }
    elseif gsoAIO.Load.meAurelionSol then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meAzir then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meBard then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meBlitzcrank then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meBrand then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meBraum then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meCaitlyn then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meCamille then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meCassiopeia then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meChogath then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meCorki then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meDarius then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meDiana then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meDrMundo then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meDraven then
        self.drawRanges = { e = true, erange = 1050 }
    elseif gsoAIO.Load.meEkko then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meElise then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meEvelynn then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meEzreal then
        self.drawRanges = { q = true, qrange = 1150, w = true, wrange = 1000, e = true, erange = 475 }
    elseif gsoAIO.Load.meFiddlesticks then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meFiora then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meFizz then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meGalio then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meGangplank then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meGaren then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meGnar then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meGragas then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meGraves then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meHecarim then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meHeimerdinger then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meIllaoi then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meIrelia then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meIvern then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meJanna then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meJarvanIV then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meJax then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meJayce then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meJhin then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meJinx then
        self.drawRanges = { q = true, qfunc = function() return self:_jinxQ() end, w = true, wrange = 1450, e = true, erange = 900 }
    elseif gsoAIO.Load.meKalista then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKarma then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKarthus then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKassadin then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKatarina then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKayle then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKayn then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKennen then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKhazix then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKindred then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKled then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meKogMaw then
        self.drawRanges = { q = true, qrange = 1175, e = true, erange = 1280, r = true, rfunc = function() return self:_kogR() end }
    elseif gsoAIO.Load.meLeblanc then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meLeeSin then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meLeona then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meLissandra then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meLucian then
        self.drawRanges = { q = true, qrange = 500+120, w = true, wrange = 900+350, e = true, erange = 425, r = true, rrange = 1200 }
    elseif gsoAIO.Load.meLulu then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meLux then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meMalphite then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meMalzahar then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meMaokai then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meMasterYi then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meMissFortune then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meMonkeyKing then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meMordekaiser then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meMorgana then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meNami then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meNasus then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meNautilus then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meNidalee then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meNocturne then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meNunu then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meOlaf then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meOrianna then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meOrnn then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.mePantheon then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.mePoppy then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meQuinn then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meRakan then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meRammus then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meRekSai then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meRenekton then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meRengar then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meRiven then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meRumble then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meRyze then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meSejuani then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meShaco then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meShen then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meShyvana then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meSinged then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meSion then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meSivir then
        self.drawRanges = { q = true, qrange = 1250, r = true, rrange = 1000 }
    elseif gsoAIO.Load.meSkarner then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meSona then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meSoraka then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meSwain then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meSyndra then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meTahmKench then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meTaliyah then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meTalon then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meTaric then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meTeemo then
        self.drawRanges = { q = true, qrange = 680, r = true, rfunc = function() return self:_teemoR() end }
    elseif gsoAIO.Load.meThresh then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meTristana then
        self.drawRanges = { w = true, wrange = 900 }
    elseif gsoAIO.Load.meTrundle then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meTryndamere then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meTwistedFate then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meTwitch then
        self.drawRanges = { w = true, wrange = 950, e = true, erange = 1200, r = true, rfunc = function() return self:_twitchR() end }
    elseif gsoAIO.Load.meUdyr then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meUrgot then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meVarus then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meVayne then
        self.drawRanges = { q = true, qrange = 300, e = true, erange = 550 }
    elseif gsoAIO.Load.meVeigar then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meVelkoz then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meVi then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meViktor then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meVladimir then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meVolibear then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meWarwick then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meXayah then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meXerath then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meXinZhao then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meYasuo then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meYorick then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meZac then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meZed then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meZiggs then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meZilean then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meZoe then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    elseif gsoAIO.Load.meZyra then
        self.drawRanges = { q = true, qrange = 0, w = true, wrange = 0, e = true, erange = 0, r = true, rrange = 0 }
    end
    Callback.Add('Draw', function() self:_draw() end)
end

function __gsoDraw:_xerathR()
    local rlvl = myHero:GetSpellData(_R).level
    if rlvl == 0 then
        return 3520
    else
        return 2200 + ( 1320 * rlvl )
    end
end

function __gsoDraw:_caitR()
    local rlvl = myHero:GetSpellData(_R).level
    if rlvl == 0 then
        return 2000
    else
        return 1500 + ( 500 * rlvl )
    end
end

function __gsoDraw:_ryzeR()
    local rlvl = myHero:GetSpellData(_R).level
    if rlvl == 0 then
        return 1750
    else
        return 500 + ( 1250 * rlvl )
    end
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

class "__gsoWndMsg"

function __gsoWndMsg:__init()
    self.lastQ    = 0
    self.lastW    = 0
    self.lastE    = 0
    self.lastR    = 0
    self.delayedSpell = {}
    Callback.Add('WndMsg', function(msg, wParam) self:_onWndMsg(msg, wParam) end)
end

function __gsoWndMsg:_onWndMsg(msg, wParam)
    local getTick = GetTickCount()
    local isKey = gsoAIO.Menu.menu.orb.keys.combo:Value() or gsoAIO.Menu.menu.orb.keys.harass:Value() or gsoAIO.Menu.menu.orb.keys.laneClear:Value() or gsoAIO.Menu.menu.orb.keys.lastHit:Value()
    if Game.CanUseSpell(_Q) == 0 and wParam == HK_Q and getTick > self.lastQ + 1000 then
        self.lastQ = getTick
        if isKey and not self.delayedSpell[0] then
            self.delayedSpell[0] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_W) == 0 and wParam == HK_W and getTick > self.lastW + 1000 then
        self.lastW = getTick
        if isKey and not self.delayedSpell[1] then
            self.delayedSpell[1] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_E) == 0 and wParam == HK_E and getTick > self.lastE + 1000 then
        self.lastE = getTick
        if isKey and not self.delayedSpell[2] then
            self.delayedSpell[2] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_R) == 0 and wParam == HK_R and getTick > self.lastR + 1000 then
        self.lastR = getTick
        if isKey and not self.delayedSpell[3] then
            self.delayedSpell[3] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    end
    for i = 1, #gsoAIO.Callbacks._wndMsg do
        gsoAIO.Callbacks._wndMsg[i]()
    end
end

class "__gsoTick"

function __gsoTick:__init()
    Callback.Add('Tick', function() self:_tick() end)
end

function __gsoTick:_tick()
    for i = 1, #gsoAIO.Callbacks._tick do
        gsoAIO.Callbacks._tick[i]()
    end
end

-- http://gamingonsteroids.com/user/198940-trus/
class "__gsoTPred"

function __gsoTPred:CutWaypoints(Waypoints, distance, unit)
    local result = {}
    local remaining = distance
    if distance > 0 then
        for i = 1, #Waypoints -1 do
            local A, B = Waypoints[i], Waypoints[i + 1]
            if A and B then 
                local dist = self:GetDistance(A, B)
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

function __gsoTPred:VectorMovementCollision(startPoint1, endPoint1, v1, startPoint2, v2, delay)
    local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
    local d, e = eP1x-sP1x, eP1y-sP1y
    local dist, t1, t2 = mathSqrt(d*d+e*e), nil, nil
    local S, K = dist~=0 and v1*d/dist or 0, dist~=0 and v1*e/dist or 0
    local function GetCollisionPoint(t) return t and {x = sP1x+S*t, y = sP1y+K*t} or nil end
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
                    local nom = mathSqrt(sqr)
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
    return t1, GetCollisionPoint(t1), t2, GetCollisionPoint(t2), dist
end

function __gsoTPred:GetCurrentWayPoints(object)
    local result = {}
    local objectPos = object.pos
    if object.pathing.hasMovePath then
        local objectPath = object.pathing
        table.insert(result, Vector(objectPos.x,objectPos.y, objectPos.z))
        for i = objectPath.pathIndex, objectPath.pathCount do
            path = object:GetPath(i)
            table.insert(result, Vector(path.x, path.y, path.z))
        end
    else
        table.insert(result, object and Vector(objectPos.x,objectPos.y, objectPos.z) or Vector(objectPos.x,objectPos.y, objectPos.z))
    end
    return result
end

function __gsoTPred:GetDistanceSqr(p1, p2)
    if not p1 or not p2 then return 999999999 end
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function __gsoTPred:GetDistance(p1, p2)
    return mathSqrt(self:GetDistanceSqr(p1, p2))
end

function __gsoTPred:GetWaypointsLength(Waypoints)
    local result = 0
    for i = 1, #Waypoints -1 do
        result = result + self:GetDistance(Waypoints[i], Waypoints[i + 1])
    end
    return result
end

function __gsoTPred:CanMove(unit, delay)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i);
        if buff and buff.count > 0 and buff.duration>=delay then
            if (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11) then
                return false -- block everything
            end
        end
    end
    return true
end

function __gsoTPred:IsImmobile(unit, delay, radius, speed, from, spelltype)
    local unitPos = unit.pos
    local ExtraDelay = speed == math.huge and 0 or from and unit and unitPos and (self:GetDistance(from, unitPos) / speed)
    if (self:CanMove(unit, delay + ExtraDelay) == false) then
        return true
    end
    return false
end

function __gsoTPred:CalculateTargetPosition(unit, delay, radius, speed, from, spelltype)
    local Waypoints = {}
    local unitPos = unit.pos
    local Position, CastPosition = Vector(unitPos), Vector(unitPos)
    local t
    Waypoints = self:GetCurrentWayPoints(unit)
    local Waypointslength = self:GetWaypointsLength(Waypoints)
    local movementspeed = unit.pathing.isDashing and unit.pathing.dashSpeed or unit.ms
    if #Waypoints == 1 then
        Position, CastPosition = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z), Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
        return Position, CastPosition
    elseif (Waypointslength - delay * movementspeed + radius) >= 0 then
        local tA = 0
        Waypoints = self:CutWaypoints(Waypoints, delay * movementspeed - radius)
        if speed ~= math.huge then
            for i = 1, #Waypoints - 1 do
                local A, B = Waypoints[i], Waypoints[i+1]
                if i == #Waypoints - 1 then
                    B = Vector(B) + radius * Vector(B - A):Normalized()
                end

                local t1, p1, t2, p2, D = self:VectorMovementCollision(A, B, movementspeed, Vector(from.x,from.y,from.z), speed)
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
            if (self:GetWaypointsLength(Waypoints) - t * movementspeed - radius) >= 0 then
                Waypoints = self:CutWaypoints(Waypoints, radius + t * movementspeed)
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

function __gsoTPred:VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

function __gsoTPred:CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw)
    if unit.networkID == minion.networkID then 
        return false
    end
    local waypoints = self:GetCurrentWayPoints(minion)
    local minionPos = minion.pos
    local MPos, CastPosition = #waypoints == 1 and Vector(minionPos) or self:CalculateTargetPosition(minion, delay, radius, speed, from, "line")
    if from and MPos and self:GetDistanceSqr(from, MPos) <= (range)^2 and self:GetDistanceSqr(from, minionPos) <= (range + 100)^2 then
        local buffer = (#waypoints > 1) and 8 or 0 
        if minion.type == myHero.type then
            buffer = buffer + minion.boundingRadius
        end
        if #waypoints > 1 then
            local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(from, Position, Vector(MPos))
            if proj1 and isOnSegment and (self:GetDistanceSqr(MPos, proj1) <= (minion.boundingRadius + radius + buffer) ^ 2) then
                return true
            end
        end
        local proj2, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(from, Position, Vector(minionPos))
        if proj2 and isOnSegment and (self:GetDistanceSqr(minionPos, proj2) <= (minion.boundingRadius + radius + buffer) ^ 2) then
            return true
        end
    end
end

function __gsoTPred:CheckMinionCollision(unit, Position, delay, radius, range, speed, from)
    Position = Vector(Position)
    from = from and Vector(from) or myHero.pos
    for i = 1, #gsoAIO.OB.enemyMinions do
        local minion = gsoAIO.OB.enemyMinions[i]
        if minion and not minion.dead and minion.isTargetable and minion.visible and minion.valid and self:CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw) then
            return true
        end
    end
    return false
end

function __gsoTPred:isSlowed(unit, delay, speed, from)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i);
        if buff and from and buff.count > 0 and buff.duration>=(delay + self:GetDistance(unit.pos, from) / speed) then
            if (buff.type == 10) then
                return true
            end
        end
    end
    return false
end

function __gsoTPred:GetBestCastPosition(unit, delay, radius, range, speed, from, collision, spelltype)
    range = range and range - 4 or math.huge
    radius = radius == 0 and 1 or radius - 4
    speed = speed and speed or math.huge
    local mePos = myHero.pos
    local hePos = unit.pos
    if not from then
        from = Vector(mePos)
    end
    local IsFromMyHero = self:GetDistanceSqr(from, mePos) < 50*50 and true or false
    delay = delay + (0.07 + Game.Latency() / 2000)
    local Position, CastPosition = self:CalculateTargetPosition(unit, delay, radius, speed, from, spelltype)
    local HitChance = 1
    if (self:IsImmobile(unit, delay, radius, speed, from, spelltype)) then
        HitChance = 5
    end
    Waypoints = self:GetCurrentWayPoints(unit)
    if (#Waypoints == 1) then
        HitChance = 2
    end
    if self:isSlowed(unit, delay, speed, from) then
        HitChance = 2
    end
    if (unit.activeSpell and unit.activeSpell.valid) then
        HitChance = 2
    end
    if self:GetDistance(mePos, hePos) < 250 then
        HitChance = 2
        Position, CastPosition = self:CalculateTargetPosition(unit, delay*0.5, radius, speed*2, from, spelltype)
        Position = CastPosition
    end
    local angletemp = Vector(from):AngleBetween(Vector(hePos), Vector(CastPosition))
    if angletemp > 60 then
        HitChance = 1
    elseif angletemp < 30 then
        HitChance = 2
    end
    --[[Out of range]]
    if IsFromMyHero then
        if (spelltype == "line" and self:GetDistanceSqr(from, Position) >= range * range) then
            HitChance = 0
        end
        if (spelltype == "circular" and (self:GetDistanceSqr(from, Position) >= (range + radius)*(range + radius))) then
            HitChance = 0
        end
        if from and Position and (self:GetDistanceSqr(from, Position) > range * range) then
            HitChance = 0
        end
    end
    radius = radius*2
    if collision and HitChance > 0 then
        if collision and self:CheckMinionCollision(unit, hePos, delay, radius, range, speed, from) then
            HitChance = -1
        elseif self:CheckMinionCollision(unit, Position, delay, radius, range, speed, from) then
            HitChance = -1
        elseif self:CheckMinionCollision(unit, CastPosition, delay, radius, range, speed, from) then
            HitChance = -1
        end
    end
    if not CastPosition or not Position then
        HitChance = -1
    end
    return CastPosition, HitChance, Position
end


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
        if minion and gsoAIO.Utils:_getDistance(mePos, minion.pos) < 2000 and not minion.dead and minion.isTargetable and minion.visible and minion.valid and not minion.isImmortal and minion.health > 0 then
            if minion.team ~= self.meTeam then
                self.enemyMinions[#self.enemyMinions+1] = minion
            else
                self.allyMinions[#self.allyMinions+1] = minion
            end
        end
    end
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if hero and hero.team ~= self.meTeam and gsoAIO.Utils:_getDistance(mePos, hero.pos) < 10000 and not hero.dead and hero.isTargetable and hero.visible and hero.valid and hero.health > 0 then
            self.enemyHeroes[#self.enemyHeroes+1] = hero
        end
    end
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret and turret.team ~= self.meTeam and gsoAIO.Utils:_getDistance(mePos, turret.pos) < 2000 and not turret.dead and turret.isTargetable and turret.visible and turret.valid and not turret.isImmortal and turret.health > 0 then
            self.enemyTurrets[#self.enemyTurrets+1] = turret
        end
    end
end


class "__gsoTS"

function __gsoTS:__init()
    self.apDmg = false
    self.isTeemo = false
    self.isBlinded = false
    self.loadedChamps = false
    self.lastTarget = nil
    self.lastFound = -10000000
    self.selectedTarget = nil
    self.lastSelTick = 0
    self.enemyHNames = {}
    self.LHTimers     = {
        [0] = { tick = 0, id = 0 },
        [1] = { tick = 0, id = 0 },
        [2] = { tick = 0, id = 0 },
        [3] = { tick = 0, id = 0 },
        [4] = { tick = 0, id = 0 }
    }
    gsoAIO.Callbacks:_setDraw(function() self:_draw() end)
    gsoAIO.Callbacks:_setWndMsg(function(msg, wParam) self:_onWndMsg(msg, wParam) end)
    gsoAIO.Callbacks:_setTick(function() self:_tick() end)
end

function __gsoTS:_getTarget(_range, orb, changeRange, enemyList)
    if gsoAIO.Menu.menu.ts.selected.only:Value() == true and gsoAIO.Utils:_valid(self.selectedTarget, true) then
        return self.selectedTarget
    end
    local result  = nil
    local num     = 10000000
    local mode    = gsoAIO.Menu.menu.ts.Mode:Value()
    local prioT  = { 10000000, 10000000 }
    for i = 1, #enemyList do
        local unit = enemyList[i]
        local unitID = unit.networkID
        local unitPos = unit.pos
        local mePos = myHero.pos
        local canTrist = gsoAIO.Load.meTristana and gsoAIO.Menu.menu.ts.tristE.enable:Value() and gsoAIO.Champ.tristanaETar and gsoAIO.Champ.tristanaETar.stacks >= gsoAIO.Menu.menu.ts.tristE.stacks:Value() and unitID == gsoAIO.Champ.tristanaETar.id
        local range = changeRange == true and _range + myHero.boundingRadius + unit.boundingRadius or _range
        local meExtended = gsoAIO.Orb.lMovePath and mePos:Extended(gsoAIO.Orb.lMovePath, (0.15+(gsoAIO.Utils.maxPing*1.5)) * myHero.ms) or mePos
        local dist1 = gsoAIO.Utils:_getDistance(mePos, unitPos)
        local dist2 = gsoAIO.Utils:_getDistance(meExtended, unitPos)
        local dist3 = dist2 > dist1 and dist2 or dist1
        if gsoAIO.Utils:_valid(unit, orb) and dist3 < range then
            if gsoAIO.Menu.menu.ts.selected.enable:Value() and self.selectedTarget and unitID == self.selectedTarget.networkID then
                return self.selectedTarget
            elseif canTrist then
                return unit
            elseif mode == 1 then
                local unitName = unit.charName
                local priority = 6
                if unitName ~= nil then
                    priority = gsoAIO.Menu.menu.ts.priority[unitName] and gsoAIO.Menu.menu.ts.priority[unitName]:Value() or priority
                end
                local calcNum = 1
                if priority == 1 then
                    calcNum = 1
                elseif priority == 2 then
                    calcNum = 1.15
                elseif priority == 3 then
                    calcNum = 1.3
                elseif priority == 4 then
                    calcNum = 1.45
                elseif priority == 5 then
                    calcNum = 1.6
                elseif priority == 6 then
                    calcNum = 1.75
                end
                local def = self.apDmg == true and unit.magicResist - myHero.magicPen or unit.armor - myHero.armorPen
                def = def * calcNum
                if def > 0 then
                      def = self.apDmg == true and myHero.magicPenPercent * def or myHero.bonusArmorPenPercent * def
                end
                local hpE = unit.health
                hpE = hpE * calcNum
                hpE = hpE * ( ( 100 + def ) / 100 )
                hpE = hpE - (unit.totalDamage*unit.attackSpeed*2) - unit.ap
                if hpE < num then
                    num     = hpE
                    result  = unit
                end
            elseif mode == 2 then
                if dist3 < num then
                    num = dist3
                    result = unit
                end
            elseif mode == 3 then
                local hpE = unit.health
                if hpE < num then
                    num = hpE
                    result = unit
                end
            elseif mode == 4 then
                local unitName = unit.charName
                local hpE = unit.health - (unit.totalDamage*unit.attackSpeed*2) - unit.ap
                local priority = 6
                if unitName ~= nil then
                    priority = gsoAIO.Menu.menu.ts.priority[unitName] and gsoAIO.Menu.menu.ts.priority[unitName]:Value() or priority
                end
                if priority == prioT[1] and hpE < prioT[2] then
                    prioT[2] = hpE
                    result = unit
                elseif priority < prioT[1] then
                    prioT[1] = priority
                    prioT[2] = hpE
                    result = unit
                end
            end
        end
    end
    return result
end

function __gsoTS:_comboT()
    return self:_getTarget(myHero.range, true, true, gsoAIO.OB.enemyHeroes)
end

function __gsoTS:_lastHitT()
    local result  = nil
    local min     = 10000000
    for i = 1, #gsoAIO.Farm.lastHit do
        local eMinionLH = gsoAIO.Farm.lastHit[i]
        local minion	= eMinionLH[1]
        local hp		= eMinionLH[2]
        local checkT = Game.Timer() < self.LHTimers[0].tick
        local mHandle = minion.handle
        if (not checkT or (checkT and self.LHTimers[0].id ~= mHandle)) and hp < min then
            min = hp
            result = minion
            self.LHTimers[4].tick = Game.Timer() + 0.75
            self.LHTimers[4].id = mHandle
        end
    end
    return result
end

function __gsoTS:_getTurret()
    local result = nil
    for i=1, #gsoAIO.OB.enemyTurrets do
        local turret = gsoAIO.OB.enemyTurrets[i]
        local range = myHero.range + myHero.boundingRadius + turret.boundingRadius
        if gsoAIO.Utils:_getDistance(myHero.pos, turret.pos) < range then
            result = turret
            break
        end
    end
    return result
end

function __gsoTS:_laneClearT()
    local result	= self:_lastHitT()
    if not result then
        result = self:_comboT()
        if not result and #gsoAIO.Farm.almostLH == 0 and gsoAIO.Farm.shouldWait == false then
            result = self:_getTurret()
            if not result then
                local min = 10000000
                for i = 1, #gsoAIO.Farm.laneClear do
                    local minion = gsoAIO.Farm.laneClear[i]
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

function __gsoTS:_harassT()
    local result = self:_lastHitT()
    return result == nil and self:_comboT() or result
end

function __gsoTS:_draw()
    if gsoAIO.Menu.menu.gsodraw.circle1.seltar:Value() and gsoAIO.Utils:_valid(self.selectedTarget, true) then
        Draw.Circle(self.selectedTarget.pos, gsoAIO.Menu.menu.gsodraw.circle1.seltarradius:Value(), gsoAIO.Menu.menu.gsodraw.circle1.seltarwidth:Value(), gsoAIO.Menu.menu.gsodraw.circle1.seltarcolor:Value())
    end
end

function __gsoTS:_tick()
    if gsoAIO.TS.isTeemo == true then
        self.isBlinded = gsoAIO.Utils:_hasBuff(myHero, "blindingdart")
    end
    if self.loadedChamps == false then
        for i = 1, Game.HeroCount() do
            local hero = Game.Hero(i)
            if hero.team ~= gsoAIO.OB.meTeam then
                local eName = hero.charName
                if eName and #eName > 0 and not gsoAIO.Menu.menu.ts.priority[eName] then
                    self.enemyHNames[#self.enemyHNames+1] = eName
                    self.lastFound = Game.Timer()
                    local priority = gsoAIO.Utils.Priorities[eName] ~= nil and gsoAIO.Utils.Priorities[eName] or 5
                    gsoAIO.Menu.menu.ts.priority:MenuElement({ id = eName, name = eName, value = priority, min = 1, max = 5, step = 1 })
                    if eName == "Teemo" then          self.isTeemo = true
                    elseif eName == "Kayle" then      gsoAIO.Utils.undyingBuffs["JudicatorIntervention"] = true
                    elseif eName == "Taric" then      gsoAIO.Utils.undyingBuffs["TaricR"] = true
                    elseif eName == "Kindred" then    gsoAIO.Utils.undyingBuffs["kindredrnodeathbuff"] = true
                    elseif eName == "Zilean" then     gsoAIO.Utils.undyingBuffs["ChronoShift"] = true; gsoAIO.Utils.undyingBuffs["chronorevive"] = true
                    elseif eName == "Tryndamere" then gsoAIO.Utils.undyingBuffs["UndyingRage"] = true
                    elseif eName == "Jax" then        gsoAIO.Utils.undyingBuffs["JaxCounterStrike"] = true
                    elseif eName == "Fiora" then      gsoAIO.Utils.undyingBuffs["FioraW"] = true
                    elseif eName == "Aatrox" then     gsoAIO.Utils.undyingBuffs["aatroxpassivedeath"] = true
                    elseif eName == "Vladimir" then   gsoAIO.Utils.undyingBuffs["VladimirSanguinePool"] = true
                    elseif eName == "KogMaw" then     gsoAIO.Utils.undyingBuffs["KogMawIcathianSurprise"] = true
                    elseif eName == "Karthus" then    gsoAIO.Utils.undyingBuffs["KarthusDeathDefiedBuff"] = true
                    end
                end
            end
        end
        if Game.Timer() > self.lastFound + 5 and Game.Timer() < self.lastFound + 10 then
            self.loadedChamps = true
        end
    end
end

function __gsoTS:_onWndMsg(msg, wParam)
    local getTick = GetTickCount()
    if msg == WM_LBUTTONDOWN and gsoAIO.Menu.menu.ts.selected.enable:Value() == true then
        if getTick > self.lastSelTick + 100 and getTick > gsoAIO.WndMsg.lastQ + 250 and getTick > gsoAIO.WndMsg.lastW + 250 and getTick > gsoAIO.WndMsg.lastE + 250 and getTick > gsoAIO.WndMsg.lastR + 250 then 
            local num = 10000000
            local enemy = nil
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local heroPos = hero.pos
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(myHero.pos, heroPos) < 10000 then
                    local distance = gsoAIO.Utils:_getDistance(heroPos, mousePos)
                    if distance < 150 and distance < num then
                        enemy = hero
                        num = distance
                    end
                end
            end
            if enemy ~= nil then
                self.selectedTarget = enemy
            else
                self.selectedTarget = nil
            end
            self.lastSelTick = GetTickCount()
        end
    end
end

class "__gsoUtils"

function __gsoUtils:__init()
    self.latencies = {}
    self.maxPing = Game.Latency() * 0.001
    self.minPing = Game.Latency() * 0.001
    self.delayedActions = {}
    self.attacks = {
        ["caitlynheadshotmissile"] = true,
        ["quinnwenhanced"] = true,
        ["viktorqbuff"] = true
    }
    self.noAttacks = {
        ["volleyattack"] = true,
        ["volleyattackwithsound"] = true,
        ["sivirwattackbounce"] = true,
        ["asheqattacknoonhit"] = true
    }
    self.undyingBuffs = {
        ["zhonyasringshield"] = true
    }
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
    Callback.Add('Tick', function() self:_tick() end)
end

function __gsoUtils:_tick()
    self.latencies[GetTickCount() + 2500] = Game.Latency() * 0.001
    local maxPing = 0
    local minPing = 50
    for k,v in pairs(self.latencies) do
        if v > maxPing then
            maxPing = v
        end
        if v < minPing then
            minPing = v
        end
        if GetTickCount() > k then
            self.latencies[k] = nil
        end
    end
    self.maxPing = maxPing
    self.minPing = minPing
    for i = 1, #gsoAIO.Utils.delayedActions do
        local dAction = gsoAIO.Utils.delayedActions[i]
        if dAction and Game.Timer() > dAction.endTime then
            dAction.func()
            gsoAIO.Utils.delayedActions[i] = nil
        end
    end
end

function __gsoUtils:_getDistance(a, b)
  local x = a.x - b.x
  local z = a.z - b.z
  return mathSqrt(x * x + z * z)
end

function __gsoUtils:_movePos(unit, time)
    local unitPath = unit.pathing
    if unitPath.hasMovePath == true then
        local uPos  = unit.pos
        local ePos  = unitPath.endPos
        local dist1 = gsoAIO.Utils:_getDistance(ePos, uPos)
        local predPos = uPos:Extended(ePos, time * unit.ms)
        local dist2 = gsoAIO.Utils:_getDistance(predPos, uPos)
        if dist2 > dist1 then
            return ePos
        else
            return predPos
        end
    end
    return unit.pos
end

function __gsoUtils:_pointOnLineSegment(x, z, ax, az, bx, bz)
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((x - ax) * bxax + (z - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    if t < 0 then return false
    elseif t > 1 then return false
    else return true
    end
end

function __gsoUtils:_isImmortal(unit, orb)
    local unitHPPercent = 100 * unit.health / unit.maxHealth
    if self.undyingBuffs["JaxCounterStrike"] ~= nil then    self.undyingBuffs["JaxCounterStrike"] = orb end
    if self.undyingBuffs["kindredrnodeathbuff"] ~= nil then self.undyingBuffs["kindredrnodeathbuff"] = unitHPPercent < 10 end
    if self.undyingBuffs["UndyingRage"] ~= nil then         self.undyingBuffs["UndyingRage"] = unitHPPercent < 15 end
    if self.undyingBuffs["ChronoShift"] ~= nil then         self.undyingBuffs["ChronoShift"] = unitHPPercent < 15; self.undyingBuffs["chronorevive"] = unitHPPercent < 15 end
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local undyingBuff = self.undyingBuffs[buff.name]
            if undyingBuff and undyingBuff == true then
                return true
            end
        end
    end
    return false
end

function __gsoUtils:_valid(unit, orb)
    if not unit or self:_isImmortal(unit, orb) then
        return false
    end
    if not unit.dead and unit.isTargetable and unit.visible and unit.valid then
        return true
    end
    return false
end

function __gsoUtils:_castAgain(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
end

function __gsoUtils:_isImmobile(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local bType = buff.type
            if bType == 5 or bType == 11 or bType == 29 or bType == 24 or buff.name == "recall" then
                return true
            end
        end
    end
    return false
end

function __gsoUtils:_immobileTime(unit)
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

function __gsoUtils:_nearTurret(pos, range, bb)
    for i = 1, #gsoAIO.OB.enemyTurrets do
        local unit = gsoAIO.OB.enemyTurrets[i]
        local range = bb and unit.boundingRadius or range
        if self:_getDistance(pos, unit.pos) < range then
            return true
        end
    end
    return false
end

function __gsoUtils:_nearHeroes(pos, range, bb)
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local unit = gsoAIO.OB.enemyHeroes[i]
        local range = bb and unit.boundingRadius or range
        if self:_getDistance(pos, unit.pos) < range then
            return true
        end
    end
    return false
end

function __gsoUtils:_nearMinions(pos, range, bb)
    for i = 1, #gsoAIO.OB.enemyMinions do
        local unit = gsoAIO.OB.enemyMinions[i]
        local range = bb and unit.boundingRadius or range
        if self:_getDistance(pos, unit.pos) < range then
            return true
        end
    end
    return false
end

function __gsoUtils:_nearUnit(pos, id)
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local unit = gsoAIO.OB.enemyHeroes[i]
        if id ~= unit.networkID and self:_getDistance(pos, unit.pos) < unit.boundingRadius then
            return true
        end
    end
    for i = 1, #gsoAIO.OB.enemyMinions do
        local unit = gsoAIO.OB.enemyMinions[i]
        if self:_getDistance(pos, unit.pos) < unit.boundingRadius then
            return true
        end
    end
    return false
end

function __gsoUtils:_buffCount(unit, bName)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == bName then
            return buff.count
        end
    end
    return 0
end

function __gsoUtils:_hasBuff(unit, bName)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == bName then
            return true
        end
    end
    return false
end

function __gsoUtils:_buffDuration(unit, bName)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == bName then
            return buff.duration
        end
    end
    return 0
end

function __gsoUtils:_isReady(gT, sT, spell)
    return gsoAIO.Orb.dActionsC == 0 and self:_checkTimers(gT, sT) and Game.CanUseSpell(spell) == 0
end

function __gsoUtils:_isReadyFast(gT, sT, spell)
    return self:_checkTimers(gT, sT) and Game.CanUseSpell(spell) == 0
end

function __gsoUtils:_checkWall(from, to, distance)
    local pos1 = to + (to-from):Normalized() * 50
    local pos2 = pos1 + (to-from):Normalized() * (distance - 50)
    local point1 = Point(pos1.x, pos1.z)
    local point2 = Point(pos2.x, pos2.z)
    if (MapPosition:inWall(point1) and MapPosition:inWall(point2)) or MapPosition:intersectsWall(LineSegment(point1, point2)) then
        return true
    end
    return false
end

function __gsoUtils:_getTimers(qT, wT, eT, rT)
    local gT = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    return {
        q = gT - qT,
        qq = gT - gsoAIO.WndMsg.lastQ,
        w = gT - wT,
        ww = gT - gsoAIO.WndMsg.lastW,
        e = gT - eT,
        ee = gT - gsoAIO.WndMsg.lastE,
        r = gT - rT,
        rr = gT - gsoAIO.WndMsg.lastR
    }
end

function __gsoUtils:_checkTimers(gT, sT)
    --[[assert(type(gT.q) == "number", "this is not number")
    assert(type(gT.qq) == "number", "this is not number")
    assert(type(gT.w) == "number", "this is not number")
    assert(type(gT.ww) == "number", "this is not number")
    assert(type(gT.e) == "number", "this is not number")
    assert(type(gT.ee) == "number", "this is not number")
    assert(type(gT.r) == "number", "this is not number")
    assert(type(gT.rr) == "number", "this is not number")
    assert(type(sT.q) == "number", "this is not number")
    assert(type(sT.w) == "number", "this is not number")
    assert(type(sT.e) == "number", "this is not number")
    assert(type(sT.r) == "number", "this is not number")]]
    if gT.q > sT.q and gT.qq > sT.q and gT.w > sT.w and gT.ww > sT.w and gT.e > sT.e and gT.ee > sT.e and gT.r > sT.r and gT.rr > sT.r then
        return true
    end
    return false
end

function __gsoUtils:_getClosestEnemy(sourcePos, enemyList, maxDistance)
    local result = nil
    for i = 1, #enemyList do
        local hero = enemyList[i]
        local distance = gsoAIO.Utils:_getDistance(sourcePos, hero.pos)
        if gsoAIO.Utils:_valid(hero, false) and distance < maxDistance then
            maxDistance = distance
            result = hero
        end
    end
    return result
end

function __gsoUtils:_getImmobileEnemy(sourcePos, enemyList, maxDistance)
    local result = nil
    local num = 0
    for i = 1, #enemyList do
        local hero = enemyList[i]
        local distance = gsoAIO.Utils:_getDistance(sourcePos, hero.pos)
        local iT = self:_immobileTime(hero)
        if distance < maxDistance and iT > num then
            num = iT
            result = hero
        end
    end
    return result
end

function __gsoUtils:_getCastPos(sourcePos, target, sD)
    local tP = target.pos
    local castpos,HitChance,pos = gsoAIO.TPred:GetBestCastPosition(target, sD.delay, sD.width*0.5, sD.range, sD.speed, sourcePos, sD.col, sD.sType)
    local distanceToSource = gsoAIO.Utils:_getDistance(sourcePos, castpos)
    local heroType = target.type == Obj_AI_Hero
    local heroID = heroType and target.networkID or 0
    local minionID = not heroType and target.networkID or 0
    local checkMinionCol = gsoAIO.Menu.menu.orb.keys.combo:Value()
    if sD.col and (self:_checkHeroesCollision(sourcePos.x, sourcePos.z, castpos.x, castpos.z, 60, heroID) or ( checkMinionCol and self:_checkMinionsCollision(sourcePos.x, sourcePos.z, castpos.x, castpos.z, 60, minionID))) then
        return nil
    end
    if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(tP, castpos) < 500 and distanceToSource > 150 and distanceToSource < sD.range then
        return castpos
    end
    return nil
end

function __gsoUtils:_closestPointToLineSegment(x, z, ax, az, bx, bz)
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((x - ax) * bxax + (z - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    if t < 0 then
        return ax, az, false
    elseif t > 1 then
        return bx, bz, false
    else
        return ax + t * bxax, az + t * bzaz, true
    end
end

function __gsoUtils:_checkHeroesCollision(ax, az, bx, bz, width, id)
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero = gsoAIO.OB.enemyHeroes[i]
        if hero.networkID ~= id then
            local heroPos = hero.pos
            local posx,posz,onLineSegment = self:_closestPointToLineSegment(heroPos.x, heroPos.z, ax, az, bx, bz)
            local distanceToPoint = gsoAIO.Utils:_getDistance(heroPos, { x = posx, z = posz })
            if distanceToPoint < width + hero.boundingRadius + 25 then
                return true
            end
        end
    end
    return false
end

function __gsoUtils:_checkMinionsCollision(ax, az, bx, bz, width, id)
    for i = 1, #gsoAIO.OB.enemyMinions do
        local minion = gsoAIO.OB.enemyMinions[i]
        if minion.networkID ~= id then
            local minionPos = minion.pos
            local posx,posz,onLineSegment = self:_closestPointToLineSegment(minionPos.x, minionPos.z, ax, az, bx, bz)
            local distanceToPoint = gsoAIO.Utils:_getDistance(minionPos, { x = posx, z = posz })
            if distanceToPoint < width + minion.boundingRadius + 25 then
                return true
            end
        end
    end
    return false
end

function __gsoUtils:_getCastPosGlobal(sourcePos, target, sD)
    local tP = target.pos
    local castpos,HitChance,pos = gsoAIO.TPred:GetBestCastPosition(target, sD.delay, sD.width*0.5, sD.range, sD.speed, sourcePos, sD.col, sD.sType)
    local distanceToSource = gsoAIO.Utils:_getDistance(sourcePos, castpos)
    local id = target.networkID
    if (gsoAIO.Load.meJinx or gsoAIO.Load.meAshe) and self:_checkHeroesCollision(castpos.x, castpos.z, sourcePos.x, sourcePos.z, sD.width, id) then
        return nil
    end
    if HitChance > 0 and gsoAIO.Utils:_getDistance(tP, castpos) < 500 and distanceToSource > 150 and distanceToSource < sD.range then
        return castpos
    end
    return nil
end

function __gsoUtils:_useKeySet(pos, hkSpell)
    local cPos = cursorPos
    Control.SetCursorPos(pos)
    Control.KeyDown(hkSpell)
    Control.KeyUp(hkSpell)
    gsoAIO.Orb.setCursor = pos
    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
    self.delayedActions[#self.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
end

function __gsoUtils:_useKeySetGlobal(pos, hkSpell)
    local cPos = cursorPos
    local extCastPos = myHero.pos:Extended(pos, 500)
    Control.SetCursorPos(extCastPos)
    Control.KeyDown(hkSpell)
    Control.KeyUp(hkSpell)
    gsoAIO.Orb.setCursor = extCastPos
    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
    self.delayedActions[#self.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
end

function __gsoUtils:_castSpell(gT, sT, spell, hkSpell)
    if self:_checkTimers(gT, sT) and Game.CanUseSpell(spell) == 0 then
        Control.KeyDown(hkSpell)
        Control.KeyUp(hkSpell)
        return true
    end
    return false
end

function __gsoUtils:_castSpell2(gT, sT, spell, hkSpell)
    if gsoAIO.Orb.dActionsC == 0 and self:_checkTimers(gT, sT) and Game.CanUseSpell(spell) == 0 then
        Control.KeyDown(hkSpell)
        Control.KeyUp(hkSpell)
        self.delayedActions[#self.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
        return true
    end
    return false
end

function __gsoUtils:_castSpellTarget(pos, spell, hkSpell, gT, sT)
    if pos and self:_isReady(gT, sT, spell) then
        self:_useKeySet(pos, hkSpell)
        return true
    end
    return false
end

function __gsoUtils:_castSpellSkillshot(sourcePos, target, sD, hkSpell)
    local castpos = self:_getCastPos(sourcePos, target, sD)
    if castpos then
        self:_useKeySet(castpos, hkSpell)
        return true
    end
    return false
end

function __gsoUtils:_castSpellSkillshotGlobal(sourcePos, target, sD, hkSpell)
    local castpos = self:_getCastPosGlobal(sourcePos, target, sD)
    if castpos then
        self:_useKeySetGlobal(castpos, hkSpell)
        return true
    end
    return false
end

function __gsoUtils:_countEnemyHeroesInRange(sourcePos, range, bb)
    local count = 0
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local unit = gsoAIO.OB.enemyHeroes[i]
        local extraRange = bb and unit.boundingRadius or 0
        if gsoAIO.Utils:_getDistance(sourcePos, unit.pos) < range + extraRange then
            count = count + 1
        end
    end
    return count
end

class "__gsoAatrox"

function __gsoAatrox:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoAatrox:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoAatrox:_onAttack(target)
end

function __gsoAatrox:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoAatrox:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoAatrox:_tick()
    
end

class "__gsoAhri"

function __gsoAhri:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoAhri:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoAhri:_onAttack(target)
end

function __gsoAhri:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoAhri:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoAhri:_tick()
    
end

class "__gsoAkali"

function __gsoAkali:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoAkali:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoAkali:_onAttack(target)
end

function __gsoAkali:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoAkali:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoAkali:_tick()
    
end

class "__gsoAlistar"

function __gsoAlistar:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoAlistar:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoAlistar:_onAttack(target)
end

function __gsoAlistar:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoAlistar:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoAlistar:_tick()
    
end

class "__gsoAmumu"

function __gsoAmumu:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoAmumu:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoAmumu:_onAttack(target)
end

function __gsoAmumu:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoAmumu:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoAmumu:_tick()
    
end

class "__gsoAnivia"

function __gsoAnivia:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoAnivia:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoAnivia:_onAttack(target)
end

function __gsoAnivia:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoAnivia:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoAnivia:_tick()
    
end

class "__gsoAnnie"

function __gsoAnnie:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoAnnie:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoAnnie:_onAttack(target)
end

function __gsoAnnie:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoAnnie:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoAnnie:_tick()
    
end

class "__gsoAshe"

function __gsoAshe:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.QEndTime = 0
    self.hasQBuff = false
    self.loadedChamps = false
    self.asNoQ = myHero.attackSpeed
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setAASpeed(function() return self:_aaSpeed() end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setBonusDmgUnit(function(unit) return self:_dmgUnit(unit) end)
end

function __gsoAshe:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    
    -- USE R :
    local canRd = (isCombo and gsoAIO.Menu.menu.gsoashe.rset.rcd:Value()) or (isHarass and gsoAIO.Menu.menu.gsoashe.rset.rcd:Value())
    local canRi = (isCombo and gsoAIO.Menu.menu.gsoashe.rset.rci:Value()) or (isHarass and gsoAIO.Menu.menu.gsoashe.rset.rhi:Value())
    if (canRd or canRi) and gsoAIO.Utils:_isReady(gT, { q = 0, w = 250, e = 250, r = 1000 }, _R) then
        local rPos = nil
        if canRd then
            local t = gsoAIO.Utils:_getClosestEnemy(mePos, gsoAIO.OB.enemyHeroes, gsoAIO.Menu.menu.gsoashe.rset.rdist:Value())
            rPos = t and gsoAIO.Utils:_getCastPos(mePos, t, { delay = 0.25, range = 1500, width = 125, speed = 1600, sType = "line", col = false }) or nil
        end
        if not rPos and canRi then
            local t = gsoAIO.Utils:_getImmobileEnemy(mePos, gsoAIO.OB.enemyHeroes, 1000)
            rPos = t and t.pos or nil
        end
        if rPos then
            gsoAIO.Utils:_useKeySet(rPos, HK_R)
            self.lastR = GetTickCount()
            self.canW = false
            return true
        end
    end
    
    -- USE Q :
    local canQ = ( isCombo and gsoAIO.Menu.menu.gsoashe.qset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsoashe.qset.harass:Value() )
    if canQ and afterAttack and beforeAttack and isTarget and gsoAIO.Utils:_castSpell(gT, { q = 1000, w = 350, e = 350, r = 350 }, _Q, HK_Q) then
        self.asNoQ = myHero.attackSpeed
        self.lastQ = GetTickCount()
        self.canW = false
        return true
    end
    
    if not isTarget or afterAttack then
        
        -- USE W :
        local canW = ( isCombo and gsoAIO.Menu.menu.gsoashe.wset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsoashe.wset.harass:Value() )
        if canW and gsoAIO.Utils:_isReady(gT, { q = 0, w = 1000, e = 250, r = 250 }, _W) and (not isTarget or (isTarget and self.canW)) then
            local wTarget = isTarget and target or gsoAIO.TS:_getTarget(1200, false, false, gsoAIO.OB.enemyHeroes)
            if wTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, wTarget, { delay = 0.25, range = 1200, width = 75, speed = 2000, sType = "line", col = true }, HK_W) then
                self.lastW = GetTickCount()
                return true
            end
        end
    end
    return false
end

function __gsoAshe:_aaSpeed()
    local num1 = self.QEndTime - GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    if num1 > -1500 and num1 < 0 then
        return self.asNoQ
    end
    return myHero.attackSpeed
end

function __gsoAshe:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 250, e = 250, r = 250 }) then
        return true
    end
    return false
end

function __gsoAshe:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 350, e = 350, r = 350 }) then
        return true
    end
    return false
end

function __gsoAshe:_tick()
    
    -- check q buff
    local qDuration = gsoAIO.Utils:_buffDuration(myHero, "asheqattack")
    self.hasQBuff = qDuration > 0
    self.QEndTime = qDuration > 0 and GetTickCount() + (qDuration*1000) or self.QEndTime
    
    -- load champions to menu
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsoashe.rset.semirashe.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    
    -- semi r
    if gsoAIO.Menu.menu.gsoashe.rset.semirashe.enabled:Value() and gsoAIO.Utils:_isReady(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 250, e = 250, r = 1000 }, _R) then
        local rTargets = {}
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local hero = gsoAIO.OB.enemyHeroes[i]
            local heroName = hero.charName
            local isFromList = gsoAIO.Menu.menu.gsoashe.rset.semirashe.useon[heroName] and gsoAIO.Menu.menu.gsoashe.rset.semirashe.useon[heroName]:Value()
            local hpPercent = gsoAIO.Menu.menu.gsoashe.rset.semirashe.semilow:Value() and gsoAIO.Menu.menu.gsoashe.rset.semirashe.semip:Value() or 100
            local isLowHP = isFromList and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if isLowHP then
                rTargets[#rTargets+1] = hero
            end
        end
        local rrange = gsoAIO.Menu.menu.gsoashe.rset.semirashe.rrange:Value()
        local rTarget = gsoAIO.TS:_getTarget(rrange, false, false, rTargets)
        if rTarget and gsoAIO.Utils:_castSpellSkillshotGlobal(myHero.pos, rTarget, { delay = 0.25, range = rrange, width = 125, speed = 1600, sType = "line", col = false }, HK_R) then
            self.lastR = GetTickCount()
        end
    end
end

function __gsoAshe:_dmgUnit(unit)
    local dmg = myHero.totalDamage
    local crit = 0.1 + myHero.critChance
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == "ashepassiveslow" then
            local aacompleteT = myHero.attackData.windUpTime + (gsoAIO.Utils:_getDistance(myHero.pos, unit.pos) / myHero.attackData.projectileSpeed)
            if aacompleteT + 0.1 < buff.duration then
                return dmg * crit
            end
        end
    end
    return 0
end

class "__gsoAurelionSol"

function __gsoAurelionSol:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoAurelionSol:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoAurelionSol:_onAttack(target)
end

function __gsoAurelionSol:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoAurelionSol:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoAurelionSol:_tick()
    
end

class "__gsoAzir"

function __gsoAzir:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoAzir:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoAzir:_onAttack(target)
end

function __gsoAzir:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoAzir:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoAzir:_tick()
    
end

class "__gsoBard"

function __gsoBard:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoBard:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoBard:_onAttack(target)
end

function __gsoBard:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoBard:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoBard:_tick()
    
end

class "__gsoBlitzcrank"

function __gsoBlitzcrank:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoBlitzcrank:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoBlitzcrank:_onAttack(target)
end

function __gsoBlitzcrank:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoBlitzcrank:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoBlitzcrank:_tick()
    
end

class "__gsoBrand"

function __gsoBrand:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoBrand:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoBrand:_onAttack(target)
end

function __gsoBrand:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoBrand:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoBrand:_tick()
    
end

class "__gsoBraum"

function __gsoBraum:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoBraum:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoBraum:_onAttack(target)
end

function __gsoBraum:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoBraum:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoBraum:_tick()
    
end

class "__gsoCaitlyn"

function __gsoCaitlyn:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoCaitlyn:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoCaitlyn:_onAttack(target)
end

function __gsoCaitlyn:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoCaitlyn:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoCaitlyn:_tick()
    
end

class "__gsoCamille"

function __gsoCamille:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoCamille:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoCamille:_onAttack(target)
end

function __gsoCamille:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoCamille:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoCamille:_tick()
    
end

class "__gsoCassiopeia"

function __gsoCassiopeia:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoCassiopeia:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoCassiopeia:_onAttack(target)
end

function __gsoCassiopeia:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoCassiopeia:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoCassiopeia:_tick()
    
end

class "__gsoChogath"

function __gsoChogath:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoChogath:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoChogath:_onAttack(target)
end

function __gsoChogath:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoChogath:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoChogath:_tick()
    
end

class "__gsoCorki"

function __gsoCorki:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoCorki:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoCorki:_onAttack(target)
end

function __gsoCorki:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoCorki:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoCorki:_tick()
    
end

class "__gsoDarius"

function __gsoDarius:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoDarius:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoDarius:_onAttack(target)
end

function __gsoDarius:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoDarius:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoDarius:_tick()
    
end

class "__gsoDiana"

function __gsoDiana:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoDiana:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoDiana:_onAttack(target)
end

function __gsoDiana:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoDiana:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoDiana:_tick()
    
end

class "__gsoDrMundo"

function __gsoDrMundo:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoDrMundo:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoDrMundo:_onAttack(target)
end

function __gsoDrMundo:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoDrMundo:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoDrMundo:_tick()
    
end

class "__gsoDraven"

function __gsoDraven:__init()
    self.qParticles = {}
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.lMove = 0
    gsoAIO.Callbacks:_setMousePos(function() return self:_setMousePos() end)
    gsoAIO.Callbacks:_setOnMove(function(target) return self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setDraw(function() self:_draw() end)
end

function __gsoDraven:_onAttack(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local canQ = ( gsoAIO.Menu.menu.orb.keys.combo:Value() and gsoAIO.Menu.menu.gsodraven.qset.combo:Value() ) or ( gsoAIO.Menu.menu.orb.keys.harass:Value() and gsoAIO.Menu.menu.gsodraven.qset.harass:Value() )
    if canQ and isTarget and gsoAIO.Utils:_castSpell(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 1000, w = 0, e = 250, r = 250 }, _Q, HK_Q) then
        self.lastQ = GetTickCount()
    end
end

function __gsoDraven:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    
    -- USE E :
    local canE = ( isCombo and gsoAIO.Menu.menu.gsodraven.eset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsodraven.eset.harass:Value() )
    if canE and gsoAIO.Utils:_isReady(gT, { q = 0, w = 0, e = 1000, r = 250 }, _E) then
        local eTarget = isTarget and target or gsoAIO.TS:_getTarget(1050, false, false, gsoAIO.OB.enemyHeroes)
        if eTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, eTarget, { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false }, HK_E) then
            self.lastE = GetTickCount()
            return true
        end
    end
    
    -- USE W :
    local canW = ( isCombo and gsoAIO.Menu.menu.gsodraven.wset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsodraven.wset.harass:Value() )
    if canW and Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 ) then
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local hero  = gsoAIO.OB.enemyHeroes[i]
            local delayNum = isTarget and 2750 or 2000
            if hero and gsoAIO.Utils:_valid(hero, false) and gsoAIO.Utils:_getDistance(myHero.pos, hero.pos) < gsoAIO.Menu.menu.gsodraven.wset.hdist:Value() then
                if gsoAIO.Utils:_castSpell2(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = delayNum, e = 350, r = 350 }, _W, HK_W) then
                    self.lastW = GetTickCount()
                    return true
                end
            end
        end
    end
    
    return false
end

function __gsoDraven:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 0, e = 250, r = 250 }) then
        return true
    end
    return false
end

function __gsoDraven:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 0, e = 350, r = 350 }) then
        return true
    end
    return false
end

function __gsoDraven:_setMousePos()
    if not gsoAIO.Menu.menu.gsodraven.aset.catch:Value() then return nil end
    local qPos = nil
    local kID = nil
    local num = 1000000000
    for k,v in pairs(self.qParticles) do
        if not v.success then
            local distanceToMouse = gsoAIO.Utils:_getDistance(v.pos, mousePos)
            if distanceToMouse < num then
                qPos = v.pos
                num = distanceToMouse
                kID = k
            end
        end
    end
    if qPos ~= nil then
        qPos = qPos:Extended(mousePos, gsoAIO.Menu.menu.gsodraven.aset.stopmove:Value())
        local stopNearUnit = gsoAIO.Utils:_nearTurret(qPos, 0, true) or gsoAIO.Utils:_nearHeroes(qPos, 0, true) or gsoAIO.Utils:_nearMinions(qPos, 0, true)
        local stopUnderTurret = gsoAIO.Menu.menu.gsodraven.aset.catcht:Value() and gsoAIO.Utils:_nearTurret(qPos, 775, false)
        local stopOutOfAARange = gsoAIO.Menu.menu.gsodraven.aset.catcho:Value() and not gsoAIO.Utils:_nearHeroes(qPos, myHero.range + myHero.boundingRadius + 30, false)
        if qPos and ( stopNearUnit or stopUnderTurret or stopOutOfAARange ) then
            qPos = nil
            self.qParticles[kID].active = false
        else
            self.qParticles[kID].active = true
        end
    end
    return qPos
end

function __gsoDraven:_tick()
    
    -- load champions to menu
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsodraven.rset.semirdraven.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    
    -- semi r
    if gsoAIO.Menu.menu.gsodraven.rset.semirdraven.enabled:Value() and gsoAIO.Utils:_isReady(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 100, e = 250, r = 1000 }, _R) then
        local rTargets = {}
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local hero = gsoAIO.OB.enemyHeroes[i]
            local heroName = hero.charName
            local isFromList = gsoAIO.Menu.menu.gsodraven.rset.semirdraven.useon[heroName] and gsoAIO.Menu.menu.gsodraven.rset.semirdraven.useon[heroName]:Value()
            local hpPercent = gsoAIO.Menu.menu.gsodraven.rset.semirdraven.semilow:Value() and gsoAIO.Menu.menu.gsodraven.rset.semirdraven.semip:Value() or 100
            local isLowHP = isFromList and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if isLowHP then
                rTargets[#rTargets+1] = hero
            end
        end
        local rrange = gsoAIO.Menu.menu.gsodraven.rset.semirdraven.rrange:Value()
        local rTarget = gsoAIO.TS:_getTarget(rrange, false, false, rTargets)
        if rTarget and gsoAIO.Utils:_castSpellSkillshotGlobal(myHero.pos, rTarget, { delay = 0.25, range = rrange, width = 125, speed = 2000, sType = "line", col = false }, HK_R) then
            self.lastR = GetTickCount()
        end
    end
    
    -- handle axes
    local mePos = myHero.pos
    for i = 1, Game.ParticleCount() do
        local particle = Game.Particle(i)
        local particlePos = particle and particle.pos or nil
        if particlePos and gsoAIO.Utils:_getDistance(mePos, particlePos) < 500 then
            local pname = particle.name
            if pname == "Draven_Base_Q_reticle" then
                local particleID = particle.handle
                if not self.qParticles[particleID] then
                    self.qParticles[particleID] = { pos = particlePos, tick = GetTickCount(), success = false, active = false }
                    gsoAIO.Orb.lMove = 0
                end
            end
        end
    end
    for k,v in pairs(self.qParticles) do
        local timerMinus = GetTickCount() - v.tick
        local numMenu = 900 - (gsoAIO.Utils.minPing*1000) + (myHero.ms - 330)*2
        if not v.success and timerMinus > numMenu then
            self.qParticles[k].success = true
            gsoAIO.Orb.lMove = 0
        end
        if timerMinus > numMenu and timerMinus < numMenu + 100 then
            gsoAIO.Orb.lMove = 0
        end
        if timerMinus > 2000 then
            self.qParticles[k] = nil
        end
    end
end

function __gsoDraven:_draw()
    if gsoAIO.Menu.menu.gsodraven.aset.catch:Value() then
        local aenabled = gsoAIO.Menu.menu.gsodraw.circle1.aaxeenable:Value()
        local ienabled = gsoAIO.Menu.menu.gsodraw.circle1.iaxeenable:Value()
        if aenabled or ienabled then
            for k,v in pairs(self.qParticles) do
                if not v.success then
                    if v.active and aenabled then
                        local acol = gsoAIO.Menu.menu.gsodraw.circle1.aaxecolor:Value()
                        local arad = gsoAIO.Menu.menu.gsodraw.circle1.aaxeradius:Value()
                        local awid = gsoAIO.Menu.menu.gsodraw.circle1.aaxewidth:Value()
                        Draw.Circle(v.pos, arad, awid, acol)
                    elseif ienabled then
                        local icol = gsoAIO.Menu.menu.gsodraw.circle1.iaxecolor:Value()
                        local irad = gsoAIO.Menu.menu.gsodraw.circle1.iaxeradius:Value()
                        local iwid = gsoAIO.Menu.menu.gsodraw.circle1.iaxewidth:Value()
                        Draw.Circle(v.pos, irad, iwid, icol)
                    end
                end
            end
        end
    end
end

class "__gsoEkko"

function __gsoEkko:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoEkko:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoEkko:_onAttack(target)
end

function __gsoEkko:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoEkko:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoEkko:_tick()
    
end

class "__gsoElise"

function __gsoElise:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoElise:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoElise:_onAttack(target)
end

function __gsoElise:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoElise:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoElise:_tick()
    
end

class "__gsoEvelynn"

function __gsoEvelynn:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoEvelynn:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoEvelynn:_onAttack(target)
end

function __gsoEvelynn:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoEvelynn:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoEvelynn:_tick()
    
end

class "__gsoEzreal"

function __gsoEzreal:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.shouldWaitT  = 0
    self.shouldWait   = false
    self.loadedChamps = false
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setDraw(function() self:_draw() end)
end

function __gsoEzreal:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    
    if not isTarget or afterAttack then
        
        -- Q :
        local canQ = gsoAIO.Utils:_isReady(gT, { q = 1000, w = 350, e = 500, r = 1100 }, _Q)
        local qout = gsoAIO.Menu.menu.gsoezreal.qset.qout:Value()
              canQ = canQ and ( not qout or (qout and not isTarget) )
        
        -- Q FARM :
        if canQ and ( not isTarget or (isTarget and self.canQ) ) and self:_castQFarm() then
            self.canW = false
            return true
        end
        
        -- Q COMBO :
        canQ = canQ and ( ( isCombo and gsoAIO.Menu.menu.gsoezreal.qset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsoezreal.qset.harass:Value() ) )
        if canQ and ( not isTarget or (isTarget and self.canQ) ) then
            local qTarget = isTarget and target or gsoAIO.TS:_getTarget(1150, true, false, gsoAIO.OB.enemyHeroes)
            local qTPos = qTarget and qTarget.pos or nil
            if qTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, qTarget, { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }, HK_Q) then
                self.lastQ = GetTickCount()
                self.canW = false
                return true
            end
        end
        
        -- USE W :
        local canW = ( isCombo and gsoAIO.Menu.menu.gsoezreal.wset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsoezreal.wset.harass:Value() )
        local wout = gsoAIO.Menu.menu.gsoezreal.wset.wout:Value()
              canW = canW and ( not wout or (wout and not isTarget) )
        if canW and gsoAIO.Utils:_isReady(gT, { q = 350, w = 1000, e = 500, r = 1100 }, _W) and ( not isTarget or (isTarget and self.canW) ) then
            local wTarget = isTarget and target or gsoAIO.TS:_getTarget(1000, false, false, gsoAIO.OB.enemyHeroes)
            if wTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, wTarget, { delay = 0.25, range = 1000, width = 80, speed = 1550, sType = "line", col = false }, HK_W) then
                self.lastW = GetTickCount()
                self.canQ = false
                return true
            end
        end
    end
    return false
end

function __gsoEzreal:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 175, w = 175, e = 250, r = 1000 }) then
        return true
    end
    return false
end

function __gsoEzreal:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 350, w = 350, e = 350, r = 1100 }) then
        return true
    end
    return false
end

function __gsoEzreal:_castQ(t)
    if t and gsoAIO.Utils:_castSpellSkillshot(myHero.pos, t, { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }, HK_Q) then
        self.lastQ = GetTickCount()
        self.canW = false
        return true
    end
    return false
end

function __gsoEzreal:_castQFarm()
    local meRange = myHero.range + myHero.boundingRadius
    local manaPercent = 100 * myHero.mana / myHero.maxMana
    local isLH = gsoAIO.Menu.menu.gsoezreal.qset.lasthit:Value() and (gsoAIO.Menu.menu.orb.keys.lastHit:Value() or gsoAIO.Menu.menu.orb.keys.harass:Value())
    local isLC = gsoAIO.Menu.menu.gsoezreal.qset.laneclear:Value() and gsoAIO.Menu.menu.orb.keys.laneClear:Value()
    if isLH or isLC then
        local canLH = manaPercent > gsoAIO.Menu.menu.gsoezreal.qset.qlh:Value()
        local canLC = manaPercent > gsoAIO.Menu.menu.gsoezreal.qset.qlc:Value()
        if not canLH and not canLC then return false end
        if self.shouldWait == true and Game.Timer() > self.shouldWaitT + 0.5 then
            self.shouldWait = false
        end
        local almostLH = false
        local laneClearT = {}
        local lastHitT = {}
        
        -- [[ set enemy minions ]]
        local mLH = gsoAIO.Menu.menu.orb.delays.lhDelay:Value()*0.001
        for i = 1, #gsoAIO.OB.enemyMinions do
            local eMinion = gsoAIO.OB.enemyMinions[i]
            local eMinion_handle	= eMinion.handle
            local eMinion_health	= eMinion.health
            local myHero_aaData		= myHero.attackData
            local myHero_pFlyTime	= gsoAIO.Utils:_getDistance(myHero.pos, eMinion.pos) / 2000
            for k1,v1 in pairs(gsoAIO.Farm.aAttacks) do
                for k2,v2 in pairs(gsoAIO.Farm.aAttacks[k1]) do
                    if v2.canceled == false and eMinion_handle == v2.to.handle then
                        local checkT	= Game.Timer()
                        local pEndTime	= v2.startTime + v2.pTime
                        if pEndTime > checkT and  pEndTime - checkT < myHero_pFlyTime - mLH then
                            eMinion_health = eMinion_health - v2.dmg
                        end
                    end
                end
            end
            local myHero_dmg = ((25 * myHero:GetSpellData(_Q).level) - 10) + (1.1 * myHero.totalDamage) + (0.4 * myHero.ap)
            if eMinion_health - myHero_dmg < 0 then
                lastHitT[#lastHitT+1] = eMinion
            else
                if eMinion.health - gsoAIO.Farm:_possibleDmg(eMinion, 2.5) - myHero_dmg < 0 then
                    almostLH = true
                    self.shouldWait = true
                    self.shouldWaitT = Game.Timer()
                else
                    laneClearT[#laneClearT+1] = eMinion
                end
            end
        end

        -- [[ lasthit ]]
        if isLH and canLH then
            local canCheckT = false
            for i = 1, #lastHitT do
                local unit = lastHitT[i]
                local unitPos = unit.pos
                local mePos = myHero.pos
                local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                local mHandle = unit.handle
                if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
            end
            if not canCheckT or (canCheckT and Game.Timer() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                for i = 1, #lastHitT do
                    local minion = lastHitT[i]
                    local minionPos = minion.pos
                    local mePos = myHero.pos
                    local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                    local mHandle = minion.handle
                    if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                        local distance = gsoAIO.Utils:_getDistance(mePos, minionPos)
                        if distance < 1150 and self:_castQ(minion, minionPos, mePos) then
                            gsoAIO.TS.LHTimers[0].tick = Game.Timer() + 0.75
                            gsoAIO.TS.LHTimers[0].id = mHandle
                            return true
                        end
                    end
                end
            end

        -- [[ laneclear ]]
        elseif isLC and canLC then

            local canCheckT = false
            for i = 1, #lastHitT do
                local unit = lastHitT[i]
                local unitPos = unit.pos
                local mePos = myHero.pos
                local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                local mHandle = unit.handle
                if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
            end
            if not canCheckT or (canCheckT and Game.Timer() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                for i = 1, #lastHitT do
                    local minion = lastHitT[i]
                    local minionPos = minion.pos
                    local mePos = myHero.pos
                    local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                    local mHandle = minion.handle
                    if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                        local distance = gsoAIO.Utils:_getDistance(mePos, minionPos)
                        if distance < 1150 and self:_castQ(minion, minionPos, mePos) then
                            gsoAIO.TS.LHTimers[0].tick = Game.Timer() + 0.75
                            gsoAIO.TS.LHTimers[0].id = mHandle
                            return true
                        end
                    end
                end
            end
            if not almostLH and not self.shouldWait then
                canCheckT = false
                for i = 1, #gsoAIO.OB.enemyHeroes do
                    local unit = gsoAIO.OB.enemyHeroes[i]
                    local unitPos = unit.pos
                    local mePos = myHero.pos
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
                if not canCheckT or (canCheckT and Game.Timer() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                    for i = 1, #gsoAIO.OB.enemyHeroes do
                        local unit = gsoAIO.OB.enemyHeroes[i]
                        local unitPos = unit.pos
                        local mePos = myHero.pos
                        local distance = gsoAIO.Utils:_getDistance(mePos, unitPos)
                        if gsoAIO.Utils:_valid(unit, true) and distance < 1150 and self:_castQ(unit, unitPos, mePos) then return true end
                    end
                end
                canCheckT = false
                for i = 1, #laneClearT do
                    local unit = laneClearT[i]
                    local unitPos = unit.pos
                    local mePos = myHero.pos
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
                if not canCheckT or (canCheckT and Game.Timer() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                    for i = 1, #laneClearT do
                        local minion = laneClearT[i]
                        local minionPos = minion.pos
                        local mePos = myHero.pos
                        local distance = gsoAIO.Utils:_getDistance(myHero.pos, minionPos)
                        if distance < 1150 and self:_castQ(minion, minionPos, mePos) then return true end
                    end
                end
            end
        end
    end
    return false
end

function __gsoEzreal:_tick()
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsoezreal.rset.semirez.useon:MenuElement({id = heroName, name = heroName, value = true})
            gsoAIO.Menu.menu.gsoezreal.autoq.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    if getTick - self.lastE > 1000 and Game.CanUseSpell(_E) == 0 then
        local dActions = gsoAIO.WndMsg.delayedSpell
        for k,v in pairs(dActions) do
            if k == 2 then
                if gsoAIO.Orb.dActionsC == 0 then
                    v[1]()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() return 0 end, 50 }
                    gsoAIO.Orb.enableAA = false
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.lastE = GetTickCount()
                    gsoAIO.WndMsg.delayedSpell[k] = nil
                    break
                end
                if GetTickCount() - v[2] > 125 then
                    gsoAIO.WndMsg.delayedSpell[k] = nil
                end
                break
            end
        end
    end
    
    -- semi r
    if gsoAIO.Menu.menu.gsoezreal.rset.semirez.enabled:Value() and gsoAIO.Utils:_isReady(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 350, w = 350, e = 550, r = 1100 }, _R) then
        local rTargets = {}
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local hero = gsoAIO.OB.enemyHeroes[i]
            local heroName = hero.charName
            local isFromList = gsoAIO.Menu.menu.gsoezreal.rset.semirez.useon[heroName] and gsoAIO.Menu.menu.gsoezreal.rset.semirez.useon[heroName]:Value()
            local hpPercent = gsoAIO.Menu.menu.gsoezreal.rset.semirez.semilow:Value() and gsoAIO.Menu.menu.gsoezreal.rset.semirez.semip:Value() or 100
            local isLowHP = isFromList and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if isLowHP then
                rTargets[#rTargets+1] = hero
            end
        end
        local rrange = gsoAIO.Menu.menu.gsoezreal.rset.semirez.rrange:Value()
        local rTarget = gsoAIO.TS:_getTarget(rrange, false, false, rTargets)
        if rTarget and gsoAIO.Utils:_castSpellSkillshotGlobal(myHero.pos, rTarget, { delay = 1, range = rrange, width = 160, speed = 2000, sType = "line", col = false }, HK_R) then
            self.lastR = GetTickCount()
        end
    end
    
    -- AUTO Q :
    local qout = gsoAIO.Menu.menu.gsoezreal.qset.qout:Value()
    local canQ = gsoAIO.Menu.menu.gsoezreal.autoq.enable:Value() and not gsoAIO.Menu.menu.orb.keys.combo:Value() and not gsoAIO.Menu.menu.orb.keys.harass:Value()
          canQ = canQ and gsoAIO.Utils:_isReady(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 1000, w = 350, e = 550, r = 1100 }, _Q)
          canQ = canQ and ( 100 * myHero.mana ) / myHero.maxMana > gsoAIO.Menu.menu.gsoezreal.autoq.mana:Value()
          canQ = canQ and ( not qout or (qout and gsoAIO.Utils:_countEnemyHeroesInRange(myHero.pos, myHero.range + myHero.boundingRadius, true) == 0) )
    if canQ then
        local meRange = myHero.range + myHero.boundingRadius
        local mePos = myHero.pos
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local unit = gsoAIO.OB.enemyHeroes[i]
            local unitName = unit.charName
            if gsoAIO.Menu.menu.gsoezreal.autoq.useon[unitName] and gsoAIO.Menu.menu.gsoezreal.autoq.useon[unitName]:Value() then
                local unitPos = unit.pos
                local distance = gsoAIO.Utils:_getDistance(mePos, unitPos)
                local isAA = distance < meRange + unit.boundingRadius
                if gsoAIO.Utils:_valid(unit, true) and distance < 1150 and ( not isAA or (isAA and self.canQ) ) and gsoAIO.Utils:_castSpellSkillshot(mePos, unit, { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }, HK_Q) then
                    self.lastQ = GetTickCount()
                    self.canW = false
                    break
                end
            end
        end
    end
end

function __gsoEzreal:_draw()
    if gsoAIO.Menu.menu.gsodraw.texts1.enableautoq:Value() then
        local mePos = myHero.pos:To2D()
        local posX = mePos.x - 50
        local posY = mePos.y
        if gsoAIO.Menu.menu.gsoezreal.autoq.enable:Value() then
            Draw.Text("Auto Q Enabled", gsoAIO.Menu.menu.gsodraw.texts1.sizeautoq:Value(), posX, posY, gsoAIO.Menu.menu.gsodraw.texts1.colorautoqe:Value()) 
        else
            Draw.Text("Auto Q Disabled", gsoAIO.Menu.menu.gsodraw.texts1.sizeautoq:Value(), posX, posY, gsoAIO.Menu.menu.gsodraw.texts1.colorautoqd:Value()) 
        end
    end
end

class "__gsoFiddlesticks"

function __gsoFiddlesticks:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoFiddlesticks:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoFiddlesticks:_onAttack(target)
end

function __gsoFiddlesticks:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoFiddlesticks:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoFiddlesticks:_tick()
    
end

class "__gsoFiora"

function __gsoFiora:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoFiora:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoFiora:_onAttack(target)
end

function __gsoFiora:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoFiora:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoFiora:_tick()
    
end

class "__gsoFizz"

function __gsoFizz:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoFizz:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoFizz:_onAttack(target)
end

function __gsoFizz:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoFizz:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoFizz:_tick()
    
end

class "__gsoGalio"

function __gsoGalio:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoGalio:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoGalio:_onAttack(target)
end

function __gsoGalio:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoGalio:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoGalio:_tick()
    
end

class "__gsoGangplank"

function __gsoGangplank:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoGangplank:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoGangplank:_onAttack(target)
end

function __gsoGangplank:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoGangplank:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoGangplank:_tick()
    
end

class "__gsoGaren"

function __gsoGaren:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoGaren:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoGaren:_onAttack(target)
end

function __gsoGaren:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoGaren:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoGaren:_tick()
    
end

class "__gsoGnar"

function __gsoGnar:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoGnar:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoGnar:_onAttack(target)
end

function __gsoGnar:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoGnar:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoGnar:_tick()
    
end

class "__gsoGragas"

function __gsoGragas:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoGragas:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoGragas:_onAttack(target)
end

function __gsoGragas:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoGragas:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoGragas:_tick()
    
end

class "__gsoGraves"

function __gsoGraves:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoGraves:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoGraves:_onAttack(target)
end

function __gsoGraves:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoGraves:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoGraves:_tick()
    
end

class "__gsoHecarim"

function __gsoHecarim:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoHecarim:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoHecarim:_onAttack(target)
end

function __gsoHecarim:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoHecarim:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoHecarim:_tick()
    
end

class "__gsoHeimerdinger"

function __gsoHeimerdinger:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoHeimerdinger:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoHeimerdinger:_onAttack(target)
end

function __gsoHeimerdinger:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoHeimerdinger:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoHeimerdinger:_tick()
    
end

class "__gsoIllaoi"

function __gsoIllaoi:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoIllaoi:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoIllaoi:_onAttack(target)
end

function __gsoIllaoi:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoIllaoi:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoIllaoi:_tick()
    
end

class "__gsoIrelia"

function __gsoIrelia:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoIrelia:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoIrelia:_onAttack(target)
end

function __gsoIrelia:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoIrelia:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoIrelia:_tick()
    
end

class "__gsoIvern"

function __gsoIvern:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoIvern:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoIvern:_onAttack(target)
end

function __gsoIvern:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoIvern:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoIvern:_tick()
    
end

class "__gsoJanna"

function __gsoJanna:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoJanna:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoJanna:_onAttack(target)
end

function __gsoJanna:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoJanna:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoJanna:_tick()
    
end

class "__gsoJarvanIV"

function __gsoJarvanIV:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoJarvanIV:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoJarvanIV:_onAttack(target)
end

function __gsoJarvanIV:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoJarvanIV:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoJarvanIV:_tick()
    
end

class "__gsoJax"

function __gsoJax:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoJax:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoJax:_onAttack(target)
end

function __gsoJax:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoJax:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoJax:_tick()
    
end

class "__gsoJayce"

function __gsoJayce:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoJayce:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoJayce:_onAttack(target)
end

function __gsoJayce:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoJayce:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoJayce:_tick()
    
end

class "__gsoJhin"

function __gsoJhin:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoJhin:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoJhin:_onAttack(target)
end

function __gsoJhin:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoJhin:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoJhin:_tick()
    
end

class "__gsoJinx"

function __gsoJinx:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.hasQBuff = false
    self.loadedChamps = false
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoJinx:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    
    -- USE E :
    local canE = ( isCombo and gsoAIO.Menu.menu.gsojinx.eset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsojinx.eset.harass:Value() )
    if canE and gsoAIO.Utils:_isReadyFast(gT, { q = 650, w = 550, e = 1000, r = 550 }, _E) then
        local t = gsoAIO.Utils:_getImmobileEnemy(mePos, gsoAIO.OB.enemyHeroes, 900)
        if t then
            gsoAIO.Utils:_useKeySet(t.pos, HK_E)
            self.lastE = GetTickCount()
            return true
        end
    end
    
    -- USE Q :
    local canQ = ( isCombo and gsoAIO.Menu.menu.gsojinx.qset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsojinx.qset.harass:Value() )
    if canQ and gsoAIO.Utils:_isReadyFast(gT, { q = 650, w = 550, e = 75, r = 550 }, _Q) then
        local mePos = myHero.pos
        local canCastQ = false
        local qRange = 575 + ( 25 * myHero:GetSpellData(_Q).level )
        if not isTarget and not self.hasQBuff and gsoAIO.Utils:_countEnemyHeroesInRange(mePos, qRange + 300) > 0 then
            canCastQ = true
        end
        if isTarget and self.hasQBuff and gsoAIO.Utils:_getDistance(mePos, target.pos) < 525 + myHero.boundingRadius then
            canCastQ = true
        end
        if canCastQ then
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            self.lastQ = GetTickCount()
            return true
        end
    end
    
    if not isTarget or afterAttack then
        local wout = gsoAIO.Menu.menu.gsojinx.wset.wout:Value()
        if not wout or (wout and not isTarget) then
            local canW = ( isCombo and gsoAIO.Menu.menu.gsojinx.wset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsojinx.wset.harass:Value() )
            if canW and gsoAIO.Utils:_isReady(gT, { q = 0, w = 1000, e = 75, r = 550 }, _W) and (not isTarget or (isTarget and self.canW)) then
                local wTarget = isTarget and target or gsoAIO.TS:_getTarget(1175, false, false, gsoAIO.OB.enemyHeroes)
                if wTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, wTarget, { delay = 0.5, range = 1450, width = 70, speed = 3200, sType = "line", col = true }, HK_W) then
                    self.lastW = GetTickCount()
                    return true
                end
            end
        end
    end
    return false
end

function __gsoJinx:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 500, e = 0, r = 500 }) then
        return true
    end
    return false
end

function __gsoJinx:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 600, e = 0, r = 600 }) then
        return true
    end
    return false
end

function __gsoJinx:_tick()
    self.hasQBuff = gsoAIO.Utils:_hasBuff(myHero, "jinxq")
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsojinx.rset.semirjinx.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    
    -- semi r
    if gsoAIO.Menu.menu.gsojinx.rset.semirjinx.enabled:Value() and gsoAIO.Utils:_isReady(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 550, e = 75, r = 1000 }, _R) then
        local rTargets = {}
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local hero = gsoAIO.OB.enemyHeroes[i]
            local heroName = hero.charName
            local isFromList = gsoAIO.Menu.menu.gsojinx.rset.semirjinx.useon[heroName] and gsoAIO.Menu.menu.gsojinx.rset.semirjinx.useon[heroName]:Value()
            local hpPercent = gsoAIO.Menu.menu.gsojinx.rset.semirjinx.semilow:Value() and gsoAIO.Menu.menu.gsojinx.rset.semirjinx.semip:Value() or 100
            local isLowHP = isFromList and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth <= hpPercent
            if isLowHP then
                rTargets[#rTargets+1] = hero
            end
        end
        local rrange = gsoAIO.Menu.menu.gsojinx.rset.semirjinx.rrange:Value()
        local rTarget = gsoAIO.TS:_getTarget(rrange, false, false, rTargets)
        if rTarget and gsoAIO.Utils:_castSpellSkillshotGlobal(myHero.pos, rTarget, { delay = 0.5, range = rrange, width = 225, speed = 1750, sType = "line", col = false }, HK_R) then
            self.lastR = GetTickCount()
        end
    end
end

class "__gsoKalista"

function __gsoKalista:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKalista:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKalista:_onAttack(target)
end

function __gsoKalista:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKalista:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKalista:_tick()
    
end

class "__gsoKarma"

function __gsoKarma:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKarma:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKarma:_onAttack(target)
end

function __gsoKarma:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKarma:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKarma:_tick()
    
end

class "__gsoKarthus"

function __gsoKarthus:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKarthus:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKarthus:_onAttack(target)
end

function __gsoKarthus:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKarthus:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKarthus:_tick()
    
end

class "__gsoKassadin"

function __gsoKassadin:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKassadin:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKassadin:_onAttack(target)
end

function __gsoKassadin:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKassadin:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKassadin:_tick()
    
end

class "__gsoKatarina"

function __gsoKatarina:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKatarina:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKatarina:_onAttack(target)
end

function __gsoKatarina:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKatarina:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKatarina:_tick()
    
end

class "__gsoKayle"

function __gsoKayle:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKayle:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKayle:_onAttack(target)
end

function __gsoKayle:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKayle:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKayle:_tick()
    
end

class "__gsoKayn"

function __gsoKayn:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKayn:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKayn:_onAttack(target)
end

function __gsoKayn:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKayn:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKayn:_tick()
    
end

class "__gsoKennen"

function __gsoKennen:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKennen:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKennen:_onAttack(target)
end

function __gsoKennen:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKennen:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKennen:_tick()
    
end

class "__gsoKhazix"

function __gsoKhazix:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKhazix:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKhazix:_onAttack(target)
end

function __gsoKhazix:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKhazix:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKhazix:_tick()
    
end

class "__gsoKindred"

function __gsoKindred:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKindred:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKindred:_onAttack(target)
end

function __gsoKindred:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKindred:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKindred:_tick()
    
end

class "__gsoKled"

function __gsoKled:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoKled:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoKled:_onAttack(target)
end

function __gsoKled:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoKled:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoKled:_tick()
    
end

class "__gsoKogMaw"

function __gsoKogMaw:__init()
    gsoAIO.TS.apDmg = true
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.hasWBuff = false
    self.loadedChamps = false
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setTick(function() self:_tick() end)
end

function __gsoKogMaw:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    
    if not isTarget or afterAttack then
        
        local wMana = 40 - ( myHero:GetSpellData(_W).currentCd * myHero.mpRegen )
        local meMana = myHero.mana - wMana
        
        -- USE Q :
        local canQ = ( isCombo and gsoAIO.Menu.menu.gsokog.qset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsokog.qset.harass:Value() )
              canQ = canQ and meMana > myHero:GetSpellData(_Q).mana and ( (not isTarget and GetTickCount() - self.lastW > 350) or (isTarget and self.canQ) )
        if canQ and gsoAIO.Utils:_isReady(gT, { q = 1000, w = 150, e = 350, r = 350 }, _Q) and (not isTarget or (isTarget and self.canQ)) then
            local qTarget = isTarget and target or gsoAIO.TS:_getTarget(1175, false, false, gsoAIO.OB.enemyHeroes)
            if qTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, qTarget, { delay = 0.25, range = 1175, width = 70, speed = 1650, sType = "line", col = true }, HK_Q) then
                self.lastQ = GetTickCount()
                self.canE = false
                self.canR = false
                return true
            end
        end
        
        -- USE E :
        local canE = ( isCombo and gsoAIO.Menu.menu.gsokog.eset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsokog.eset.harass:Value() )
              canE = canE and meMana > myHero:GetSpellData(_E).mana and ( (not isTarget and GetTickCount() - self.lastW > 350) or (isTarget and self.canE) )
              canE = canE and ( myHero.mana * 100 ) / myHero.maxMana > gsoAIO.Menu.menu.gsokog.eset.emana:Value()
        if canE and gsoAIO.Utils:_isReady(gT, { q = 350, w = 150, e = 1000, r = 350 }, _E) and (not isTarget or (isTarget and self.canE)) then
            local eTarget = isTarget and target or gsoAIO.TS:_getTarget(1280, false, false, gsoAIO.OB.enemyHeroes)
            if eTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, eTarget, { delay = 0.25, range = 1280, width = 120, speed = 1350, sType = "line", col = false }, HK_E) then
                self.lastE = GetTickCount()
                self.canQ = false
                self.canR = false
                return true
            end
        end
        
        -- USE R :
        local rStacks = gsoAIO.Utils:_buffCount(myHero, "kogmawlivingartillerycost") < gsoAIO.Menu.menu.gsokog.rset.stack:Value()
        local stopRIfW = gsoAIO.Menu.menu.gsokog.wset.stopr:Value() and self.hasWBuff
        local canR = ( isCombo and gsoAIO.Menu.menu.gsokog.rset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsokog.rset.harass:Value() )
              canR = canR and rStacks and not stopRIfW and gsoAIO.Utils:_isReady(gT, { q = 350, w = 150, e = 350, r = 750 }, _R) and (not isTarget or (isTarget and self.canR))
              canR = canR and meMana > myHero:GetSpellData(_R).mana and ( myHero.mana * 100 ) / myHero.maxMana > gsoAIO.Menu.menu.gsokog.rset.rmana:Value()
        if canR and ( (not isTarget and GetTickCount() - self.lastW > 350) or (isTarget and self.canR) ) then
            
            local rrange = 900 + ( 300 * myHero:GetSpellData(_R).level )
            
            -- only enemies with hp lower than 40%
            local onlyLowR = gsoAIO.Menu.menu.gsokog.rset.onlylow:Value()
            
            -- check for target in attack range
            local rTarget = nil
            if not onlyLowR and isTarget then rTarget = target end
            if onlyLowR and isTarget and ( target.health * 100 ) / target.maxHealth < 39 then rTarget = target end
            
            -- check for targets in R range
            local rTargets = {}
            if not rTarget then
                if onlyLowR then
                    for i = 1, #gsoAIO.OB.enemyHeroes do
                        local hero = gsoAIO.OB.enemyHeroes[i]
                        if hero and ( hero.health * 100 ) / hero.maxHealth < 39 then
                            rTargets[#rTargets+1] = hero
                        end
                    end
                else
                    rTargets = gsoAIO.OB.enemyHeroes
                end
            end
            
            -- target
            local rT = rTarget and rTarget or gsoAIO.TS:_getTarget(rrange + 112, false, false, rTargets)
            if rT and gsoAIO.Utils:_castSpellSkillshot(mePos, rT, { delay = 1.2, range = rrange, width = 225, speed = math.maxinteger, sType = "circular", col = false }, HK_R) then
                self.lastR = GetTickCount()
                self.canQ = false
                self.canE = false
                return true
            end
        end
    end
    return false
end

function __gsoKogMaw:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 250, w = 0, e = 250, r = 250 }) then
        return true
    end
    return false
end

function __gsoKogMaw:_canAttack(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local mePos = myHero.pos
    
    -- USE W :
    local canW = ( gsoAIO.Menu.menu.orb.keys.combo:Value() and gsoAIO.Menu.menu.gsokog.wset.combo:Value() ) or ( gsoAIO.Menu.menu.orb.keys.harass:Value() and gsoAIO.Menu.menu.gsokog.wset.harass:Value() )
          canW = canW and gsoAIO.Utils:_isReadyFast(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 250, w = 1000, e = 250, r = 250 }, _W)
          canW = canW and gsoAIO.Utils:_countEnemyHeroesInRange(mePos, 610 + ( 20 * myHero:GetSpellData(_W).level ) + myHero.boundingRadius, true) > 0
    if canW and beforeAttack then
        Control.KeyDown(HK_W)
        Control.KeyUp(HK_W)
        self.lastW = GetTickCount()
        self.canQ = false
        self.canE = false
        self.canR = false
    end
    
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 350, w = 0, e = 350, r = 350 }) then
        return true
    end
    return false
end

function __gsoKogMaw:_tick()
    if not self.loadedChamps and gsoAIO.TS.loadedChamps then
        for i = 1, #gsoAIO.TS.enemyHNames do
            local heroName = gsoAIO.TS.enemyHNames[i]
            gsoAIO.Menu.menu.gsokog.rset.semirmenu.useon:MenuElement({id = heroName, name = heroName, value = true})
        end
        self.loadedChamps = true
    end
    local hasWBuff = false
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        local buffName = buff and buff.name or nil
        if buffName and buff.count > 0 and buff.duration > 0 then
            if buffName == "KogMawBioArcaneBarrage" then
                hasWBuff = true
                break
            end
        end
    end
    self.hasWBuff = hasWBuff
    local mePos = myHero.pos
    
    local canR = gsoAIO.Utils:_isReady(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 350, w = 150, e = 350, r = 750 }, _R)
    if canR and Game.Timer() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT + gsoAIO.Utils.maxPing then
        
        -- spell data
        local sR = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false }
        sR.range = 900 + ( 300 * myHero:GetSpellData(_R).level )
        
        local rStacks = gsoAIO.Utils:_buffCount(myHero, "kogmawlivingartillerycost") < gsoAIO.Menu.menu.gsokog.rset.stack:Value()
        local checkRStacksKS = gsoAIO.Menu.menu.gsokog.rset.ksmenu.csksr:Value()
        if gsoAIO.Menu.menu.gsokog.rset.ksmenu.ksr:Value() and ( not checkRStacksKS or ( checkRStacksKS and rStacks ) ) then
        
            -- check for killable targets in R range
            local rTargets = {}
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local baseRDmg = 60 + ( 40 * myHero:GetSpellData(_R).level ) + ( myHero.bonusDamage * 0.65 ) + ( myHero.ap * 0.25 )
                local rMultipier = math.floor(100 - ( ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth ))
                local rDmg = rMultipier > 60 and baseRDmg * 2 or baseRDmg * ( 1 + ( rMultipier * 0.00833 ) )
                      rDmg = gsoAIO.Dmg.PredHP(hero, { dmgAP = rDmg, dmgType = "ap" } )
                local unitKillable = rDmg > hero.health + (hero.hpRegen * 2)
                if unitKillable then
                    rTargets[#rTargets+1] = hero
                end
            end
            
            -- target
            local rT = #rTargets == 0 and nil or gsoAIO.TS:_getTarget(sR.range + (sR.width*0.5), false, false, rTargets)
            
            -- use spell
            if rT and gsoAIO.Utils:_castSpellSkillshot(mePos, rT, sR, HK_R) then
                self.lastR = GetTickCount()
                self.canQ = false
                self.canE = false
                return
            end
        end
        
        local checkRStacksSemi = gsoAIO.Menu.menu.gsokog.rset.semirmenu.semistacks:Value()
        if gsoAIO.Menu.menu.gsokog.rset.semirmenu.semir:Value() and ( not checkRStacksSemi or ( checkRStacksSemi and rStacks ) ) then
            
            -- only enemies with hp lower than 40%
            local onlyLowR = gsoAIO.Menu.menu.gsokog.rset.semirmenu.semilow:Value()

            -- check for targets in R range
            local rTargets = {}
            if onlyLowR then
                for i = 1, #gsoAIO.OB.enemyHeroes do
                    local hero = gsoAIO.OB.enemyHeroes[i]
                    if hero and ( ( hero.health + ( hero.hpRegen * 3 ) ) * 100 ) / hero.maxHealth < 40 then
                        rTargets[#rTargets+1] = hero
                    end
                end
            else
                rTargets = gsoAIO.OB.enemyHeroes
            end
            
            -- target
            local rT = #rTargets == 0 and nil or gsoAIO.TS:_getTarget(sR.range + (sR.width*0.5), false, false, rTargets)
            
            -- use spell
            if rT and gsoAIO.Utils:_castSpellSkillshot(mePos, rT, sR, HK_R) then
                self.lastR = GetTickCount()
                self.canQ = false
                self.canE = false
                return
            end
        end
    end
end

class "__gsoLeblanc"

function __gsoLeblanc:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoLeblanc:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoLeblanc:_onAttack(target)
end

function __gsoLeblanc:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoLeblanc:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoLeblanc:_tick()
    
end

class "__gsoLeeSin"

function __gsoLeeSin:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoLeeSin:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoLeeSin:_onAttack(target)
end

function __gsoLeeSin:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoLeeSin:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoLeeSin:_tick()
    
end

class "__gsoLeona"

function __gsoLeona:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoLeona:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoLeona:_onAttack(target)
end

function __gsoLeona:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoLeona:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoLeona:_tick()
    
end

class "__gsoLissandra"

function __gsoLissandra:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoLissandra:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoLissandra:_onAttack(target)
end

function __gsoLissandra:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoLissandra:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoLissandra:_tick()
    
end

class "__gsoLucian"

function __gsoLucian:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoLucian:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
        local canE = ( isCombo and gsoAIO.Menu.menu.gsolucian.eset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsolucian.eset.harass:Value() )
              canE = canE and gsoAIO.Utils:_isReadyFast(gT, { q = 500, w = 250, e = 1000, r = 3350 }, _E)
        if canE and (not isTarget or (isTarget and self.canE)) then
            local meRange = myHero.range + myHero.boundingRadius
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local heroPos = hero.pos
                local distToMouse = gsoAIO.Utils:_getDistance(mePos, mousePos)
                local distToHero = gsoAIO.Utils:_getDistance(mePos, heroPos)
                local distToEndPos = gsoAIO.Utils:_getDistance(mePos, hero.pathing.endPos)
                local extRange
                if distToEndPos > distToHero then
                    extRange = distToMouse > 325 and 325 or distToMouse
                else
                    extRange = distToMouse > 425 and 425 or distToMouse
                end
                local extPos = mePos + (mousePos-mePos):Normalized() * extRange
                local distEnemyToExt = gsoAIO.Utils:_getDistance(extPos, heroPos)
                if gsoAIO.Utils:_valid(hero, true) and distEnemyToExt < meRange + hero.boundingRadius then
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    self.lastE = GetTickCount()
                    self.canQ = false
                    self.canW = false
                    self.canR = false
                    gsoAIO.Orb.aaReset = true
                    return true
                end
            end
        end
        local canQ = (isCombo and gsoAIO.Menu.menu.gsolucian.qset.combo:Value()) or (isHarass and gsoAIO.Menu.menu.gsolucian.qset.harass:Value())
        if canQ and (not isTarget or (isTarget and self.canQ)) then
            if isTarget and not gsoAIO.Utils:_nearUnit(target.pos, target.networkID) and gsoAIO.Utils:_castSpellTarget(target.pos, _Q, HK_Q, gT, { q = 1000, w = 350, e = 350, r = 3350 }) then
                self.lastQ = GetTickCount()
                self.canW = false
                self.canE = false
                self.canR = false
                return true
            end
        end
        local canW = ( isCombo and gsoAIO.Menu.menu.gsolucian.wset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsolucian.wset.harass:Value() )
        if canW and gsoAIO.Utils:_isReady(gT, { q = 500, w = 1000, e = 350, r = 3350 }, _W) and (not isTarget or (isTarget and self.canW)) then
            local wTarget = isTarget and target or gsoAIO.TS:_getTarget(1350, false, false, gsoAIO.OB.enemyHeroes)
            if wTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, wTarget, { delay = 0.25, range = 1250, width = 75, speed = 1600, sType = "line", col = false }, HK_W) then
                self.canQ = false
                self.canE = false
                self.canR = false
                return true
            end
        end
    end
end

function __gsoLucian:_onAttack(target)
end

function __gsoLucian:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 200, e = 200, r = 1000 }) then
        return true
    end
    return true
end

function __gsoLucian:_canAttack(target)
    if not gsoAIO.Utils:_hasBuff(myHero, "lucianr") and gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 0, e = 200, r = 0 }) then
        return true
    end
    return false
end

function __gsoLucian:_tick()
    
end

class "__gsoLulu"

function __gsoLulu:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoLulu:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoLulu:_onAttack(target)
end

function __gsoLulu:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoLulu:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoLulu:_tick()
    
end

class "__gsoLux"

function __gsoLux:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoLux:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoLux:_onAttack(target)
end

function __gsoLux:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoLux:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoLux:_tick()
    
end

class "__gsoMalphite"

function __gsoMalphite:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoMalphite:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoMalphite:_onAttack(target)
end

function __gsoMalphite:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoMalphite:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoMalphite:_tick()
    
end

class "__gsoMalzahar"

function __gsoMalzahar:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoMalzahar:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoMalzahar:_onAttack(target)
end

function __gsoMalzahar:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoMalzahar:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoMalzahar:_tick()
    
end

class "__gsoMaokai"

function __gsoMaokai:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoMaokai:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoMaokai:_onAttack(target)
end

function __gsoMaokai:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoMaokai:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoMaokai:_tick()
    
end

class "__gsoMasterYi"

function __gsoMasterYi:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoMasterYi:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoMasterYi:_onAttack(target)
end

function __gsoMasterYi:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoMasterYi:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoMasterYi:_tick()
    
end

class "__gsoMissFortune"

function __gsoMissFortune:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoMissFortune:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoMissFortune:_onAttack(target)
end

function __gsoMissFortune:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoMissFortune:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoMissFortune:_tick()
    
end

class "__gsoMonkeyKing"

function __gsoMonkeyKing:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoMonkeyKing:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoMonkeyKing:_onAttack(target)
end

function __gsoMonkeyKing:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoMonkeyKing:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoMonkeyKing:_tick()
    
end

class "__gsoMordekaiser"

function __gsoMordekaiser:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoMordekaiser:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoMordekaiser:_onAttack(target)
end

function __gsoMordekaiser:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoMordekaiser:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoMordekaiser:_tick()
    
end

class "__gsoMorgana"

function __gsoMorgana:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoMorgana:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoMorgana:_onAttack(target)
end

function __gsoMorgana:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoMorgana:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoMorgana:_tick()
    
end

class "__gsoNami"

function __gsoNami:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoNami:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoNami:_onAttack(target)
end

function __gsoNami:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoNami:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoNami:_tick()
    
end

class "__gsoNasus"

function __gsoNasus:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoNasus:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoNasus:_onAttack(target)
end

function __gsoNasus:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoNasus:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoNasus:_tick()
    
end

class "__gsoNautilus"

function __gsoNautilus:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoNautilus:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoNautilus:_onAttack(target)
end

function __gsoNautilus:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoNautilus:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoNautilus:_tick()
    
end

class "__gsoNidalee"

function __gsoNidalee:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoNidalee:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoNidalee:_onAttack(target)
end

function __gsoNidalee:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoNidalee:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoNidalee:_tick()
    
end

class "__gsoNocturne"

function __gsoNocturne:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoNocturne:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoNocturne:_onAttack(target)
end

function __gsoNocturne:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoNocturne:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoNocturne:_tick()
    
end

class "__gsoNunu"

function __gsoNunu:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoNunu:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoNunu:_onAttack(target)
end

function __gsoNunu:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoNunu:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoNunu:_tick()
    
end

class "__gsoOlaf"

function __gsoOlaf:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoOlaf:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoOlaf:_onAttack(target)
end

function __gsoOlaf:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoOlaf:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoOlaf:_tick()
    
end

class "__gsoOrianna"

function __gsoOrianna:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoOrianna:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoOrianna:_onAttack(target)
end

function __gsoOrianna:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoOrianna:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoOrianna:_tick()
    
end

class "__gsoOrnn"

function __gsoOrnn:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoOrnn:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoOrnn:_onAttack(target)
end

function __gsoOrnn:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoOrnn:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoOrnn:_tick()
    
end

class "__gsoPantheon"

function __gsoPantheon:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoPantheon:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoPantheon:_onAttack(target)
end

function __gsoPantheon:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoPantheon:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoPantheon:_tick()
    
end

class "__gsoPoppy"

function __gsoPoppy:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoPoppy:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoPoppy:_onAttack(target)
end

function __gsoPoppy:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoPoppy:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoPoppy:_tick()
    
end

class "__gsoQuinn"

function __gsoQuinn:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoQuinn:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoQuinn:_onAttack(target)
end

function __gsoQuinn:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoQuinn:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoQuinn:_tick()
    
end

class "__gsoRakan"

function __gsoRakan:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoRakan:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoRakan:_onAttack(target)
end

function __gsoRakan:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoRakan:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoRakan:_tick()
    
end

class "__gsoRammus"

function __gsoRammus:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoRammus:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoRammus:_onAttack(target)
end

function __gsoRammus:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoRammus:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoRammus:_tick()
    
end

class "__gsoRekSai"

function __gsoRekSai:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoRekSai:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoRekSai:_onAttack(target)
end

function __gsoRekSai:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoRekSai:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoRekSai:_tick()
    
end

class "__gsoRenekton"

function __gsoRenekton:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoRenekton:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoRenekton:_onAttack(target)
end

function __gsoRenekton:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoRenekton:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoRenekton:_tick()
    
end

class "__gsoRengar"

function __gsoRengar:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoRengar:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoRengar:_onAttack(target)
end

function __gsoRengar:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoRengar:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoRengar:_tick()
    
end

class "__gsoRiven"

function __gsoRiven:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoRiven:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoRiven:_onAttack(target)
end

function __gsoRiven:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoRiven:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoRiven:_tick()
    
end

class "__gsoRumble"

function __gsoRumble:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoRumble:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoRumble:_onAttack(target)
end

function __gsoRumble:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoRumble:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoRumble:_tick()
    
end

class "__gsoRyze"

function __gsoRyze:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoRyze:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoRyze:_onAttack(target)
end

function __gsoRyze:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoRyze:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoRyze:_tick()
    
end

class "__gsoSejuani"

function __gsoSejuani:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoSejuani:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoSejuani:_onAttack(target)
end

function __gsoSejuani:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoSejuani:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoSejuani:_tick()
    
end

class "__gsoShaco"

function __gsoShaco:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoShaco:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoShaco:_onAttack(target)
end

function __gsoShaco:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoShaco:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoShaco:_tick()
    
end

class "__gsoShen"

function __gsoShen:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoShen:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoShen:_onAttack(target)
end

function __gsoShen:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoShen:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoShen:_tick()
    
end

class "__gsoShyvana"

function __gsoShyvana:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoShyvana:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoShyvana:_onAttack(target)
end

function __gsoShyvana:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoShyvana:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoShyvana:_tick()
    
end

class "__gsoSinged"

function __gsoSinged:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoSinged:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoSinged:_onAttack(target)
end

function __gsoSinged:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoSinged:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoSinged:_tick()
    
end

class "__gsoSion"

function __gsoSion:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoSion:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoSion:_onAttack(target)
end

function __gsoSion:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoSion:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoSion:_tick()
    
end

class "__gsoSivir"

function __gsoSivir:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.lastReset = 0
    self.asNoW = myHero.attackSpeed
    gsoAIO.Callbacks:_setOnMove(function(target) return self:_onMove(target) end)
    gsoAIO.Callbacks:_setAASpeed(function() return self:_aaSpeed() end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
end

function __gsoSivir:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    
    local canW = ( isCombo and gsoAIO.Menu.menu.gsosivir.wset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsosivir.wset.harass:Value() )
          canW = canW and isTarget and Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    if canW and gsoAIO.Utils:_castSpell(gT, { q = 250, w = 1000, e = 0, r = 0 }, _W, HK_W) then
        self.lastW = GetTickCount()
        self.canQ = false
        gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.aaReset = true end, endTime = Game.Timer() + 0.05 }
        return true
    end
    
    if not isTarget or afterAttack then
        
        -- USE Q :
        local canQ = ( isCombo and gsoAIO.Menu.menu.gsosivir.qset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsosivir.qset.harass:Value() )
              canQ = canQ and gsoAIO.Utils:_isReady(gT, { q = 1000, w = 0, e = 0, r = 0 }, _Q) and (not isTarget or (isTarget and self.canQ))
        if canQ then
            local qTarget = isTarget and target or gsoAIO.TS:_getTarget(1250, false, false, gsoAIO.OB.enemyHeroes)
            if qTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, qTarget, { delay = 0.25, range = 1250, width = 60, speed = 1350, sType = "line", col = false }, HK_Q) then
                self.lastQ = GetTickCount()
                return true
            end
        end
    end
    return false
end

function __gsoSivir:_aaSpeed()
    local wDiff = GetTickCount() - gsoAIO.WndMsg.lastW - (gsoAIO.Utils.maxPing*1000)
    if wDiff > 3500 and wDiff < 4500 then
        return self.asNoW
    end
    return myHero.attackSpeed
end

function __gsoSivir:_canMove(target)
   if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 250, w = 0, e = 0, r = 0 }) then
        return true
    end
    return false
end

function __gsoSivir:_canAttack(target)
   if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 350, w = 0, e = 0, r = 0 }) then
        return true
    end
    return false
end

class "__gsoSkarner"

function __gsoSkarner:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoSkarner:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoSkarner:_onAttack(target)
end

function __gsoSkarner:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoSkarner:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoSkarner:_tick()
    
end

class "__gsoSona"

function __gsoSona:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoSona:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoSona:_onAttack(target)
end

function __gsoSona:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoSona:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoSona:_tick()
    
end

class "__gsoSoraka"

function __gsoSoraka:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoSoraka:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoSoraka:_onAttack(target)
end

function __gsoSoraka:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoSoraka:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoSoraka:_tick()
    
end

class "__gsoSwain"

function __gsoSwain:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoSwain:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoSwain:_onAttack(target)
end

function __gsoSwain:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoSwain:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoSwain:_tick()
    
end

class "__gsoSyndra"

function __gsoSyndra:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoSyndra:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoSyndra:_onAttack(target)
end

function __gsoSyndra:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoSyndra:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoSyndra:_tick()
    
end

class "__gsoTahmKench"

function __gsoTahmKench:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoTahmKench:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoTahmKench:_onAttack(target)
end

function __gsoTahmKench:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoTahmKench:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoTahmKench:_tick()
    
end

class "__gsoTaliyah"

function __gsoTaliyah:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoTaliyah:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoTaliyah:_onAttack(target)
end

function __gsoTaliyah:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoTaliyah:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoTaliyah:_tick()
    
end

class "__gsoTalon"

function __gsoTalon:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoTalon:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoTalon:_onAttack(target)
end

function __gsoTalon:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoTalon:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoTalon:_tick()
    
end

class "__gsoTaric"

function __gsoTaric:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoTaric:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoTaric:_onAttack(target)
end

function __gsoTaric:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoTaric:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoTaric:_tick()
    
end

class "__gsoTeemo"

function __gsoTeemo:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
end

function __gsoTeemo:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos

    if not isTarget or afterAttack then
        
        -- USE Q :
        local canQ = ( isCombo and gsoAIO.Menu.menu.gsoteemo.qset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsoteemo.qset.harass:Value() )
        if canQ and (not isTarget or (isTarget and self.canQ)) then
            local qTarget = isTarget and target or gsoAIO.TS:_getTarget(680, false, false, gsoAIO.OB.enemyHeroes)
            if qTarget and gsoAIO.Utils:_castSpellTarget(qTarget.pos, _Q, HK_Q, gT, { q = 1000, w = 0, e = 0, r = 750 }) then
                self.canR = false
                self.lastQ = GetTickCount()
            end
        end
        
        -- USE R :
        local canR = ( isCombo and gsoAIO.Menu.menu.gsoteemo.rset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsoteemo.rset.harass:Value() )
              canR = canR and gsoAIO.Utils:_isReady(gT, { q = 350, w = 0, e = 0, r = 1000 }, _R) and (not isTarget or (isTarget and self.canR))
        if canR then
            local rRange = 150 + ( 250 * myHero:GetSpellData(_R).level )
            local onlyImmobile = gsoAIO.Menu.menu.gsoteemo.rset.immo:Value()
            local rTarget = onlyImmobile and gsoAIO.Utils:_getImmobileEnemy(mePos, gsoAIO.OB.enemyHeroes, rRange) or nil
            if not rTarget and not onlyImmobile then
                local isTeemoTarget = isTarget and gsoAIO.Utils:_getDistance(mePos, target.pos) < rRange
                rTarget = isTeemoTarget and target or gsoAIO.TS:_getTarget(rRange, false, false, gsoAIO.OB.enemyHeroes)
            end
            if rTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, rTarget, { delay = 0.25, range = rRange, width = 200, speed = 1000, sType = "circular", col = false }, HK_R) then
                self.lastR = GetTickCount()
                self.canQ = false
                return true
            end
        end
        
        -- USE W :
        local canW = ( isCombo and gsoAIO.Menu.menu.gsoteemo.wset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsoteemo.wset.harass:Value() )
              canW = canW and gsoAIO.Utils:_isReadyFast(gT, { q = 350, w = 1000, e = 0, r = 350 }, _W)
              canW = canW and gsoAIO.Utils:_countEnemyHeroesInRange(mePos, gsoAIO.Menu.menu.gsoteemo.wset.mindist:Value(), false) > 0
        if canW then
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            self.lastW = GetTickCount()
            return true
        end
    end
    return false
end

function __gsoTeemo:_canMove(target)
   if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 250, w = 0, e = 0, r = 250 }) then
        return true
    end
    return false
end

function __gsoTeemo:_canAttack(target)
   if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 350, w = 0, e = 0, r = 350 }) then
        return true
    end
    return false
end

class "__gsoThresh"

function __gsoThresh:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoThresh:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoThresh:_onAttack(target)
end

function __gsoThresh:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoThresh:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoThresh:_tick()
    
end

class "__gsoTristana"

function __gsoTristana:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.asNoQ = 0
    self.tristanaETar = nil
    self.eData = gsoAIO.Dmg.Damages["Tristana"].e
    self.rData = gsoAIO.Dmg.Damages["Tristana"].r
    self.getEData =
        function(stacks)
            return
            {
                dmgAP = self.eData.dmgAP(),
                dmgAD = self.eData.dmgAD(stacks),
                dmgType = self.eData.dmgType
            }
        end
    self.getRData =
        function()
            return
            {
                dmgAP = self.rData.dmgAP(),
                dmgType = self.rData.dmgType
            }
        end
    gsoAIO.Callbacks:_setOnAttack(function(target) self:_onAttack(target) end)
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setAASpeed(function() return self:_aaSpeed() end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoTristana:_onAttack(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local canQ = (gsoAIO.Menu.menu.orb.keys.combo:Value() and gsoAIO.Menu.menu.gsotristana.qset.combo:Value()) or (gsoAIO.Menu.menu.orb.keys.harass:Value() and gsoAIO.Menu.menu.gsotristana.qset.harass:Value())
    if isTarget and canQ and gsoAIO.Utils:_castSpell(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 1000, w = 750, e = 0, r = 0 }, _Q, HK_Q) then
        self.asNoQ = myHero.attackSpeed
        self.lastQ = GetTickCount()
    end
end

function __gsoTristana:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    if isTarget and Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 ) then
        local canQ = (gsoAIO.Menu.menu.orb.keys.combo:Value() and gsoAIO.Menu.menu.gsotristana.qset.combo:Value()) or (gsoAIO.Menu.menu.orb.keys.harass:Value() and gsoAIO.Menu.menu.gsotristana.qset.harass:Value())
        if isTarget and canQ and gsoAIO.Utils:_castSpell(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 1000, w = 750, e = 0, r = 0 }, _Q, HK_Q) then
            self.asNoQ = myHero.attackSpeed
            self.lastQ = GetTickCount()
            return true
        end
    end
    return false
end

function __gsoTristana:_canMove(target)
   if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 500, e = 100, r = 100 }) then
        return true
    end
    return false
end

function __gsoTristana:_canAttack(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    
    if isTarget then
        
        -- USE R :
        local canR = gsoAIO.Menu.menu.gsotristana.rset.ks:Value()
        if canR then
            local meRange = myHero.range + myHero.boundingRadius
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local unit = gsoAIO.OB.enemyHeroes[i]
                local unitPos = unit and unit.pos or nil
                local canRonUnit = unitPos and gsoAIO.Utils:_valid(unit, false) and gsoAIO.Utils:_getDistance(unitPos, mePos) < meRange + unit.boundingRadius
                      canRonUnit = canRonUnit and not gsoAIO.Utils:_nearUnit(unitPos, unit.networkID)
                if canRonUnit then
                    local rDmg = gsoAIO.Dmg.PredHP(unit, self.getRData())
                    local checkEDmg = self.tristanaETar and self.tristanaETar.unit.networkID == unit.networkID
                    local eDmg = checkEDmg and gsoAIO.Dmg.PredHP(unit, self.getEData(self.tristanaETar.stacks)) or 0
                    local unitKillable = eDmg + rDmg > unit.health + (unit.hpRegen * 2)
                    if unitKillable and gsoAIO.Utils:_castSpellTarget(unitPos, _R, HK_R, gT, { q = 0, w = 350, e = 250, r = 1000 }) then
                        self.lastR = GetTickCount()
                        return false
                    end
                end
            end
        end
        
        -- USE E :
        local canE = (isCombo and gsoAIO.Menu.menu.gsotristana.eset.combo:Value()) or (isHarass and gsoAIO.Menu.menu.gsotristana.eset.harass:Value())
              canE = canE and Game.Timer() > gsoAIO.Orb.lAttack + (gsoAIO.Orb.animT * 0.5)
        if canE then
            local targetPos = target.pos
            local targetID = target.networkID
            if not gsoAIO.Utils:_nearUnit(targetPos, targetID) and gsoAIO.Utils:_castSpellTarget(targetPos, _E, HK_E, gT, { q = 0, w = 350, e = 1000, r = 250 }) then
                self.lastE = GetTickCount()
                self.tristanaETar = { id = targetID, stacks = 1, unit = target }
                return false
            end
        end
    end
   if gsoAIO.Utils:_checkTimers(gT, { q = 0, w = 800, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoTristana:_aaSpeed()
    local qDiff = GetTickCount() - gsoAIO.WndMsg.lastQ
    if qDiff > 7000 and qDiff < 8000 then
        return self.asNoQ
    end
    return myHero.attackSpeed
end

function __gsoTristana:_tick()
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero  = gsoAIO.OB.enemyHeroes[i]
        for i = 0, hero.buffCount do
            local buff = hero:GetBuff(i)
            if buff and buff.count > 0 and buff.duration > 1 and buff.name:lower() == "tristanaechargesound" and self.tristanaETar and not self.tristanaETar.endTime then
                self.tristanaETar.endTime = Game.Timer() + buff.duration - gsoAIO.Utils.minPing
            end
        end
    end
    if self.tristanaETar and self.tristanaETar.endTime and Game.Timer() > self.tristanaETar.endTime then
        self.tristanaETar = nil
    end
    local getTick = GetTickCount()
    if getTick - self.lastW > 1000 and Game.CanUseSpell(_W) == 0 then
        local dActions = gsoAIO.WndMsg.delayedSpell
        for k,v in pairs(dActions) do
            if k == 1 then
                if gsoAIO.Orb.dActionsC == 0 then
                    v[1]()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() return 0 end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    self.lastW = GetTickCount()
                    gsoAIO.WndMsg.delayedSpell[k] = nil
                    gsoAIO.Orb.lMove = 0
                    break
                end
                if GetTickCount() - v[2] > 125 then
                    gsoAIO.WndMsg.delayedSpell[k] = nil
                end
                break
            end
        end
    end
end

class "__gsoTrundle"

function __gsoTrundle:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoTrundle:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoTrundle:_onAttack(target)
end

function __gsoTrundle:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoTrundle:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoTrundle:_tick()
    
end

class "__gsoTryndamere"

function __gsoTryndamere:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoTryndamere:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoTryndamere:_onAttack(target)
end

function __gsoTryndamere:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoTryndamere:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoTryndamere:_tick()
    
end

class "__gsoTwistedFate"

function __gsoTwistedFate:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoTwistedFate:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoTwistedFate:_onAttack(target)
end

function __gsoTwistedFate:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoTwistedFate:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoTwistedFate:_tick()
    
end

class "__gsoTwitch"

function __gsoTwitch:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.hasQBuff = false
    self.qBuffTime = 0
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.eBuffs = {}
    self.asNoQ = myHero.attackSpeed
    self.boolRecall = true
    self.QASBuff = false
    self.QASTime = 0
    self.lastASCheck = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setAASpeed(function() return self:_aaSpeed() end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
    gsoAIO.Callbacks:_setDraw(function() self:_draw() end)
end

function __gsoTwitch:_onMove(target)
    
    local stopifQBuff = false
    local num1 = 1350 - ( GetTickCount() - (gsoAIO.Utils.maxPing*1000) - gsoAIO.WndMsg.lastQ )
    if num1 > -50 and num1 < 550 then
        stopifQBuff = true
    end
    
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    
    if not isTarget or afterAttack then
        
        -- USE W :
        local stopWIfR = gsoAIO.Menu.menu.gsotwitch.wset.stopwult:Value() and GetTickCount() < gsoAIO.WndMsg.lastR + 5450
        local stopWIfQ = gsoAIO.Menu.menu.gsotwitch.wset.stopq:Value() and self.hasQBuff
        local canW = not stopWIfR and not stopWIfQ and not stopifQBuff and ((isCombo and gsoAIO.Menu.menu.gsotwitch.wset.combo:Value()) or (isHarass and gsoAIO.Menu.menu.gsotwitch.wset.harass:Value()))
              canW = canW and gsoAIO.Utils:_isReady(gT, { q = 0, w = 1000, e = 350, r = 0 }, _W) and (not isTarget or (isTarget and self.canW))
        if canW then
            local wTarget = isTarget and target or gsoAIO.TS:_getTarget(950, false, false, gsoAIO.OB.enemyHeroes)
            if wTarget and gsoAIO.Utils:_castSpellSkillshot(mePos, wTarget, { delay = 0.25, range = 950, width = 275, speed = 1400, sType = "circular", col = false }, HK_W) then
                self.lastW = GetTickCount()
                self.canE = false
                return true
            end
        end
        
        -- USE E :
        local canE = (isCombo and gsoAIO.Menu.menu.gsotwitch.eset.combo:Value()) or (isHarass and gsoAIO.Menu.menu.gsotwitch.eset.harass:Value())
              canE = canE and gsoAIO.Utils:_isReadyFast(gT, { q = 0, w = 350, e = 1000, r = 0 }, _E) and not stopifQBuff and ( not isTarget or (isTarget and self.canE) )
        if canE then
            local xStacks   = gsoAIO.Menu.menu.gsotwitch.eset.stacks:Value()
            local xEnemies  = gsoAIO.Menu.menu.gsotwitch.eset.enemies:Value()
            local countE    = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_getDistance(myHero.pos, hero.pos) < 1200 and gsoAIO.Utils:_valid(hero, false) then
                    local nID = hero.networkID
                    if self.eBuffs[nID] and self.eBuffs[nID].count >= xStacks then
                        countE = countE + 1
                    end
                end
            end
            if countE >= xEnemies then
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                self.lastE = GetTickCount()
                self.canW = false
                gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
                return
            end
        end
    end
end

function __gsoTwitch:_aaSpeed()
    local num1 = GetTickCount()-self.QASTime-(gsoAIO.Utils.maxPing*1000)
    if num1 > -150 and num1 < 1500 then
        return self.asNoQ
    end
    return myHero.attackSpeed
end

function __gsoTwitch:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 250, e = 250, r = 0 }) then
        return true
    end
    return false
end

function __gsoTwitch:_canAttack(target)
    local getTick = GetTickCount() - (gsoAIO.Utils.maxPing*1000)
    local num1 = 1350-(getTick-gsoAIO.WndMsg.lastQ)
    if num1 > -50 and num1 < (gsoAIO.Orb.windUpT*1000) + 250 then
        return false
    end
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 0, w = 350, e = 350, r = 0 }) then
        return true
    end
    return false
end

function __gsoTwitch:_tick()
    if GetTickCount() - gsoAIO.WndMsg.lastQ < 500 and GetTickCount() > self.lastASCheck + 1000 then
        self.asNoQ = myHero.attackSpeed
        self.lastASCheck = GetTickCount()
    end
    local boolRecall = gsoAIO.Menu.menu.gsotwitch.qset.recallkey:Value()
    if boolRecall == self.boolRecall then
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        Control.KeyDown(string.byte("B"))
        Control.KeyUp(string.byte("B"))
        self.boolRecall = not boolRecall
    end
    local hasQBuff = false
    local QASBuff = false
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        local buffName = buff and buff.name or nil
        if buffName and buff.count > 0 and buff.duration > 0 then
            if buffName == "globalcamouflage" or buffName == "TwitchHideInShadows" then
                hasQBuff = true
                self.qBuffTime = GetTickCount() + (buff.duration*1000)
                break
            end
            if buffName == "twitchhideinshadowsbuff" then
                QASBuff = true
                self.QASTime = GetTickCount() + (buff.duration*1000)
            end
        end
    end
    self.hasQBuff = hasQBuff
    self.QASBuff = QASBuff
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero  = gsoAIO.OB.enemyHeroes[i]
        local nID   = hero.networkID
        if not self.eBuffs[nID] then
            self.eBuffs[nID] = { count = 0, durT = 0 }
        end
        if not hero.dead then
            local hasB = false
            local cB = self.eBuffs[nID].count
            local dB = self.eBuffs[nID].durT
            for i = 0, hero.buffCount do
                local buff = hero:GetBuff(i)
                if buff and buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
                    hasB = true
                    if cB < 6 and buff.duration > dB then
                        self.eBuffs[nID].count = cB + 1
                        self.eBuffs[nID].durT = buff.duration
                    else
                        self.eBuffs[nID].durT = buff.duration
                    end
                    break
                end
            end
            if not hasB then
                self.eBuffs[nID].count = 0
                self.eBuffs[nID].durT = 0
            end
        end
    end
    
    -- E KS :
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local canE = gsoAIO.Utils:_isReadyFast(gT, { q = 0, w = 350, e = 1000, r = 0 }, _E)
    if canE then
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local hero  = gsoAIO.OB.enemyHeroes[i]
            local nID   = hero.networkID
            if self.eBuffs[nID] and self.eBuffs[nID].count > 0 and gsoAIO.Utils:_getDistance(myHero.pos, hero.pos) < 1200 then
                local elvl = myHero:GetSpellData(_E).level
                local basedmg = 5 + ( elvl * 15 )
                local cstacks = self.eBuffs[nID].count
                local perstack = ( 10 + (5*elvl) ) * cstacks
                local bonusAD = myHero.bonusDamage * 0.25 * cstacks
                local bonusAP = myHero.ap * 0.2 * cstacks
                local edmg = basedmg + perstack + bonusAD + bonusAP
                local tarm = hero.armor - myHero.armorPen
                      tarm = tarm > 0 and myHero.armorPenPercent * tarm or tarm
                local DmgDealt = tarm > 0 and edmg * ( 100 / ( 100 + tarm ) ) or edmg * ( 2 - ( 100 / ( 100 - tarm ) ) )
                local HPRegen = hero.hpRegen * 1.5
                if hero.health + hero.shieldAD + HPRegen < DmgDealt and gsoAIO.Utils:_valid(hero, false) then
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    self.lastE = GetTickCount()
                    self.canW = false
                    gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Orb.lMove = 0 end, endTime = Game.Timer() + 0.05 }
                end
            end
        end
    end
end

function __gsoTwitch:_draw()
    local mePos = myHero.pos
    if GetTickCount() < gsoAIO.WndMsg.lastQ + 16000 then
        local mePos2D = mePos:To2D()
        local posX = mePos2D.x - 50
        local posY = mePos2D.y
        local num1 = math.floor(1350+gsoAIO.WndMsg.qLatency-(GetTickCount()-gsoAIO.WndMsg.lastQ))
        local timerEnabled = gsoAIO.Menu.menu.gsodraw.texts1.enabletime:Value()
        local timerColor = gsoAIO.Menu.menu.gsodraw.texts1.colortime:Value()
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
        elseif self.hasQBuff then
            local num2 = math.floor(self.qBuffTime-GetTickCount() + gsoAIO.WndMsg.qLatency)
            if num2 > 1 then
                if gsoAIO.Menu.menu.gsodraw.circle1.invenable:Value() then
                    Draw.Circle(mePos, 500, 1, gsoAIO.Menu.menu.gsodraw.circle1.invcolor:Value())
                end
                if gsoAIO.Menu.menu.gsodraw.circle1.notenable:Value() then
                    Draw.Circle(mePos, 800, 1, gsoAIO.Menu.menu.gsodraw.circle1.notcolor:Value())
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

class "__gsoUdyr"

function __gsoUdyr:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoUdyr:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoUdyr:_onAttack(target)
end

function __gsoUdyr:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoUdyr:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoUdyr:_tick()
    
end

class "__gsoUrgot"

function __gsoUrgot:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoUrgot:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoUrgot:_onAttack(target)
end

function __gsoUrgot:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoUrgot:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoUrgot:_tick()
    
end

class "__gsoVarus"

function __gsoVarus:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoVarus:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoVarus:_onAttack(target)
end

function __gsoVarus:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoVarus:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoVarus:_tick()
    
end

class "__gsoVayne"

function __gsoVayne:__init()
    require "MapPositionGOS"
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.lastReset = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoVayne:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos

    if isTarget and afterAttack then
        
        -- USE E :
        local targetPos = isTarget and target.pos or nil
        local canE = targetPos and ( ( isCombo and gsoAIO.Menu.menu.gsovayne.eset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsovayne.eset.harass:Value() ) )
              canE = canE and not gsoAIO.Utils:_nearUnit(targetPos, target.networkID)
        if canE then
            local ePred = target:GetPrediction(2000,0.15)
            local canEonTarget = ePred and gsoAIO.Utils:_getDistance(ePred, targetPos) < 500 and gsoAIO.Utils:_checkWall(mePos, ePred, 475) and gsoAIO.Utils:_checkWall(mePos, targetPos, 475)
            if canEonTarget and gsoAIO.Utils:_castSpellTarget(targetPos, _E, HK_E, gT, { q = 400, w = 0, e = 1000, r = 0 }) then
                self.canQ = false
                self.lastE = GetTickCount()
                return true
            end
        end
    end
    if not isTarget or afterAttack then
    
        -- USE Q :
        local canQ = ( isCombo and gsoAIO.Menu.menu.gsovayne.qset.combo:Value() ) or ( isHarass and gsoAIO.Menu.menu.gsovayne.qset.harass:Value() )
              canQ = canQ and gsoAIO.Utils:_isReadyFast(gT, { q = 1000, w = 0, e = 750, r = 0 }, _Q)
              canQ = canQ and (self.canQ or ( GetTickCount() > self.lastE + 600 ) )
        if canQ then
            local meRange = myHero.range + myHero.boundingRadius
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local heroPos = hero.pos
                local distToMouse = gsoAIO.Utils:_getDistance(mePos, mousePos)
                local distToHero = gsoAIO.Utils:_getDistance(mePos, heroPos)
                local distToEndPos = gsoAIO.Utils:_getDistance(mePos, hero.pathing.endPos)
                local extRange
                if distToEndPos > distToHero then
                    extRange = distToMouse > 200 and 200 or distToMouse
                else
                    extRange = distToMouse > 300 and 300 or distToMouse
                end
                local extPos = mePos + (mousePos-mePos):Normalized() * extRange
                local distEnemyToExt = gsoAIO.Utils:_getDistance(extPos, heroPos)
                if gsoAIO.Utils:_valid(hero, true) and distEnemyToExt < meRange + hero.boundingRadius then
                    Control.KeyDown(HK_Q)
                    Control.KeyUp(HK_Q)
                    self.lastQ = GetTickCount()
                    self.canE = false
                    return true
                end
            end
        end
    end
    return false
end

function __gsoVayne:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 0, e = 400, r = 0 }) then
        return true
    end
    return false
end

function __gsoVayne:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 0, e = 500, r = 0 }) then
        return true
    end
    return false
end

function __gsoVayne:_tick()
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff and buff.count > 0 and buff.name == "vaynetumblebonus" and Game.Timer() > self.lastReset + 1.2 and buff.duration > 5.8 then
            self.lastReset = Game.Timer()
            gsoAIO.Orb.aaReset = true
        end
    end
end

class "__gsoVeigar"

function __gsoVeigar:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoVeigar:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoVeigar:_onAttack(target)
end

function __gsoVeigar:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoVeigar:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoVeigar:_tick()
    
end

class "__gsoVelkoz"

function __gsoVelkoz:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoVelkoz:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoVelkoz:_onAttack(target)
end

function __gsoVelkoz:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoVelkoz:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoVelkoz:_tick()
    
end

class "__gsoVi"

function __gsoVi:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoVi:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoVi:_onAttack(target)
end

function __gsoVi:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoVi:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoVi:_tick()
    
end

class "__gsoViktor"

function __gsoViktor:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoViktor:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoViktor:_onAttack(target)
end

function __gsoViktor:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoViktor:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoViktor:_tick()
    
end

class "__gsoVladimir"

function __gsoVladimir:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoVladimir:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoVladimir:_onAttack(target)
end

function __gsoVladimir:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoVladimir:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoVladimir:_tick()
    
end

class "__gsoVolibear"

function __gsoVolibear:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoVolibear:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoVolibear:_onAttack(target)
end

function __gsoVolibear:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoVolibear:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoVolibear:_tick()
    
end

class "__gsoWarwick"

function __gsoWarwick:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoWarwick:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoWarwick:_onAttack(target)
end

function __gsoWarwick:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoWarwick:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoWarwick:_tick()
    
end

class "__gsoXayah"

function __gsoXayah:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoXayah:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoXayah:_onAttack(target)
end

function __gsoXayah:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoXayah:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoXayah:_tick()
    
end

class "__gsoXerath"

function __gsoXerath:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoXerath:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoXerath:_onAttack(target)
end

function __gsoXerath:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoXerath:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoXerath:_tick()
    
end

class "__gsoXinZhao"

function __gsoXinZhao:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoXinZhao:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoXinZhao:_onAttack(target)
end

function __gsoXinZhao:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoXinZhao:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoXinZhao:_tick()
    
end

class "__gsoYasuo"

function __gsoYasuo:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoYasuo:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoYasuo:_onAttack(target)
end

function __gsoYasuo:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoYasuo:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoYasuo:_tick()
    
end

class "__gsoYorick"

function __gsoYorick:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoYorick:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoYorick:_onAttack(target)
end

function __gsoYorick:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoYorick:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoYorick:_tick()
    
end

class "__gsoZac"

function __gsoZac:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoZac:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoZac:_onAttack(target)
end

function __gsoZac:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoZac:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoZac:_tick()
    
end

class "__gsoZed"

function __gsoZed:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoZed:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoZed:_onAttack(target)
end

function __gsoZed:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoZed:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoZed:_tick()
    
end

class "__gsoZiggs"

function __gsoZiggs:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoZiggs:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoZiggs:_onAttack(target)
end

function __gsoZiggs:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoZiggs:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoZiggs:_tick()
    
end

class "__gsoZilean"

function __gsoZilean:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoZilean:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoZilean:_onAttack(target)
end

function __gsoZilean:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoZilean:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoZilean:_tick()
    
end

class "__gsoZoe"

function __gsoZoe:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoZoe:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoZoe:_onAttack(target)
end

function __gsoZoe:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoZoe:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoZoe:_tick()
    
end

class "__gsoZyra"

function __gsoZyra:__init()
    self.canQ = true
    self.canW = true
    self.canE = true
    self.canR = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    gsoAIO.Callbacks:_setOnMove(function(target) self:_onMove(target) end)
    gsoAIO.Callbacks:_setOnAttack(function(target) return self:_onAttack(target) end)
    gsoAIO.Callbacks:_setCanMove(function(target) return self:_canMove(target) end)
    gsoAIO.Callbacks:_setCanAttack(function(target) return self:_canAttack(target) end)
    gsoAIO.Callbacks:_setOnTick(function() self:_tick() end)
end

function __gsoZyra:_onMove(target)
    local isTarget = target and target.type == Obj_AI_Hero
    local afterAttack = Game.Timer() < gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.75 )
    local beforeAttack = Game.Timer() > gsoAIO.Orb.lAttack + ( gsoAIO.Orb.animT * 0.5 )
    local gT = gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR)
    local isCombo = gsoAIO.Menu.menu.orb.keys.combo:Value()
    local isHarass = gsoAIO.Menu.menu.orb.keys.harass:Value()
    local mePos = myHero.pos
    if not isTarget or afterAttack then
    
    end
end

function __gsoZyra:_onAttack(target)
end

function __gsoZyra:_canMove(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 200, w = 200, e = 200, r = 200 }) then
        return true
    end
    return false
end

function __gsoZyra:_canAttack(target)
    if gsoAIO.Utils:_checkTimers(gsoAIO.Utils:_getTimers(self.lastQ, self.lastW, self.lastE, self.lastR), { q = 300, w = 300, e = 300, r = 300 }) then
        return true
    end
    return false
end

function __gsoZyra:_tick()
    
end

gsoAIO = {
    Load = nil,
    Menu = nil,
    Callbacks = nil,
    Dmg = nil,
    Items = nil,
    Champ = nil,
    WndMsg = nil,
    Utils = nil,
    OB = nil,
    TS = nil,
    Farm = nil,
    TPred = nil,
    Orb = nil,
    Draw = nil,
    Tick = nil
}

class "__gsoLoad"

function __gsoLoad:__init()
    self.loadTime = GetTickCount()
    self.meAatrox = heroName == "aatrox"
    self.meAhri = heroName == "ahri"
    self.meAkali = heroName == "akali"
    self.meAlistar = heroName == "alistar"
    self.meAmumu = heroName == "amumu"
    self.meAnivia = heroName == "anivia"
    self.meAnnie = heroName == "annie"
    self.meAshe = heroName == "ashe"
    self.meAurelionSol = heroName == "aurelionsol"
    self.meAzir = heroName == "azir"
    self.meBard = heroName == "bard"
    self.meBlitzcrank = heroName == "blitzcrank"
    self.meBrand = heroName == "brand"
    self.meBraum = heroName == "braum"
    self.meCaitlyn = heroName == "caitlyn"
    self.meCamille = heroName == "camille"
    self.meCassiopeia = heroName == "cassiopeia"
    self.meChogath = heroName == "chogath"
    self.meCorki = heroName == "corki"
    self.meDarius = heroName == "darius"
    self.meDiana = heroName == "diana"
    self.meDrMundo = heroName == "drmundo"
    self.meDraven = heroName == "draven"
    self.meEkko = heroName == "ekko"
    self.meElise = heroName == "elise"
    self.meEvelynn = heroName == "evelynn"
    self.meEzreal = heroName == "ezreal"
    self.meFiddlesticks = heroName == "fiddlesticks"
    self.meFiora = heroName == "fiora"
    self.meFizz = heroName == "fizz"
    self.meGalio = heroName == "galio"
    self.meGangplank = heroName == "gangplank"
    self.meGaren = heroName == "garen"
    self.meGnar = heroName == "gnar"
    self.meGragas = heroName == "gragas"
    self.meGraves = heroName == "graves"
    self.meHecarim = heroName == "hecarim"
    self.meHeimerdinger = heroName == "heimerdinger"
    self.meIllaoi = heroName == "illaoi"
    self.meIrelia = heroName == "irelia"
    self.meIvern = heroName == "ivern"
    self.meJanna = heroName == "janna"
    self.meJarvanIV = heroName == "jarvaniv"
    self.meJax = heroName == "jax"
    self.meJayce = heroName == "jayce"
    self.meJhin = heroName == "jhin"
    self.meJinx = heroName == "jinx"
    self.meKalista = heroName == "kalista"
    self.meKarma = heroName == "karma"
    self.meKarthus = heroName == "karthus"
    self.meKassadin = heroName == "kassadin"
    self.meKatarina = heroName == "katarina"
    self.meKayle = heroName == "kayle"
    self.meKayn = heroName == "kayn"
    self.meKennen = heroName == "kennen"
    self.meKhazix = heroName == "khazix"
    self.meKindred = heroName == "kindred"
    self.meKled = heroName == "kled"
    self.meKogMaw = heroName == "kogmaw"
    self.meLeblanc = heroName == "leblanc"
    self.meLeeSin = heroName == "leesin"
    self.meLeona = heroName == "leona"
    self.meLissandra = heroName == "lissandra"
    self.meLucian = heroName == "lucian"
    self.meLulu = heroName == "lulu"
    self.meLux = heroName == "lux"
    self.meMalphite = heroName == "malphite"
    self.meMalzahar = heroName == "malzahar"
    self.meMaokai = heroName == "maokai"
    self.meMasterYi = heroName == "masteryi"
    self.meMissFortune = heroName == "missfortune"
    self.meMonkeyKing = heroName == "monkeyking"
    self.meMordekaiser = heroName == "mordekaiser"
    self.meMorgana = heroName == "morgana"
    self.meNami = heroName == "nami"
    self.meNasus = heroName == "nasus"
    self.meNautilus = heroName == "nautilus"
    self.meNidalee = heroName == "nidalee"
    self.meNocturne = heroName == "nocturne"
    self.meNunu = heroName == "nunu"
    self.meOlaf = heroName == "olaf"
    self.meOrianna = heroName == "orianna"
    self.meOrnn = heroName == "ornn"
    self.mePantheon = heroName == "pantheon"
    self.mePoppy = heroName == "poppy"
    self.meQuinn = heroName == "quinn"
    self.meRakan = heroName == "rakan"
    self.meRammus = heroName == "rammus"
    self.meRekSai = heroName == "reksai"
    self.meRenekton = heroName == "renekton"
    self.meRengar = heroName == "rengar"
    self.meRiven = heroName == "riven"
    self.meRumble = heroName == "rumble"
    self.meRyze = heroName == "ryze"
    self.meSejuani = heroName == "sejuani"
    self.meShaco = heroName == "shaco"
    self.meShen = heroName == "shen"
    self.meShyvana = heroName == "shyvana"
    self.meSinged = heroName == "singed"
    self.meSion = heroName == "sion"
    self.meSivir = heroName == "sivir"
    self.meSkarner = heroName == "skarner"
    self.meSona = heroName == "sona"
    self.meSoraka = heroName == "soraka"
    self.meSwain = heroName == "swain"
    self.meSyndra = heroName == "syndra"
    self.meTahmKench = heroName == "tahmkench"
    self.meTaliyah = heroName == "taliyah"
    self.meTalon = heroName == "talon"
    self.meTaric = heroName == "taric"
    self.meTeemo = heroName == "teemo"
    self.meThresh = heroName == "thresh"
    self.meTristana = heroName == "tristana"
    self.meTrundle = heroName == "trundle"
    self.meTryndamere = heroName == "tryndamere"
    self.meTwistedFate = heroName == "twistedfate"
    self.meTwitch = heroName == "twitch"
    self.meUdyr = heroName == "udyr"
    self.meUrgot = heroName == "urgot"
    self.meVarus = heroName == "varus"
    self.meVayne = heroName == "vayne"
    self.meVeigar = heroName == "veigar"
    self.meVelkoz = heroName == "velkoz"
    self.meVi = heroName == "vi"
    self.meViktor = heroName == "viktor"
    self.meVladimir = heroName == "vladimir"
    self.meVolibear = heroName == "volibear"
    self.meWarwick = heroName == "warwick"
    self.meXayah = heroName == "xayah"
    self.meXerath = heroName == "xerath"
    self.meXinZhao = heroName == "xinzhao"
    self.meYasuo = heroName == "yasuo"
    self.meYorick = heroName == "yorick"
    self.meZac = heroName == "zac"
    self.meZed = heroName == "zed"
    self.meZiggs = heroName == "ziggs"
    self.meZilean = heroName == "zilean"
    self.meZoe = heroName == "zoe"
    self.meZyra = heroName == "zyra"
    Callback.Add('Load', function() self:_load() end)
end

function __gsoLoad:_load()
    gsoAIO.Menu = __gsoMenu()
    gsoAIO.Menu:_menu()
    gsoAIO.Callbacks = __gsoCallbacks()
    gsoAIO.Dmg = __gsoDmg()
    gsoAIO.Items = __gsoItems()
    gsoAIO.WndMsg = __gsoWndMsg()
    gsoAIO.Utils = __gsoUtils()
    gsoAIO.OB = __gsoOB()
    gsoAIO.TS = __gsoTS()
    gsoAIO.Farm = __gsoFarm()
    gsoAIO.TPred = __gsoTPred()
    gsoAIO.Orb = __gsoOrb()
    if self.meAatrox then
        gsoAIO.Champ = __gsoAatrox()
    elseif self.meAhri then
        gsoAIO.Champ = __gsoAhri()
    elseif self.meAkali then
        gsoAIO.Champ = __gsoAkali()
    elseif self.meAlistar then
        gsoAIO.Champ = __gsoAlistar()
    elseif self.meAmumu then
        gsoAIO.Champ = __gsoAmumu()
    elseif self.meAnivia then
        gsoAIO.Champ = __gsoAnivia()
    elseif self.meAnnie then
        gsoAIO.Champ = __gsoAnnie()
    elseif self.meAshe then
        gsoAIO.Champ = __gsoAshe()
    elseif self.meAurelionSol then
        gsoAIO.Champ = __gsoAurelionSol()
    elseif self.meAzir then
        gsoAIO.Champ = __gsoAzir()
    elseif self.meBard then
        gsoAIO.Champ = __gsoBard()
    elseif self.meBlitzcrank then
        gsoAIO.Champ = __gsoBlitzcrank()
    elseif self.meBrand then
        gsoAIO.Champ = __gsoBrand()
    elseif self.meBraum then
        gsoAIO.Champ = __gsoBraum()
    elseif self.meCaitlyn then
        gsoAIO.Champ = __gsoCaitlyn()
    elseif self.meCamille then
        gsoAIO.Champ = __gsoCamille()
    elseif self.meCassiopeia then
        gsoAIO.Champ = __gsoCassiopeia()
    elseif self.meChogath then
        gsoAIO.Champ = __gsoChogath()
    elseif self.meCorki then
        gsoAIO.Champ = __gsoCorki()
    elseif self.meDarius then
        gsoAIO.Champ = __gsoDarius()
    elseif self.meDiana then
        gsoAIO.Champ = __gsoDiana()
    elseif self.meDrMundo then
        gsoAIO.Champ = __gsoDrMundo()
    elseif self.meDraven then
        gsoAIO.Champ = __gsoDraven()
    elseif self.meEkko then
        gsoAIO.Champ = __gsoEkko()
    elseif self.meElise then
        gsoAIO.Champ = __gsoElise()
    elseif self.meEvelynn then
        gsoAIO.Champ = __gsoEvelynn()
    elseif self.meEzreal then
        gsoAIO.Champ = __gsoEzreal()
    elseif self.meFiddlesticks then
        gsoAIO.Champ = __gsoFiddlesticks()
    elseif self.meFiora then
        gsoAIO.Champ = __gsoFiora()
    elseif self.meFizz then
        gsoAIO.Champ = __gsoFizz()
    elseif self.meGalio then
        gsoAIO.Champ = __gsoGalio()
    elseif self.meGangplank then
        gsoAIO.Champ = __gsoGangplank()
    elseif self.meGaren then
        gsoAIO.Champ = __gsoGaren()
    elseif self.meGnar then
        gsoAIO.Champ = __gsoGnar()
    elseif self.meGragas then
        gsoAIO.Champ = __gsoGragas()
    elseif self.meGraves then
        gsoAIO.Champ = __gsoGraves()
    elseif self.meHecarim then
        gsoAIO.Champ = __gsoHecarim()
    elseif self.meHeimerdinger then
        gsoAIO.Champ = __gsoHeimerdinger()
    elseif self.meIllaoi then
        gsoAIO.Champ = __gsoIllaoi()
    elseif self.meIrelia then
        gsoAIO.Champ = __gsoIrelia()
    elseif self.meIvern then
        gsoAIO.Champ = __gsoIvern()
    elseif self.meJanna then
        gsoAIO.Champ = __gsoJanna()
    elseif self.meJarvanIV then
        gsoAIO.Champ = __gsoJarvanIV()
    elseif self.meJax then
        gsoAIO.Champ = __gsoJax()
    elseif self.meJayce then
        gsoAIO.Champ = __gsoJayce()
    elseif self.meJhin then
        gsoAIO.Champ = __gsoJhin()
    elseif self.meJinx then
        gsoAIO.Champ = __gsoJinx()
    elseif self.meKalista then
        gsoAIO.Champ = __gsoKalista()
    elseif self.meKarma then
        gsoAIO.Champ = __gsoKarma()
    elseif self.meKarthus then
        gsoAIO.Champ = __gsoKarthus()
    elseif self.meKassadin then
        gsoAIO.Champ = __gsoKassadin()
    elseif self.meKatarina then
        gsoAIO.Champ = __gsoKatarina()
    elseif self.meKayle then
        gsoAIO.Champ = __gsoKayle()
    elseif self.meKayn then
        gsoAIO.Champ = __gsoKayn()
    elseif self.meKennen then
        gsoAIO.Champ = __gsoKennen()
    elseif self.meKhazix then
        gsoAIO.Champ = __gsoKhazix()
    elseif self.meKindred then
        gsoAIO.Champ = __gsoKindred()
    elseif self.meKled then
        gsoAIO.Champ = __gsoKled()
    elseif self.meKogMaw then
        gsoAIO.Champ = __gsoKogMaw()
    elseif self.meLeblanc then
        gsoAIO.Champ = __gsoLeblanc()
    elseif self.meLeeSin then
        gsoAIO.Champ = __gsoLeeSin()
    elseif self.meLeona then
        gsoAIO.Champ = __gsoLeona()
    elseif self.meLissandra then
        gsoAIO.Champ = __gsoLissandra()
    elseif self.meLucian then
        gsoAIO.Champ = __gsoLucian()
    elseif self.meLulu then
        gsoAIO.Champ = __gsoLulu()
    elseif self.meLux then
        gsoAIO.Champ = __gsoLux()
    elseif self.meMalphite then
        gsoAIO.Champ = __gsoMalphite()
    elseif self.meMalzahar then
        gsoAIO.Champ = __gsoMalzahar()
    elseif self.meMaokai then
        gsoAIO.Champ = __gsoMaokai()
    elseif self.meMasterYi then
        gsoAIO.Champ = __gsoMasterYi()
    elseif self.meMissFortune then
        gsoAIO.Champ = __gsoMissFortune()
    elseif self.meMonkeyKing then
        gsoAIO.Champ = __gsoMonkeyKing()
    elseif self.meMordekaiser then
        gsoAIO.Champ = __gsoMordekaiser()
    elseif self.meMorgana then
        gsoAIO.Champ = __gsoMorgana()
    elseif self.meNami then
        gsoAIO.Champ = __gsoNami()
    elseif self.meNasus then
        gsoAIO.Champ = __gsoNasus()
    elseif self.meNautilus then
        gsoAIO.Champ = __gsoNautilus()
    elseif self.meNidalee then
        gsoAIO.Champ = __gsoNidalee()
    elseif self.meNocturne then
        gsoAIO.Champ = __gsoNocturne()
    elseif self.meNunu then
        gsoAIO.Champ = __gsoNunu()
    elseif self.meOlaf then
        gsoAIO.Champ = __gsoOlaf()
    elseif self.meOrianna then
        gsoAIO.Champ = __gsoOrianna()
    elseif self.meOrnn then
        gsoAIO.Champ = __gsoOrnn()
    elseif self.mePantheon then
        gsoAIO.Champ = __gsoPantheon()
    elseif self.mePoppy then
        gsoAIO.Champ = __gsoPoppy()
    elseif self.meQuinn then
        gsoAIO.Champ = __gsoQuinn()
    elseif self.meRakan then
        gsoAIO.Champ = __gsoRakan()
    elseif self.meRammus then
        gsoAIO.Champ = __gsoRammus()
    elseif self.meRekSai then
        gsoAIO.Champ = __gsoRekSai()
    elseif self.meRenekton then
        gsoAIO.Champ = __gsoRenekton()
    elseif self.meRengar then
        gsoAIO.Champ = __gsoRengar()
    elseif self.meRiven then
        gsoAIO.Champ = __gsoRiven()
    elseif self.meRumble then
        gsoAIO.Champ = __gsoRumble()
    elseif self.meRyze then
        gsoAIO.Champ = __gsoRyze()
    elseif self.meSejuani then
        gsoAIO.Champ = __gsoSejuani()
    elseif self.meShaco then
        gsoAIO.Champ = __gsoShaco()
    elseif self.meShen then
        gsoAIO.Champ = __gsoShen()
    elseif self.meShyvana then
        gsoAIO.Champ = __gsoShyvana()
    elseif self.meSinged then
        gsoAIO.Champ = __gsoSinged()
    elseif self.meSion then
        gsoAIO.Champ = __gsoSion()
    elseif self.meSivir then
        gsoAIO.Champ = __gsoSivir()
    elseif self.meSkarner then
        gsoAIO.Champ = __gsoSkarner()
    elseif self.meSona then
        gsoAIO.Champ = __gsoSona()
    elseif self.meSoraka then
        gsoAIO.Champ = __gsoSoraka()
    elseif self.meSwain then
        gsoAIO.Champ = __gsoSwain()
    elseif self.meSyndra then
        gsoAIO.Champ = __gsoSyndra()
    elseif self.meTahmKench then
        gsoAIO.Champ = __gsoTahmKench()
    elseif self.meTaliyah then
        gsoAIO.Champ = __gsoTaliyah()
    elseif self.meTalon then
        gsoAIO.Champ = __gsoTalon()
    elseif self.meTaric then
        gsoAIO.Champ = __gsoTaric()
    elseif self.meTeemo then
        gsoAIO.Champ = __gsoTeemo()
    elseif self.meThresh then
        gsoAIO.Champ = __gsoThresh()
    elseif self.meTristana then
        gsoAIO.Champ = __gsoTristana()
    elseif self.meTrundle then
        gsoAIO.Champ = __gsoTrundle()
    elseif self.meTryndamere then
        gsoAIO.Champ = __gsoTryndamere()
    elseif self.meTwistedFate then
        gsoAIO.Champ = __gsoTwistedFate()
    elseif self.meTwitch then
        gsoAIO.Champ = __gsoTwitch()
    elseif self.meUdyr then
        gsoAIO.Champ = __gsoUdyr()
    elseif self.meUrgot then
        gsoAIO.Champ = __gsoUrgot()
    elseif self.meVarus then
        gsoAIO.Champ = __gsoVarus()
    elseif self.meVayne then
        gsoAIO.Champ = __gsoVayne()
    elseif self.meVeigar then
        gsoAIO.Champ = __gsoVeigar()
    elseif self.meVelkoz then
        gsoAIO.Champ = __gsoVelkoz()
    elseif self.meVi then
        gsoAIO.Champ = __gsoVi()
    elseif self.meViktor then
        gsoAIO.Champ = __gsoViktor()
    elseif self.meVladimir then
        gsoAIO.Champ = __gsoVladimir()
    elseif self.meVolibear then
        gsoAIO.Champ = __gsoVolibear()
    elseif self.meWarwick then
        gsoAIO.Champ = __gsoWarwick()
    elseif self.meXayah then
        gsoAIO.Champ = __gsoXayah()
    elseif self.meXerath then
        gsoAIO.Champ = __gsoXerath()
    elseif self.meXinZhao then
        gsoAIO.Champ = __gsoXinZhao()
    elseif self.meYasuo then
        gsoAIO.Champ = __gsoYasuo()
    elseif self.meYorick then
        gsoAIO.Champ = __gsoYorick()
    elseif self.meZac then
        gsoAIO.Champ = __gsoZac()
    elseif self.meZed then
        gsoAIO.Champ = __gsoZed()
    elseif self.meZiggs then
        gsoAIO.Champ = __gsoZiggs()
    elseif self.meZilean then
        gsoAIO.Champ = __gsoZilean()
    elseif self.meZoe then
        gsoAIO.Champ = __gsoZoe()
    elseif self.meZyra then
        gsoAIO.Champ = __gsoZyra()
    end
    gsoAIO.Menu:_menuChamp()
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
    gsoAIO.Draw = __gsoDraw()
    gsoAIO.Menu:_menuDraw()
    gsoAIO.Tick = __gsoTick()
    print("gamsteronAIO "..version.." | loaded!")
end
gsoAIO.Load = __gsoLoad()
