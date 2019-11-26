local args = ...
local player = args.player
local GraphWidth = args.GraphWidth
local GraphHeight = args.GraphHeight
local pn = ToEnumShortString(player)
local ps = GAMESTATE:GetPlayerState(player)
local noteskin = ps:GetCurrentPlayerOptions():NoteSkin()--:lower()
local game_name = GAMESTATE:GetCurrentGame():GetName()
-- This doesn't handle every game type that SM5 supports, but could, if dan knew more about NoteSkins...
local column = {
        dance = "Up",
        pump = "UpRight",
        techno = "Up",
        kb7 = "Key1"
}
drawarrow = function(arrow, i)
	local status, noteskin_actor = pcall(NOTESKIN.LoadActorForNoteSkin, NOTESKIN, arrow, "Tap Note", noteskin)

	if noteskin_actor then
		return noteskin_actor..{
			Name="NoteSkin_"..noteskin,
			InitCommand=function(self) self:visible(true)
			self:x(pn == "P1" and -GraphWidth/2-10 or GraphWidth/2+10)
				:y(_screen.cy - 206 - GraphHeight/2 + 13*i)
				:zoom(.22)
		end
		}
	else
		SM("There are Lua errors in your " .. noteskin .. " NoteSkin.\nYou should fix them, or delete the NoteSkin.")

		return Def.Actor{
			Name="NoteSkin_"..noteskin,
			InitCommand=function(self) self:visible(true) end
		}
	end
end

local t = Def.ActorFrame{}
t[#t+1] = drawarrow("Right", 0)
t[#t+1] = drawarrow("Up", 1)
t[#t+1] = drawarrow("Down", 2)
t[#t+1] = drawarrow("Left", 3)
return t
