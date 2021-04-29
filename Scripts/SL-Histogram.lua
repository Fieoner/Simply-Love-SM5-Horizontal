local function gen_vertices(player, width, height)
	local Song, Steps
	local first_step_has_occurred = false

	if GAMESTATE:IsCourseMode() then
		local TrailEntry = GAMESTATE:GetCurrentTrail(player):GetTrailEntry(GAMESTATE:GetCourseSongIndex())
		Steps = TrailEntry:GetSteps()
		Song = TrailEntry:GetSong()
	else
		Steps = GAMESTATE:GetCurrentSteps(player)
		Song = GAMESTATE:GetCurrentSong()
	end

	local PeakNPS, NPSperMeasure = GetNPSperMeasure(Song, Steps)

	-- store the PeakNPS in GAMESTATE:Env()[pn.."PeakNPS"] in case both players are joined
	-- their charts may have different peak densities, and if they both want histograms,
	-- we'll need to be able to compare densities and scale one of the graphs vertically
	GAMESTATE:Env()[ToEnumShortString(player).."PeakNPS"] = PeakNPS

	-- use MESSAGEMAN to broadcast that the peak NPS has been calculated (and/or updated in CourseMode)
	-- and is available.  actors on the current screen can listen for this via something like:
	--
	-- PeakNPSUpdatedMessageCommand=function(self)
	--   local p1peak = GAMESTATE:Env()["P1PeakNPS"]
	-- end
	MESSAGEMAN:Broadcast("PeakNPSUpdated")

	local verts = {}
	local x, y, t

	if (PeakNPS and NPSperMeasure and #NPSperMeasure > 1) then

		local TimingData = Steps:GetTimingData()
		local FirstSecond = math.min(TimingData:GetElapsedTimeFromBeat(0), 0)
		local LastSecond = Song:GetLastSecond()

		-- magic numbers obtained from Photoshop's Eyedrop tool in rgba percentage form (0 to 1)
		local blue   = {0,    0.678, 0.753, 1}
		local purple = {0.51, 0,     0.631, 1}
		local upper

		for i, nps in ipairs(NPSperMeasure) do

			if nps > 0 then first_step_has_occurred = true end

			if first_step_has_occurred then
				-- i will represent the current measure number but will be 1 larger than
				-- it should be (measures in SM start at 0; indexed Lua tables start at 1)
				-- subtract 1 from i now to get the actual measure number to calculate time
				t = TimingData:GetElapsedTimeFromBeat((i-1)*4)

				x = scale(t, FirstSecond, LastSecond, 0, width)
				y = round(-1 * scale(nps, 0, PeakNPS, 0, height))

				-- if the height of this measure is the same as the previous two measures
				-- we don't need to add two more points (bottom and top) to the verts table,
				-- we can just "extend" the previous two points by updating their x position
				-- to that of the current measure.  For songs with long streams, this should
				-- cut down on the overall size of the verts table significantly.
				if #verts > 2 and verts[#verts][1][2] == y and verts[#verts-2][1][2] == y then
					verts[#verts][1][1] = x
					verts[#verts-1][1][1] = x
				else
					-- lerp_color() is a global function defined by the SM engine that takes three arguments:
					--    a float between [0,1]
					--    color1
					--    color2
					-- and returns a color that has been linearly interpolated by that percent between the two colors provided
					-- for example, lerp_color(0.5, yellow, orange) will return the color that is halfway between yellow and orange
					upper = lerp_color(math.abs(y/height), blue, purple )

					verts[#verts+1] = {{x, 0, 0}, blue} -- bottom of graph (blue)
					verts[#verts+1] = {{x, y, 0}, upper}  -- top of graph (somewhere between blue and purple)
				end
			end
		end
	end

	return verts
end

-- FIXME: add inline comments explaining the intent/purpose of this code
function interpolate_vert(v1, v2, offset)
	local ratio = (offset - v1[1][1]) / (v2[1][1] - v1[1][1])
	local y = v1[1][2] * (1 - ratio) + v2[1][2] * ratio
	local color = lerp_color(ratio, v1[2], v2[2])

	return {{offset, y, 0}, color}
end


NPS_Histogram = function(player, _w, _h)

	local SongNumberInCourse = 0
	--local legacygraph = ThemePrefs.Get("UseLegacyDensityGraph")
	local legacygraph = true --TODO

	local amv = Def.ActorMultiVertex{
		Name="DensityGraph_AMV",

		-- based on noticeable lag at ~3.5k
		MaxVertices = 2000,

		Initialize=function(self, actor)
			local Song, Steps
			local first_step_has_occurred = false

			if GAMESTATE:IsCourseMode() then
				local TrailEntry = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()[SongNumberInCourse]
				Steps = TrailEntry:GetSteps()
				Song = TrailEntry:GetSong()
			else
				Steps = GAMESTATE:GetCurrentSteps(player)
				Song = GAMESTATE:GetCurrentSong()
			end

			local PeakNPS, NPSperMeasure = GetNPSperMeasure(Song, Steps)
			-- broadcast this for any other actors on the current screen that rely on knowing the peak nps
			MESSAGEMAN:Broadcast("PeakNPSUpdated", {PeakNPS=PeakNPS})

			-- also, store the PeakNPS in GAMESTATE:Env()[pn.."PeakNPS"] in case both players are joined
			-- their charts may have different peak densities, and if they both want histograms,
			-- we'll need to be able to compare densities and scale one of the graphs vertically
			GAMESTATE:Env()[ToEnumShortString(player).."PeakNPS"] = PeakNPS

			local verts = {}
			local x, y, t

			if (PeakNPS and NPSperMeasure and #NPSperMeasure > 1) then

				local TimingData = Steps:GetTimingData()
				local FirstSecond = TimingData:GetElapsedTimeFromBeat(0)
				local LastSecond = Song:GetLastSecond()

				-- magic numbers obtained from Photoshop's Eyedrop tool
				local yellow = {0.968, 0.953, 0.2, 1}
				local orange = {0.863, 0.553, 0.2, 1}
				local upper

				for i, nps in ipairs(NPSperMeasure) do

					if nps > 0 then first_step_has_occurred = true end

					if first_step_has_occurred then
						-- i will represent the current measure number but will be 1 larger than
						-- it should be (measures in SM start at 0; indexed Lua tables start at 1)
						-- subtract 1 from i now to get the actual measure number to calculate time
						t = TimingData:GetElapsedTimeFromBeat((i-1)*4)
						
						if legacygraph then
							t1 = TimingData:GetElapsedTimeFromBeat((i)*4)
							x1 = scale(t1,  FirstSecond, LastSecond, 0, _w)
						end

						x = scale(t, FirstSecond, LastSecond, 0, _w)
						y = round(-1 * scale(nps, 0, PeakNPS, 0, _h))

						-- if the height of this measure is the same as the previous two measures
						-- we don't need to add two more points (bottom and top) to the verts table,
						-- we can just "extend" the previous two points by updating their x position
						-- to that of the current measure.  For songs with long streams, this should
						-- cut down on the overall size of the verts table significantly.
						if #verts > 2 and verts[#verts][1][2] == y and verts[#verts-3][1][2] == y then
							verts[#verts][1][1] = x
							verts[#verts-1][1][1] = x
						else
							-- lerp_color() take a float between [0,1], color1, and color2, and returns a color
							-- that has been linearly interpolated by that percent between the colors provided
							upper = lerp_color(math.abs(y/_h), yellow, orange )

							verts[#verts+1] = {{x, 0, 0}, yellow} -- bottom of graph (yellow)
							verts[#verts+1] = {{x, y, 0}, upper}  -- top of graph (somewhere between yellow and orange)
							if legacygraph then
								verts[#verts+1] = {{x1, 0, 0}, yellow} -- bottom of graph (yellow)
								verts[#verts+1] = {{x1, y, 0}, upper}  -- top of graph (somewhere between yellow and orange)
							end
						end
					end
				end

				actor:SetNumVertices(#verts):SetVertices(verts)
			end
		end
	}

	amv.InitCommand=function(self)
		self:SetDrawState({Mode="DrawMode_QuadStrip"})
	end
	amv.CurrentSongChangedMessageCommand=function(self)
		SongNumberInCourse = SongNumberInCourse + 1

		-- we've reached a new song, so reset the vertices for the density graph
		-- this will occur at the start of each new song in CourseMode
		-- and at the start of "normal" gameplay
		amv:Initialize(self)
	end

	return amv
end


function Scrolling_NPS_Histogram(player, width, height)
	local verts, visible_verts
	local left_idx, right_idx

	local amv = Def.ActorMultiVertex{
		Name="ScrollingDensityGraph_AMV",
		InitCommand=function(self)
			self:SetDrawState({Mode="DrawMode_QuadStrip"})
		end,
		UpdateCommand=function(self)
			if visible_verts ~= nil then
				self:SetNumVertices(#visible_verts):SetVertices(visible_verts)
				visible_verts = nil
			end
		end,

		LoadCurrentSong=function(self, scaled_width)
			verts = gen_vertices(player, scaled_width, height)

			left_idx = 1
			right_idx = 2
			self:SetScrollOffset(0)
		end,
		SetScrollOffset=function(self, offset)
			local left_offset = offset
			local right_offset = offset + width

			for i = left_idx, #verts, 2 do
				if verts[i][1][1] >= left_offset then
					left_idx = i
					break
				end
			end

			for i = right_idx, #verts, 2 do
				if verts[i][1][1] <= right_offset then
					right_idx = i
				else
					break
				end
			end

			visible_verts = {unpack(verts, left_idx, right_idx)}

			if left_idx > 1 then
				local prev1, prev2, cur1, cur2 = unpack(verts, left_idx-2, left_idx+1)
				table.insert(visible_verts, 1, interpolate_vert(prev1, cur1, left_offset))
				table.insert(visible_verts, 2, interpolate_vert(prev2, cur2, left_offset))
			end

			if right_idx < #verts then
				local cur1, cur2, next1, next2 = unpack(verts, right_idx-1, right_idx+2)
				table.insert(visible_verts, interpolate_vert(cur1, next1, right_offset))
				table.insert(visible_verts, interpolate_vert(cur2, next2, right_offset))
			end
		end
	}

	return amv
end
