
class "__gsoWndMsg"

function __gsoWndMsg:__init()
    self.lastQ    = 0
    self.lastW    = 0
    self.lastE    = 0
    self.lastR    = 0
    self.qLatency = 0
    self.wLatency = 0
    self.eLatency = 0
    self.rLatency = 0
    self.delayedSpell = {}
    Callback.Add('WndMsg', function(msg, wParam) self:_onWndMsg(msg, wParam) end)
end

function __gsoWndMsg:_onWndMsg(msg, wParam)
    local getTick = GetTickCount()
    local isKey = gsoAIO.Menu.menu.orb.keys.combo:Value() or gsoAIO.Menu.menu.orb.keys.harass:Value() or gsoAIO.Menu.menu.orb.keys.laneClear:Value() or gsoAIO.Menu.menu.orb.keys.lastHit:Value()
    if Game.CanUseSpell(_Q) == 0 and wParam == HK_Q and getTick > self.lastQ + 1000 then
        self.lastQ = getTick
        self.qLatency = Game.Latency()*1.1
        if isKey and not self.delayedSpell[0] then
            self.delayedSpell[0] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_W) == 0 and wParam == HK_W and getTick > self.lastW + 1000 then
        self.lastW = getTick
        self.wLatency = Game.Latency()*1.1
        if isKey and not self.delayedSpell[1] then
            self.delayedSpell[1] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_E) == 0 and wParam == HK_E and getTick > self.lastE + 1000 then
        self.lastE = getTick
        self.eLatency = Game.Latency()*1.1
        if isKey and not self.delayedSpell[2] then
            self.delayedSpell[2] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_R) == 0 and wParam == HK_R and getTick > self.lastR + 1000 then
        self.lastR = getTick
        self.rLatency = Game.Latency()*1.1
        if isKey and not self.delayedSpell[3] then
            self.delayedSpell[3] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    end
    for i = 1, #gsoAIO.Callbacks._wndMsg do
        gsoAIO.Callbacks._wndMsg[i]()
    end
end