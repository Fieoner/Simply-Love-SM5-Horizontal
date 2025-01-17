-- if we're in CourseMode, bail now
-- the normal LifeMeter graph (Def.GraphDisplay) will be drawn
if GAMESTATE:IsCourseMode() then return end

-- arguments passed in from Graphs.lua
local args = ...
local player = args.player
local GraphWidth = args.GraphWidth
local GraphHeight = args.GraphHeight
local MissHeight = GraphHeight/4

-- sequential_offsets gathered in ./BGAnimations/ScreenGameplay overlay/JudgmentOffsetTracking.lua
local sequential_offsets = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].sequential_offsets

-- a table to store the AMV's vertices
local verts= {}
-- TotalSeconds is used in scaling the x-coordinates of the AMV's vertices
local FirstSecond = GAMESTATE:GetCurrentSong():GetFirstSecond()
local TotalSeconds = GAMESTATE:GetCurrentSong():GetLastSecond()

-- variables that will be used and re-used in the loop while calculating the AMV's vertices
local Offset, CurrentSecond, TimingWindow, x, y, c, r, g, b

-- ---------------------------------------------
-- if players have disabled W4 or W4+W5, there will be a smaller pool
-- of judgments that could have possibly been earned
local num_judgments_available = SL.Global.ActiveModifiers.WorstTimingWindow
local worst_window = SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..(num_judgments_available > 0 and num_judgments_available or 5)]

-- ---------------------------------------------

for t in ivalues(sequential_offsets) do
	CurrentSecond = t[1]
	Offset = t[2]

	if not string.find(Offset ,"Miss.") then
		CurrentSecond = CurrentSecond - Offset
	else
		CurrentSecond = CurrentSecond - worst_window
	end

	-- pad the right end because the time measured seems to lag a little...
	x = scale(CurrentSecond, FirstSecond, TotalSeconds + 0.05, 0, GraphWidth)

	if string.find(Offset, "Miss.") then
		-- a miss should be a quadrilateral that is the height of the entire graph/No. of buttons and red
		y0 = GraphHeight-string.sub(Offset,-1)*MissHeight
		y1 = y0+MissHeight
		table.insert( verts, {{x, y0, 0}, color("#ff000077")} )
		table.insert( verts, {{x+1, y0, 0}, color("#ff000077")} )
		table.insert( verts, {{x+1, y1, 0}, color("#ff000077")} )
		table.insert( verts, {{x, y1, 0}, color("#ff000077")} )
	else
		-- else, DetermineTimingWindow() is defined in ./Scripts/SL-Helpers.lua
		TimingWindow = DetermineTimingWindow(Offset)
		y = scale(Offset, worst_window, -worst_window, 0, GraphHeight)

		-- get the appropriate color from the global SL table
		c = SL.JudgmentColors[SL.Global.GameMode][TimingWindow]
		-- get the red, green, and blue values from that color
		r = c[1]
		g = c[2]
		b = c[3]

		-- insert four datapoints into the verts tables, effectively generating a single quadrilateral
		-- top left,  top right,  bottom right,  bottom left
		table.insert( verts, {{x,y,0}, {r,g,b,0.666}} )
		table.insert( verts, {{x+1.5,y,0}, {r,g,b,0.666}} )
		table.insert( verts, {{x+1.5,y+1.5,0}, {r,g,b,0.666}} )
		table.insert( verts, {{x,y+1.5,0}, {r,g,b,0.666}} )
	end
end

-- the scatter plot will use an ActorMultiVertex in "Quads" mode
-- this is more efficient than drawing n Def.Quads (one for each judgment)
-- because the entire AMV will be a single Actor rather than n Actors with n unique Draw() calls.
local amv = Def.ActorMultiVertex{
	InitCommand=function(self) self:x(-GraphWidth/2) end,
	OnCommand=function(self)
		self:SetDrawState({Mode="DrawMode_Quads"})
			:SetVertices(verts)
	end,
}

return amv
