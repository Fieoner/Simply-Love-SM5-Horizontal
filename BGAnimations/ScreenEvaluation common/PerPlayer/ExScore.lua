local player = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local TapNoteScores = {
	Names = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss', 'HitMine', 'None' },
	Scores = { 3, 2, 1, 0, 0, -1, -1, 0 }
}
local HoldNoteScores = {
	Names = { 'LetGo', 'Held', 'MissedHold', 'None' },
	Scores = { -1, 0, -1, 0 }
}
local dp = 0
local maxdp = 0

for i=1,#TapNoteScores.Names do
	local taps = stats:GetTapNoteScores("TapNoteScore_"..TapNoteScores.Names[i])
	local score = TapNoteScores.Scores[i]
	dp = dp + taps*score
end
for i=1,#HoldNoteScores.Names do
	local holds = stats:GetHoldNoteScores("HoldNoteScore_"..HoldNoteScores.Names[i])
	local score = HoldNoteScores.Scores[i]
	dp = dp + holds*score
end
-- TapNoteScore_W1 has the highest score or this doesn't work
-- Don't do stupid stuff or I'll have to write good code
totaltaps = stats:GetRadarPossible():GetValue("RadarCategory_TapsAndHolds")
maxdp = totaltaps * TapNoteScores.Scores[1]

local PercentFTFA = dp / maxdp
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentFTFA)
-- Format the Percentage string, removing the % symbol
percent = percent:gsub("%%", "")

local t = Def.ActorFrame{
	OnCommand=function(self)
		self:y( 65 )
		self:x( (player == PLAYER_1 and -190) or 60 )
	end,
	LoadFont("_wendy white")..{
		Text="FTFA SCORE: "..percent,
		Name="ExScore",
		InitCommand=cmd(vertalign, middle; horizalign, center; zoom,0.2 ),
		OnCommand=cmd(x, 70)
	}
}

return t

