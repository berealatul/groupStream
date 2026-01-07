-- =========================
-- VLC Sync Test Extension
-- =========================

state = {
    last_playing = false,
    is_remote = false,
    server_url = "http://10.160.189.122:8080/event"
}

function descriptor()
    return {
        title = "VLC Sync Test",
        version = "0.1",
        author = "Test",
        shortdesc = "Play/Pause Sync",
        capabilities = {"menu"}
    }
end

function activate()
    vlc.msg.info("Sync extension activated")
    vlc.misc.timer(300, poll)
end

function deactivate()
end

function menu()
    return {"Start Sync"}
end

function trigger_menu(id)
    if id == 1 then
        vlc.msg.info("Sync started")
    end
end

function poll()
    if not vlc.input then
        return
    end

    local playing = vlc.input.is_playing()

    if playing ~= state.last_playing and not state.is_remote then
        send_event(playing and "play" or "pause")
    end

    state.last_playing = playing
end

function send_event(action)
    local body = string.format('{"action":"%s"}', action)

    vlc.net.http.request({
        url = state.server_url,
        method = "POST",
        headers = { "Content-Type: application/json" },
        data = body
    })
end

function apply_remote(action)
    state.is_remote = true

    if action == "play" then
        vlc.playlist.play()
    elseif action == "pause" then
        vlc.playlist.pause()
    end

    state.is_remote = false
end

-- Poll server for remote events (simple long-poll)
function poll_server()
    local response = vlc.net.http.request({
        url = "http://10.160.189.122:8080/poll",
        method = "GET"
    })

    if response and response ~= "" then
        apply_remote(response)
    end
end
