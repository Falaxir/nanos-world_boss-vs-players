function BossModel_TerryCrews(player, BossData)
    -- Minimum Required
    local BossCharacter = BossCreateStartRound(BossData, "boss-vs-players-assets::TerryCrews")
    player:Possess(BossCharacter)
    -- End minimum required
end

Package.Export("BossModel_TerryCrews", BossModel_TerryCrews)