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

function activate() end
function deactivate() end

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

-- LOW-LEVEL HTTP POST
function send_event(action)
    vlc.msg.info("SENDING " .. action)

    local body = '{"action":"' .. action .. '"}'
    local req =
        "POST /event HTTP/1.1\r\n" ..
        "Host: " .. state.server_ip .. ":8080\r\n" ..
        "Content-Type: application/json\r\n" ..
        "Content-Length: " .. #body .. "\r\n" ..
        "\r\n" ..
        body

    local fd = vlc.net.open("tcp://" .. state.server_ip .. ":8080")
    fd:write(req)
    fd:read(1024) -- ignore response
    fd:close()
end

-- LOW-LEVEL HTTP GET
function poll_remote()
    local req =
        "GET /poll HTTP/1.1\r\n" ..
        "Host: " .. state.server_ip .. ":8080\r\n" ..
        "\r\n"

    local fd = vlc.net.open("tcp://" .. state.server_ip .. ":8080")
    fd:write(req)
    local resp = fd:read(1024)
    fd:close()

    if not resp then return end

    if resp:find("play") then
        vlc.msg.info("APPLYING REMOTE PLAY")
        vlc.playlist.play()
    elseif resp:find("pause") then
        vlc.msg.info("APPLYING REMOTE PAUSE")
        vlc.playlist.pause()
    else
        vlc.msg.info("NO REMOTE ACTION")
    end
end
