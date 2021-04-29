local player = ...
local alive = true
local notes_passed = 0

return Def.Actor{
	HealthStateChangedMessageCommand=function(self, param)
		if param.PlayerNumber == player and param.HealthState == "HealthState_Dead" then
			alive = false
		end
	end,
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end
		if alive == false then return end

		if params.TapNoteOffset then
			notes_passed = notes_passed + 1
		end
	end,
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.notes_passed = notes_passed
	end
}
