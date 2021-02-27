return LoadFont('wendy')..{
    InitCommand=function(self)
        self:text = ""
    end,
    OnCommand=function(self)
        self:sleep(.5)
        self:queuecommand("UpdateHrDisplay")
    end,
    UpdateHrCommand=function(self)
        f = RageFileUtil.CreateRageFile()
        f:Open(THEME:GetCurrentThemeDirectory()..'/hr.out', 1) -- 1 = read
        local hrstring = f:Read()
        f:Close()
        f:destroy()
 
        local heartrate = hrstring:match("%d+")
        self:text = heartrate
        self:sleep(.5)
        self:queuecommand("UpdateHrDisplay")
    end
}
