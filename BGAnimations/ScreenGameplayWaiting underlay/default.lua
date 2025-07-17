local af = Def.ActorFrame {
    InitCommand=function(self)
        local room = SYNCMAN:SongID(GAMESTATE:GetCurrentSong())
        SYNCMAN:Join(room)
    end,
    OnCommand=function(self)
        -- SYNCMAN:Send({
        --     action = "players"
        -- })
    end,
    SyncStartStartMessageCommand=function(self)
        local top_screen = SCREENMAN:GetTopScreen()
        top_screen:SetNextScreenName(Branch.GameplayScreen()):StartTransitioningScreen("SM_GoToNextScreen")
    end
}

af[#af+1] = LoadActor("./../ScreenEvaluation common/Shared/TitleAndBanner.lua")
af[#af+1] = LoadActor("./../ScreenEvaluation common/Shared/SongFeatures.lua")

af[#af+1] = LoadActor("./PlayerList.lua")
af[#af+1] = LoadActor("./ReadyBanner.lua")

return af