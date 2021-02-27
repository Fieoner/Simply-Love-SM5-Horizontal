local player = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentDP)

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local TapNoteScores = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	Weights = { 3, 2, 1, 0, 0, 0 },
}
local points = 0
local bofaPoints = function()
	for i=1,#TapNoteScores.Types do
		local window = TapNoteScores.Types[i]
		local number = pss:GetTapNoteScores( "TapNoteScore_"..window )
		points = points + number * TapNoteScores.Weights[i]
	end
end

-- Format the Percentage string, removing the % symbol
percent = percent:gsub("%%", "")

return Def.ActorFrame{
	Name="PercentageContainer"..ToEnumShortString(player),
	OnCommand=function(self)
		self:y( _screen.cy-26 )
	end,

	-- dark background quad behind player percent score
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#101519")):zoomto(158.5, 60)
			self:horizalign(player==PLAYER_1 and left or right)
			self:x(150 * (player == PLAYER_1 and -1 or 1))
		end
	},

	LoadFont("_wendy white")..{
		Name="Percent",
		Text=percent,
		InitCommand=function(self)
			self:horizalign(right):zoom(0.585)
			self:x( (player == PLAYER_1 and 1.5 or 141))
		end
	},
	
	 -- bofa score
	 LoadFont("_wendy white")..{
		 Name="ECFA2021",
		 Text="",
		 InitCommand = function(self)
			 self:vertalign(middle):horizalign(right):zoom(0.38):x(40)
			 score = bofaPoints()
			 self:settext("asdf"..score)
		 end
	 },

}
