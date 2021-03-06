--[[

.______     ______        _______.     _______.   ____    ____   _______.   .______    __          ___   ____    ____  _______ .______          _______.
|   _  \   /  __  \      /       |    /       |   \   \  /   /  /       |   |   _  \  |  |        /   \  \   \  /   / |   ____||   _  \        /       |
|  |_)  | |  |  |  |    |   (----`   |   (----`    \   \/   /  |   (----`   |  |_)  | |  |       /  ^  \  \   \/   /  |  |__   |  |_)  |      |   (----`
|   _  <  |  |  |  |     \   \        \   \         \      /    \   \       |   ___/  |  |      /  /_\  \  \_    _/   |   __|  |      /        \   \
|  |_)  | |  `--'  | .----)   |   .----)   |         \    / .----)   |      |  |      |  `----./  _____  \   |  |     |  |____ |  |\  \----.----)   |
|______/   \______/  |_______/    |_______/           \__/  |_______/       | _|      |_______/__/     \__\  |__|     |_______|| _| `._____|_______/

.______   ____    ____     _______    ___       __          ___      ___   ___  __  .______
|   _  \  \   \  /   /    |   ____|  /   \     |  |        /   \     \  \ /  / |  | |   _  \
|  |_)  |  \   \/   /     |  |__    /  ^  \    |  |       /  ^  \     \  V  /  |  | |  |_)  |
|   _  <    \_    _/      |   __|  /  /_\  \   |  |      /  /_\  \     >   <   |  | |      /
|  |_)  |     |  |        |  |    /  _____  \  |  `----./  _____  \   /  .  \  |  | |  |\  \----.
|______/      |__|        |__|   /__/     \__\ |_______/__/     \__\ /__/ \__\ |__| | _| `._____|

--]]

LANGUAGES_LIST = {}

Events.Subscribe("BVP_Client_GetLanguages", function (langs)
    LANGUAGES_LIST = langs
end)

Events.Subscribe("BVP_Client_GlowEveryone", function ()
    local playerNames = Player.GetAll()
    local clientPlyt = Client.GetLocalPlayer()
    local clientChara = clientPlyt:GetControlledCharacter()
    if clientChara == nil then return end
    local highlight_color = Color(1, 0, 0, 0.5)
    local highlight_color_invisible = Color(1, 0, 0, 2.5)
    local teamGlow = 1
    if clientChara:GetTeam() == 1 then
        highlight_color = Color(10, 2.5, 0, 2.5)
        teamGlow = 2
    end
    --Client.SetHighlightColor(highlight_color_invisible, 0)
    --Client.SetHighlightColor(highlight_color_invisible, 1)
    Client.SetHighlightColor(highlight_color, 2)
    --Client.SetHighlightColor(highlight_color_invisible, 2)
    for i, v in pairs(playerNames) do
        local chara = v:GetControlledCharacter()
        if chara ~= nil then
            if chara:GetTeam() == teamGlow then
                chara:SetHighlightEnabled(true, 2)
            end
        end
    end
end)

Events.Subscribe("BVP_Client_StartGame", function(bossData, BossPlayer)
    Events.Call("BVP_Client_SendPrivateChatMessage", "CHAT_RoundBegin", nil)
    local playername = BossPlayer:GetAccountName()
    local LocalPlayer = Client.GetLocalPlayer()
    if LocalPlayer:GetControlledCharacter():GetTeam() == 1 then
        Client.SetDiscordActivity("Playing as the BOSS", "Boss VS Players Gamemode", "screenshot_173", "by Falaxir")
        LocalPlayer:SetValue("BVP_BossPosses", bossData)
        LocalPlayer:SetValue("BVP_BossPoints", 0)
        Package.SetPersistentData("BVP_BossPoints", 0)
    else
        Client.SetDiscordActivity("Playing as a Player", "Boss VS Players Gamemode", "screenshot_173", "by Falaxir")
        local points = LocalPlayer:GetValue("BVP_BossPoints")
        LocalPlayer:SetValue("BVP_BossPoints", points + 1)
        Package.SetPersistentData("BVP_BossPoints", points + 1)
    end
    local ChoosenLanguage = Client.GetLocalPlayer():GetValue("BVP_Language")
    if ChoosenLanguage == nil then
        Events.CallRemote("BVP_GetLanguageOnNill")
        return
    end
    Client.SetValue("BVP_RageReady", 0)
    local text = ChoosenLanguage["HUD_Ability_Rage_Loading"]
    text = string.gsub(text, "%__PERCENTAGE__", "0")
    MainHUD:CallEvent("BVP_HUD_Boss_Rage", text)
    Client.SetValue("BVP_JumpReady", 0)
    Client.SetValue("BVP_SpecialReady", 0)
    Events.Call("BVP_Client_HUD_Advert_important", "HUD_Top_BossAnnounce", {__BOSSNAME__ = bossData.BossName}, nil)
    Events.Call("BVP_Client_HUD_Advert_top_one", "HUD_Top_BossName", {__PLAYERNAME__ = playername, __PLAYERLIFE__ = BossPlayer:GetControlledCharacter():GetMaxHealth()})
    Timer.SetTimeout(function(bossInfo)
        MainHUD:CallEvent("BVP_HUD_Advert_important", nil)
        MainHUD:CallEvent("BVP_HUD_Advert_top_one", nil)
        if bossInfo ~= nil then
            Events.Call("BVP_Client_PlayBGM", bossInfo.BossSoundMusic[math.random(#bossInfo.BossSoundMusic)])
        end
        return false
    end, 6000, bossData)
    Events.Call("BVP_Client_Rage_Calculation", bossData)
    Events.Call("BVP_Client_Jump_Calculation", bossData)
    Events.Call("BVP_Client_Special_Calculation", bossData)
    playEffect(bossData.BossSoundBegin[math.random(#bossData.BossSoundBegin)])
end)

Events.Subscribe("BVP_Client_ChangeGameState", function (newState)
    Client.SetValue("BVP_GameState", newState)
end)

Events.Subscribe("BVP_Client_SendPrivateChatMessage", function (type, tableCustomParameters)
    local ChoosenLanguage = Client.GetLocalPlayer():GetValue("BVP_Language")
    if ChoosenLanguage == nil then
        Events.CallRemote("BVP_GetLanguageOnNill")
        return
    end
    local text = ChoosenLanguage[type]
    if tableCustomParameters ~= nil then
        for key,value in pairs(tableCustomParameters)
        do
            text = string.gsub(text, "%" .. key, value)
        end
    end
    Client.SendChatMessage(text)
end)

Events.Subscribe("BVP_Client_HUD_BossInfo", function (bossData, timer)
    local ResultData = {}
    local ChoosenLanguage = Client.GetLocalPlayer():GetValue("BVP_Language")
    table.insert(ResultData, bossData.BossName)
    table.insert(ResultData, bossData.BossDescription)
    table.insert(ResultData, bossData.BossAbilities["JumpFunction"])
    table.insert(ResultData, ChoosenLanguage[bossData.BossAbilities["JumpFunction"]])
    table.insert(ResultData, bossData.BossAbilities["RageFunction"])
    table.insert(ResultData, ChoosenLanguage[bossData.BossAbilities["RageFunction"]])
    table.insert(ResultData, bossData.BossAbilities["SpecialFunction"])
    table.insert(ResultData, ChoosenLanguage[bossData.BossAbilities["SpecialFunction"]])
    local ResultString = JSON.stringify(ResultData)
    MainHUD:CallEvent("BVP_HUD_BossInfo", ResultString)
    if timer == nil then return end
    Timer.SetTimeout(function()
        MainHUD:CallEvent("BVP_HUD_BossInfo", nil)
        return false
    end, (timer + 1) * 1000)
end)

Events.Subscribe("BVP_Client_HUD_Advert_important", function (type, tableCustomParameters, timer)
    local ChoosenLanguage = Client.GetLocalPlayer():GetValue("BVP_Language")
    if ChoosenLanguage == nil then
        Events.CallRemote("BVP_GetLanguageOnNill")
        return
    end
    local text = ChoosenLanguage[type]
    if tableCustomParameters ~= nil then
        for key,value in pairs(tableCustomParameters)
        do
            text = string.gsub(text, "%" .. key, value)
        end
    end
    MainHUD:CallEvent("BVP_HUD_Advert_important", text)
    if timer == nil then return end
    Timer.SetTimeout(function()
        MainHUD:CallEvent("BVP_HUD_Advert_important", nil)
        return false
    end, timer * 1000)
end)

Events.Subscribe("BVP_Client_HUD_Image", function (image, timer)
    if image == nil then
        MainHUD:CallEvent("BVP_HUD_Image_Background", nil)
        return
    end
    if timer == 0 then return end
    MainHUD:CallEvent("BVP_HUD_Image_Background", image)
    Timer.SetTimeout(function()
        MainHUD:CallEvent("BVP_HUD_Image_Background", nil)
        return false
    end, timer * 1000)
end)

Events.Subscribe("BVP_Client_HUD_Timer", function (timer_tick)
    MainHUD:CallEvent("BVP_HUD_Timer", timer_tick)
end)

Events.Subscribe("BVP_Client_HUD_Boss_Health", function (character)
    if character == nil then return end
    local health = character:GetHealth()
    local health_max = character:GetMaxHealth()
    local result = (health / health_max) * 100
    MainHUD:CallEvent("BVP_HUD_Boss_Health", result .. " % HP boss")
end)

Events.Subscribe("BVP_Client_HUD_Players", function (type, tableCustomParameters)
    local ChoosenLanguage = Client.GetLocalPlayer():GetValue("BVP_Language")
    if ChoosenLanguage == nil then
        MainHUD:CallEvent("BVP_HUD_Players_Remaining", "ERROR: Please reconnect")
    end
    local text = ChoosenLanguage[type]
    if tableCustomParameters ~= nil then
        for key,value in pairs(tableCustomParameters)
        do
            text = string.gsub(text, "%" .. key, value)
        end
    end
    MainHUD:CallEvent("BVP_HUD_Players_Remaining", text)
end)

Events.Subscribe("BVP_Client_HUD_Advert_top_one", function (type, tableCustomParameters, timer)
    local ChoosenLanguage = Client.GetLocalPlayer():GetValue("BVP_Language")
    if ChoosenLanguage == nil then
        Events.CallRemote("BVP_GetLanguageOnNill")
        return
    end
    local text = ChoosenLanguage[type]
    if tableCustomParameters ~= nil then
        for key,value in pairs(tableCustomParameters)
        do
            text = string.gsub(text, "%" .. key, value)
        end
    end
    MainHUD:CallEvent("BVP_HUD_Advert_top_one", text)
    if timer == nil then return end
    Timer.SetTimeout(function()
        MainHUD:CallEvent("BVP_HUD_Advert_top_one")
        return false
    end, timer)
end)

-- winner : 0 = nul ; 1 = boss ; 2 = players
Events.Subscribe("BVP_Client_EndGame", function(winner)
    Client.SetDiscordActivity("Waiting Round Start", "Boss VS Players Gamemode", "screenshot_173", "by Falaxir")
    MainHUD:CallEvent("BVP_HUD_Boss_Container_Display", 0)
    Events.Call("BVP_Client_HUD_Advert_important", "HUD_Conditions_End", nil, nil)
    if winner == 1 then
        Events.Call("BVP_Client_HUD_Advert_top_one", "HUD_Conditions_BossWin", nil, nil)
        return
    end
    if winner == 2 then
        Events.Call("BVP_Client_HUD_Advert_top_one", "HUD_Conditions_PlayersWin", nil, nil)
        return
    end
    Events.Call("BVP_Client_HUD_Advert_top_one", "HUD_Conditions_NobodyWin", nil, nil)
end)