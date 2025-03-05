<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html"
              doctype-system="about:legacy-compat"
              encoding="UTF-8" />
  <xsl:template match="/icestats">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
        <title>RRM - radio.rita.moe</title>
        <link rel="icon" href="https://rita.moe/rita-icon.png" />
        <link rel="stylesheet" type="text/css" href="style-status.css" />
        <link rel="stylesheet" href="https://cdn.plyr.io/3.7.8/plyr.css" />
        <script src="https://cdn.plyr.io/3.7.8/plyr.polyfilled.js"></script>
      </head>
      <body>
        <div class="content">
          <h1 id="header">radio.rita.moe</h1>
          <!--mount point stats-->
          <xsl:for-each select="source">
            <xsl:choose>
              <xsl:when test="listeners">
                <div class="roundbox" data-mount="{@mount}">
                  <div class="mounthead">
                    <h3 class="mount">
                      <xsl:value-of select="server_name" />
                      <small>(<xsl:value-of select="@mount" />)</small>
                    </h3>
                    <div class="right">
                      <xsl:choose>
                        <xsl:when test="authenticator">
                          <a class="auth" href="/auth.xsl">Login</a>
                        </xsl:when>
                        <xsl:otherwise>
                          <ul class="mountlist">
                            <li>
                              <a class="play" href="{@mount}.m3u">M3U</a>
                            </li>
                          </ul>
                        </xsl:otherwise>
                      </xsl:choose>
                    </div>
                  </div>
                  <div class="mountcont">
                    <xsl:if test="server_type">
                      <div class="audioplayer">
                        <audio controls="controls" preload="none">
                          <source src="{@mount}" type="{server_type}" />
                        </audio>
                      </div>
                    </xsl:if>
                    <div class="playing">
                      <xsl:if test="artist">
                        <xsl:value-of select="artist" />
                        -
                      </xsl:if>
                      <xsl:value-of select="title" />
                    </div>
                  </div>
                </div>
              </xsl:when>
              <xsl:otherwise>
                <h3>
                  <xsl:value-of select="@mount" />
                  - Not Connected
                </h3>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
          <div id="footer">
            Powered by <a href="https://www.icecast.org">Icecast</a>
            and <a href="https://www.liquidsoap.info">Liquidsoap</a>.
          </div>
        </div>
        <script type="text/javascript">
<![CDATA[
          // We'll store the last title of the current mount point to check for changes
          let lastTitle = ''
          // Store the current mount point
          let currentMount = ''
          // Store the last notification
          let lastNotification = null

          // On every audio element, create a new Plyr instance
          document.querySelectorAll('div[data-mount]').forEach((e) => {
            const plyr = new Plyr(
              e.querySelector('audio'),
              {
                controls: ['play', 'current-time', 'mute', 'volume'],
                invertTime: false,
                toggleInvert: false,
              }
            )

            // When we start playing, store current mount point, clear last title and stop all other players
            plyr.on(
              'play',
              (_) => {
                currentMount = e.dataset.mount
                lastTitle = ''

                document.querySelectorAll('[data-mount]').forEach((a) => {
                  if (a !== e) {
                    a.querySelector('audio').stop()
                  }
                })
              }
            )

            // When we pause, clear current mount point and stop all data
            plyr.on(
              'pause',
              (_) => {
                // To prevent overlaps, we only clear the current mount if it's the same as the one we're pausing
                if (currentMount === e.dataset.mount) {
                  currentMount = ''
                }

                plyr.stop()
              }
            )
          })

          function np (wait) {
            // Find all mount points and fetch their status
            document.querySelectorAll('div[data-mount]').forEach((e) => {
              fetch('./status-json.xsl?mount=' + e.dataset.mount)
                .then((r) => r.json())
                .then((j) => {
                  // We delay the update to match the usual delay of the audio stream
                  setTimeout((_) => {
                    // The title may not be present, so we check for it
                    if (j.icestats.source.title) {
                      // Update the now playing text
                      e.querySelector('.playing').innerHTML = j.icestats.source.title

                      // If the title has changed and this is our current playing mount
                      if (lastTitle !== j.icestats.source.title && currentMount === e.dataset.mount) {
                        // Update the last title
                        lastTitle = j.icestats.source.title

                        // If we have permission, send a notification
                        if ('Notification' in window && Notification.permission === 'granted') {
                          lastNotification = new Notification(
                            'RRM - Now Playing',
                            {
                              body: j.icestats.source.title,
                              icon: 'https://rita.moe/rita-icon.png',
                              renotify: true,
                              requireInteraction: false,
                              tag: 'now-playing',
                            }
                          )
                        }
                      }
                    } else {
                      // If the title is not present, clear the now playing text
                      e.querySelector('.playing').innerHTML = ''
                    }
                  }, wait ?? 3000)
                })
            })
          }

          // Enable interval to fetch now playing data
          setInterval(np, 5000)
          // And run it immediately on page load
          np(0)

          // Request notification permission if it's still default
          if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission()
          }

          document.addEventListener(
            'visibilitychange',
            () => {
              // If the page is visible, close the last notification
              if (document.visibilityState === 'visible') {
                lastNotification?.close()
              }
            }
          )
]]>
        </script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
