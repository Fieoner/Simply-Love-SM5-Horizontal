if SL.Global.GameMode == "StomperZ" then return end

local pn = ...
local storage = SL[ToEnumShortString(pn)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
local passed = storage.notes_passed
local total = 0
local healthState = "HealthState_Alive"
local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(pn)) or GAMESTATE:GetCurrentSteps(pn)
if steps then
	rv = steps:GetRadarValues(pn)
	local val = rv:GetValue( 'RadarCategory_TapsAndHolds' )
	if val > 0 then
		total = val
	end
end
local perc = string.format("%.2f", (passed / total) * 100)
if perc == "100.00" then return end

local t = Def.ActorFrame{
	OnCommand=function(self)
		self:y( 45 )
		self:x( (pn == PLAYER_1 and -215) or 60 )
	end,
	LoadFont("_wendy white")..{
		Text="PERCENTAGE PASSED: "..perc,
		Name="PassPercentage",
		InitCommand=cmd(vertalign, middle; horizalign, center; zoom,0.2 ),
		OnCommand=cmd(x, 70)
	}
}

return t
