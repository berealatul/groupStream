state = {
    server_ip = "10.160.189.122"
}

function descriptor()
    return {
        title = "Play/Pause Sync",
        version = "0.1",
        author = "Test",
        shortdesc = "Manual Sync Test",
        capabilities = {"menu"}
    }
end

-- Required (even if empty)
function activate()
end

function deactivate()
end

function menu()
    return {
        "Send PLAY",
        "Send PAUSE",
        "Apply REMOTE"
    }
end

function trigger_menu(id)
    if id == 1 then
        send_event("play")
    elseif id == 2 then
        send_event("pause")
    elseif id == 3 then
        poll_remote()
    end
end

function send_event(action)
    vlc.msg.info("SENDING " .. action)

    vlc.net.request({
        url = "http://" .. state.server_ip .. ":8080/event",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json"
        },
        data = '{"action":"' .. action .. '"}'
    })
end

function poll_remote()
    local response = vlc.net.request({
        url = "http://" .. state.server_ip .. ":8080/poll",
        method = "GET"
    })

    if response == "play" then
        vlc.msg.info("APPLYING REMOTE PLAY")
        vlc.playlist.play()
    elseif response == "pause" then
        vlc.msg.info("APPLYING REMOTE PAUSE")
        vlc.playlist.pause()
    else
        vlc.msg.info("NO REMOTE ACTION")
    end
end
