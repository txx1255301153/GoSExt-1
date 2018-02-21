
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
        local t = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6 }
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
                local t3 = { HK_ITEM_1, HK_ITEM_2, HK_ITEM_3, HK_ITEM_4, HK_ITEM_5, HK_ITEM_6 }
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