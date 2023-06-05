local args = ...
local player = args.player
local GraphWidth = args.GraphWidth
local GraphHeight = args.GraphHeight
local pn = ToEnumShortString(player)
local ps = GAMESTATE:GetPlayerState(player)
local noteskin = ps:GetCurrentPlayerOptions():NoteSkin()--:lower()

local x_offset = 11 -- horizontal spacing away from the scatterplot
local y_offset = _screen.cy - 201
local arrow_zoom = .24
local arrow_spacing = 16

local drawarrow = function(arrow, i)
	local status, noteskin_actor = pcall(NOTESKIN.LoadActorForNoteSkin, NOTESKIN, arrow, "Tap Note", noteskin)

	if noteskin_actor then
		return noteskin_actor..{
			Name="NoteSkin_"..noteskin,
			InitCommand=function(self) self:visible(true)
			self:x(pn == "P1" and -GraphWidth/2-x_offset or GraphWidth/2+x_offset)
				:y(y_offset - GraphHeight/2 + arrow_spacing*i)
				:zoom(arrow_zoom)
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
