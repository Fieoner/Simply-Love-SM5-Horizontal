local Font = "Common Normal"

local MAX_PLAYER_COUNT = 10

local yPos = SCREEN_HEIGHT*0.85
local boxHeight = 20 * MAX_PLAYER_COUNT

local af = Def.ActorFrame {
    InitCommand=function(self)
        
        self:xy(SCREEN_CENTER_X, yPos)
        self:valign(0)
        
    end
}

for i = 1, MAX_PLAYER_COUNT do
    local playerIndex = MAX_PLAYER_COUNT - i + 1

    af[#af+1] = Def.Quad {
        InitCommand=function(self)
            self:zoomto(200, 20)
            self:y((i - 1) * 20 - boxHeight)
            self:halign(0.5)
            if i % 2 == 0 then
                self:diffuse(Color.White):diffusealpha(0.4)
            else
                self:diffuse(Color.White):diffusealpha(0.45)
            end
        end
    }

    af[#af+1] = Def.BitmapText {
        Font=Font,
        Text="",
        InitCommand=function(self)
            self:valign(0.5)
            self:y(i * 20 - boxHeight * 2)
            self:x(-10)
            self:halign(1)
            self:diffuse(Color.White)
            self:visible(false)
        end,
        OnCommand=function(self)
            self:queuecommand("SyncStartPlayersChangedMessageCommand")
        end,
        SyncStartPlayersChangedMessageCommand=function(self)
            local players = SYNCMAN:GetCurrentPlayers()

            if #players >= playerIndex then
                local player = players[playerIndex]
                self:settext(" - " .. player)
                self:visible(true)
            else
                self:settext("")
                self:visible(false)
            end
        end
    }
end

return af