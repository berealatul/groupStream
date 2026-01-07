-- =========================
-- VLC Sync Test Extension
-- =========================

state = {
    last_playing = false,
    is_remote = false,
    server_ip = "10.160.189.122"
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
    vlc.msg.info("Sync activated")
    vlc.misc.timer(300, tick)
end

function deactivate()
end

function menu()
    return {"Start Sync"}
end

function trigger_menu(id)
    vlc.msg.info("Sync running")
end

function tick()
    if not vlc.input then return end

    poll_local()
    poll_remote()
end

function poll_local()
    local playing = vlc.input.is_playing()

    if playing ~= state.last_playing and not state.is_remote then
        send_event(playing and "play" or "pause")
    end

    state.last_playing = playing
end

function poll_remote()
    local response = vlc.net.http.request({
        url = "http://" .. state.server_ip .. ":8080/poll",
        method = "GET"
    })

    if response == "play" or response == "pause" then
        apply_remote(response)
    end
end

function send_event(action)
    vlc.msg.info("Sending " .. action)

    vlc.net.http.request({
        url = "http://" .. state.server_ip .. ":8080/event",
        method = "POST",
        headers = { "Content-Type: application/json" },
        data = '{"action":"' .. action .. '"}'
    })
end

function apply_remote(action)
    vlc.msg.info("Applying remote " .. action)

    state.is_remote = true

    if action == "play" then
        vlc.playlist.play()
    else
        vlc.playlist.pause()
    end

    state.is_remote = false
end
