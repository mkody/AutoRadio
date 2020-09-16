<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html"
              doctype-system="about:legacy-compat"
              encoding="UTF-8" />
  <xsl:template match="/icestats">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
        <title>Radio Rita.moe</title>
        <link rel="icon" href="https://rita.moe/rita-icon.png" />
        <link rel="stylesheet" type="text/css" href="style-status.css" />
        <link rel="stylesheet" href="https://cdn.plyr.io/3.6.2/plyr.css" />
        <script src="https://cdn.plyr.io/3.6.2/plyr.polyfilled.js"></script>
      </head>
      <body>
        <div class="content">
          <h1 id="header">Radio Rita.moe</h1>
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
                            <!--
                            <li>
                              <a class="play" href="{@mount}.xspf">XSPF</a>
                            </li>
                            <li>
                              <a class="play" href="{@mount}.vclt">VCLT</a>
                            </li>
                            -->
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
                    <div class="search">
                      <a href="/" onclick="ss('{@mount}'); return false;">(search)</a>
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
          function ss (mount) {
            let title = document.querySelector('[data-mount="' + mount + '"] .playing').innerHTML
            let se = document.querySelector('[data-mount="' + mount + '"] .search a')
            se.innerHTML = 'Please wait...'
            fetch('https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=1&safeSearch=none&type=video&videoCategoryId=10&key=AIzaSyB0PbGfWP_AwEXx7_DypkJiB0qIjHxedi0&q=' + encodeURIComponent(title))
              .then(r => r.json())
              .then(j => {
                se.innerHTML = '(search)'
                if (j.items.length > 0) {
                  window.open('https://combine.fm/youtube/track/' + j.items[0].id.videoId, '_blank')
                }
              })
          }

          function s () {
            document.querySelectorAll('div[data-mount]').forEach(e => {
              fetch('https://radio.rita.moe/status-json.xsl?mount=' + e.dataset.mount)
                .then(r => r.json())
                .then(j => {
                  setTimeout(_ => {
                    e.querySelector('.playing').innerHTML = j.icestats.source.title
                  }, 5000)
                })
            })
          }

          setInterval(s, 3000)

          document.querySelectorAll('audio').forEach(e => {
            new Plyr(e, {
              controls: ['play', 'current-time', 'mute', 'volume'],
              invertTime: false,
              toggleInvert: false
            })
          })
]]>
        </script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
