if not SL.Global.ActiveModifiers.HeartRateRate then return end

return Def.Actor{
    OnCommand=function(self)
        self:sleep(.5)
        self:queuecommand("UpdateHr")
    end,
    UpdateHrCommand=function(self)
        f = RageFileUtil.CreateRageFile()
        f:Open(THEME:GetCurrentThemeDirectory()..'/hr.out', 1) -- 1 = read
        local hrstring = f:Read()
        f:Close()
        f:destroy()

        local heartrate = tonumber(hrstring:match("%d+"))
        bpm = GAMESTATE:GetSongPosition():GetCurBPS() * 60
        GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate( heartrate / bpm )
        self:sleep(.5)
        self:queuecommand("UpdateHr")
    end
}
