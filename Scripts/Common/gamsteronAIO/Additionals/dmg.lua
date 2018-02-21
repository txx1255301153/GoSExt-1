
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