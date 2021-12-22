#!/usr/bin/liquidsoap
# Allow root
settings.init.allow_root.set(true)

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
i_playlist = crossfade(
    duration=3.0,
    smart=true,
    blank.eat(
        start_blank=true,
        max_blank=1.0,
        threshold=-45.0,
        playlist(
            mode="randomize",
            reload=1,
            reload_mode="rounds",
            "/music"
        )
    )
)

# Make it safe
radio = mksafe(i_playlist)

# Output
output.icecast(
    %mp3(
        bitrate=128,
        id3v2=true
    ),
    name=getenv("STREAM_NAME"),
    description=getenv("STREAM_DESC"),
    url=getenv("STREAM_URL"),
    mount=getenv("STREAM_MOUNTPOINT"),
    password=getenv("ICECAST_SOURCE_PASSWORD"),
    host="icecast",
    port=8000,
    encoding="UTF-8",
    radio
)
