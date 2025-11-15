SYNCMAN = {
    scores = {},
    players = {},
    rooms = {},
    ws = nil,
    wsReady = false,
    inGame = false,
    playerReady = false,
    startAt = 0
}

function SYNCMAN:WS()
    if not SYNCMAN.ws then
        SYNCMAN.ws = NETWORK:WebSocket{
            -- url="ws://192.168.2.33:8765",
            url="ws://localhost:8765",
            handshakeTimeout=3,
            pingInterval=5,
            automaticReconnect=true,
            sendThreaded=false,
            onMessage=function(msg)
                -- SM(msg)
                local msgType = ToEnumShortString(msg.type)

                if msgType == "Message" then
                    local decoded = JsonDecode(msg.data)
                    if decoded then
                        if decoded.action == "scores" then
                            SYNCMAN.scores = decoded.scores
                            MESSAGEMAN:Broadcast("SyncStartPlayerScoresChanged")
                        elseif decoded.action == "players" then
                            SYNCMAN.players = decoded.players
                            MESSAGEMAN:Broadcast("SyncStartPlayersChanged")
                        elseif decoded.action == "rooms" then
                            SYNCMAN.rooms = decoded.rooms
                            MESSAGEMAN:Broadcast("SyncStartRoomsChanged")
                        elseif decoded.action == "start" then
                            MESSAGEMAN:Broadcast("SyncStartStart")
                            SYNCMAN.startAt = decoded.start_at or 0
                        elseif decoded.action == "time" then
                            SYNCMAN:Send({
                                action = "time",
                                time = GetTimeSinceStart()
                            })
                        else
                            Trace(JsonEncode(decoded))
                        end
                    end
                elseif msgType == "Open" then
                    SYNCMAN.wsReady = true
                    MESSAGEMAN:Broadcast("SyncStartConnected")
                elseif msgType == "Close" then
                    SYNCMAN.wsReady = false
                    MESSAGEMAN:Broadcast("SyncStartDisconnected")
                    Trace("WebSocket closed: " .. msg.reason)
                else
                    Trace(JsonEncode(msg))
                end
            end,
        }
    end

    return SYNCMAN.ws
end

function SYNCMAN:IsInGame()
    if not SYNCMAN:IsReady() then
        return false
    end

    if not SYNCMAN.inGame then
        return false
    end

    return true
end

function SYNCMAN:IsEnabled()
    if ThemePrefs.Get("EnableITGOnline") == "No" then
        return false
    end

    return true
end

function SYNCMAN:IsReady()
    if not SYNCMAN:IsEnabled() then
        return false
    end

    if not SYNCMAN.ws then
        return false
    end

    if SYNCMAN.wsReady == false then
        return false
    end

    return true
end

function SYNCMAN:GetCurrentPlayerScores()
    return SYNCMAN["scores"]
end

function SYNCMAN:GetCurrentPlayers()
    return SYNCMAN["players"]
end

function SYNCMAN:SongID(song)
    return song:GetMainTitle()
end

function SYNCMAN:RoomActive(song)
    for s in ivalues(SYNCMAN.rooms) do
        if s == SYNCMAN:SongID(song) then
            return true
        end
    end

    return false
end

function SYNCMAN:Send(message)
    if not SYNCMAN:IsReady() then
        return false
    end

    local ws = SYNCMAN:WS()
    -- if not ws then
    --     return
    -- end

    local encoded = JsonEncode(message)
    -- SM("SYNCMAN:Send: " .. encoded)
    -- local result = ws:Send(encoded, false)
    ws:Send(encoded, false)
    -- if not result then
    --     Trace("SYNCMAN:Send failed")
    --     return false
    -- end

    return true
end

function SYNCMAN:Join(room)
    local players = {}

    for player in ivalues( PlayerNumber ) do
        if GAMESTATE:IsHumanPlayer(player) then
            local steps = GAMESTATE:GetCurrentSteps(player)
            -- playerNames[#playerNames+1] = SYNCMAN:PlayerName(player)
            players[#players+1] = {
                name = SYNCMAN:PlayerName(player),
                diffLevel = steps:GetMeter(),
                diffType = steps:GetDifficulty()
            }
        end
    end

    SYNCMAN:Send({
        action = "join",
        room = room,
        players = players
    })

    -- if res then
        SYNCMAN.inGame = true
    -- end
end

function SYNCMAN:Reset()
    SYNCMAN.scores = {}
    SYNCMAN.players = {}
    SYNCMAN.inGame = false
    SYNCMAN.playerReady = false
    SYNCMAN.startAt = 0
    SYNCMAN:Send({
        action = "leave"
    })
end

function SYNCMAN:GetSyncOptionRow()
    return {
		Name = "SyncOption",
		Choices = {"Ready", "Play", "Back"},
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			list[1] = true  -- Default to "Play"
            return list
		end,
		SaveSelections = function(self, list, pn)
            local top_screen = SCREENMAN:GetTopScreen()

            if list[1] == true then
                SYNCMAN.playerReady = not SYNCMAN.playerReady
                SYNCMAN:Send({
                    action = "ready",
                    ready = SYNCMAN.playerReady
                })
            end

            if list[2] == true then
                SYNCMAN:Send({
                    action = "start"
                })
            end

            if list[3] == true then
                local prev_screen_name = top_screen:GetPrevScreenName()
                top_screen:SetNextScreenName(prev_screen_name):StartTransitioningScreen("SM_GoToNextScreen")
            end
		end,
	}
end

function SYNCMAN:PlayerName(player)
    local pn = ToEnumShortString(player)
    local gsName = SL[pn].GrooveStatsUsername
    if string.len(gsName) > 0 then
        return gsName
    else
        return PROFILEMAN:GetPlayerName(player)
    end
end
