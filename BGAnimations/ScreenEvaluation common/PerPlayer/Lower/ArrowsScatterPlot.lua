local args = ...
local player = args.player
local GraphWidth = args.GraphWidth
local GraphHeight = args.GraphHeight
local pn = ToEnumShortString(player)
local ps = GAMESTATE:GetPlayerState(player)
local noteskin = ps:GetCurrentPlayerOptions():NoteSkin()--:lower()

drawarrow = function(arrow, i)
	local status, noteskin_actor = pcall(NOTESKIN.LoadActorForNoteSkin, NOTESKIN, arrow, "Tap Note", noteskin)

	if noteskin_actor then
		return noteskin_actor..{
			Name="NoteSkin_"..noteskin,
			InitCommand=function(self) self:visible(true)
			self:x(pn == "P1" and -GraphWidth/2-10 or GraphWidth/2+10)
				:y(_screen.cy - 200 - GraphHeight/2 + 16*i)
				:zoom(.25)
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
