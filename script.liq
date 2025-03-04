#!/usr/bin/liquidsoap
# Playlist
i_playlist = crossfade(
    duration=3.0,
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
    name=environment.get("STREAM_NAME", default="Radio"),
    description=environment.get("STREAM_DESC", default="Our selection of music"),
    url=environment.get("STREAM_URL"),
    mount=environment.get("STREAM_MOUNTPOINT", default="live"),
    password=environment.get("ICECAST_SOURCE_PASSWORD", default="hackme"),
    host="icecast",
    port=8000,
    encoding="UTF-8",
    radio
)
