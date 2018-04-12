
class "__gsoTest"

        function __gsoTest:__init()
                require "gsoLibs\\gsoSDK"
                self.menu = MenuElement({name = "Gamsteron Test", id = "gamsteron", type = MENU })
                self.SDK = __gsoSDK(self.menu)
                Callback.Add('Tick', function() self:Tick() end)
                Callback.Add('WndMsg', function(msg, wParam) self:WndMsg(msg, wParam) end)
                Callback.Add('Draw', function() self:Draw() end)
        end
        
        function __gsoTest:Tick()
                self.SDK:Tick()
        end
        
        function __gsoTest:WndMsg(msg, wParam)
                self.SDK:WndMsg(msg, wParam)
        end
        
        function __gsoTest:Draw()
                self.SDK:Draw()
        end

__gsoTest()
