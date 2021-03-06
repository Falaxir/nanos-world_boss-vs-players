function Ability_Speed(player)
    local character = player:GetControlledCharacter()
    if character ~= nil then
        local old_speed = character:GetSpeedMultiplier()
        character:SetSpeedMultiplier(old_speed * 1.5)
        Timer.SetTimeout(function(chara, ospeed)
            if (chara:IsValid()) then
                chara:SetSpeedMultiplier(ospeed)
            end
            return false
        end, 6000, character, old_speed)
    end
end

Package.Export("Ability_Speed", Ability_Speed)