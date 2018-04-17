
class "__gsoTest"

        function __gsoTest:__init()
                self.menu = MenuElement({name = "Gamsteron Test", id = "gamsteron", type = MENU })
                require "gsoLibs\\gsoSDK"
                __gsoSDK(self.menu)
        end

__gsoTest()
