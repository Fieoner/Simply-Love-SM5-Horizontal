-- don't bother for Casual gamemode
if SL.Global.GameMode == "Casual" then return end

local player = ...
local buttons = {
        dance = { "Left", "Down", "Up", "Right" },
        pump = { "DownLeft", "UpLeft", "Center", "UpRight", "DownRight" }
}

local sequential_offsets = {}

return Def.Actor{
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end

		if params.TapNoteOffset then
			-- if the judgment was a Miss, store the string "Miss" as offset instead of 0
			-- for all other judgments, store the numerical offset as provided by the engine
			local offset
			if params.TapNoteScore == "TapNoteScore_Miss" then
				offset = "Miss" .. params.FirstTrack+1 
			else
				offset = params.TapNoteOffset
			end

			-- store judgment offsets (including misses) in an indexed table as they come
			-- also store the CurMusicSeconds for Evaluation's scatter plot
			sequential_offsets[#sequential_offsets+1] = { GAMESTATE:GetCurMusicSeconds(), offset }
		end
	end,
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.sequential_offsets = sequential_offsets
	end
}
