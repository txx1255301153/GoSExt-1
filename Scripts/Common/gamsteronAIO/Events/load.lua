
local version = "0.644"
local heroName = myHero.charName:lower()
local supportedChampions = {
    ["draven"] = true,
    ["ezreal"] = true,
    ["ashe"] = true,
    ["twitch"] = true,
    ["kogmaw"] = true,
    ["vayne"] = true,
    ["teemo"] = true,
    ["sivir"] = true,
    ["tristana"] = true,
    ["jinx"] = true
}
if not supportedChampions[heroName] then
    print("gamsteronAIO "..self.version.." | hero not supported !")
    return
end

require 'gamsteronAIO\\Additionals\\dmg'
require 'gamsteronAIO\\Additionals\\items'
require 'gamsteronAIO\\Additionals\\menu'
require 'gamsteronAIO\\Callbacks\\callbacks'
require 'gamsteronAIO\\Orbwalker\\farm'
require 'gamsteronAIO\\Orbwalker\\orb'
require 'gamsteronAIO\\Events\\onwndmsg'
require 'gamsteronAIO\\Events\\draw'
require 'gamsteronAIO\\Events\\tick'
require 'gamsteronAIO\\Prediction\\tpred'
require 'gamsteronAIO\\Target Selector\\ob'
require 'gamsteronAIO\\Target Selector\\ts'
require 'gamsteronAIO\\Utilities\\utils'

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
    self.meTristana = heroName == "tristana"
    self.meSivir = heroName == "sivir"
    self.meVayne = heroName == "vayne"
    self.meKog = heroName == "kogmaw"
    self.meTwitch = heroName == "twitch"
    self.meAshe = heroName == "ashe"
    self.meEzreal = heroName == "ezreal"
    self.meDraven = heroName == "draven"
    self.meTeemo = heroName == "teemo"
    self.meJinx = heroName == "jinx"
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
    if self.meTristana then
        require 'gamsteronAIO\\Champions\\tristana'
        gsoAIO.Champ = __gsoTristana()
    elseif self.meSivir then
        require 'gamsteronAIO\\Champions\\sivir'
        gsoAIO.Champ = __gsoSivir()
    elseif self.meVayne then
        require 'gamsteronAIO\\Champions\\vayne'
        gsoAIO.Champ = __gsoVayne()
    elseif self.meKog then
        require 'gamsteronAIO\\Champions\\kog'
        gsoAIO.Champ = __gsoKogMaw()
    elseif self.meTwitch then
        require 'gamsteronAIO\\Champions\\twitch'
        gsoAIO.Champ = __gsoTwitch()
    elseif self.meAshe then
        require 'gamsteronAIO\\Champions\\ashe'
        gsoAIO.Champ = __gsoAshe()
    elseif self.meEzreal then
        require 'gamsteronAIO\\Champions\\ezreal'
        gsoAIO.Champ = __gsoEzreal()
    elseif self.meDraven then
        require 'gamsteronAIO\\Champions\\draven'
        gsoAIO.Champ = __gsoDraven()
    elseif self.meTeemo then
        require 'gamsteronAIO\\Champions\\teemo'
        gsoAIO.Champ = __gsoTeemo()
    elseif self.meJinx then
        require 'gamsteronAIO\\Champions\\jinx'
        gsoAIO.Champ = __gsoJinx()
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