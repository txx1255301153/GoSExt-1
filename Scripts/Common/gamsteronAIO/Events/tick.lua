
class "__gsoTick"

function __gsoTick:__init()
    Callback.Add('Tick', function() self:_tick() end)
end

function __gsoTick:_tick()
    for i = 1, #gsoAIO.Callbacks._tick do
        gsoAIO.Callbacks._tick[i]()
    end
end