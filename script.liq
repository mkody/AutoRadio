#!/usr/bin/liquidsoap
# Allow root for official docker image
set("init.allow_root", true)

# Set environments if empty
if getenv("ICECAST_SOURCE_PASSWORD") == "" then
    setenv("ICECAST_SOURCE_PASSWORD", "hackme")
end
if getenv("STREAM_NAME") == "" then
    setenv("STREAM_NAME", "Radio")
end
if getenv("STREAM_DESC") == "" then
    setenv("STREAM_DESC", "Our selection of music")
end
if getenv("STREAM_MOUNTPOINT") == "" then
    setenv("STREAM_MOUNTPOINT", "live")
end

# Playlist
i_playlist = normalize(
    playlist(
        id="playlist",
        mode="random",
        reload=600,
        "/music"
    )
)

# Silence 
i_silence = blank(id="blank")

# Fallback to Silence if Playlist dies for some reason
radio = fallback(
    track_sensitive=false,
    [ i_playlist, i_silence ]
)

# Output
output.icecast(
    %mp3(
        bitrate=128,
        id3v2=true
    ),
    name = getenv("STREAM_NAME"),
    description = getenv("STREAM_DESC"),
    url = getenv("STREAM_URL"),
    mount = getenv("STREAM_MOUNTPOINT"),
    password = getenv("ICECAST_SOURCE_PASSWORD"),
    host = "icecast",
    port = 8000,
    encoding = "UTF-8",
    radio
)
