#!/usr/bin/liquidsoap
# This is the EU R128 standard
settings.lufs.track_gain_target := -23.
# Enable LUFS compute if missing from files
enable_lufs_track_gain_metadata()

# Enable the autocue metadata resolver
enable_autocue_metadata()

# Playlist
i_playlist = crossfade(
    duration=3.0,
    blank.eat(
        at_beginning=true,
        start_blank=true,
        max_blank=1.0,
        threshold=-45.0,
        normalize_track_gain(
            playlist(
                mode="randomize",
                reload=1,
                reload_mode="rounds",
                "/music"
            )
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
