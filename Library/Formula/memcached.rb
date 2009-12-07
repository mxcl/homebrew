require 'formula'

class Memcached <Formula
  @url='http://memcached.googlecode.com/files/memcached-1.4.0.tar.gz'
  @homepage='http://www.danga.com/memcached/'
  @md5='d7651ecb8bf345144cb17900d9a46c85'

  depends_on 'libevent'

  def install
    system "./configure --prefix='#{prefix}'"
    system "make install"

    (prefix+'com.danga.memcached.plist').write startup_plist
  end

  def caveats; <<-EOS
You can enabled memcached to automatically load on login with:
    launchctl load -w #{prefix}/com.danga.memcached.plist

Or start it manually:
    #{HOMEBREW_PREFIX}/bin/memcached

Add "-d" to start it as a daemon.
    EOS
  end

  def startup_plist
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.danga.memcached</string>
  <key>KeepAlive</key>
  <true/>
  <key>ProgramArguments</key>
  <array>
    <string>#{HOMEBREW_PREFIX}/bin/memcached</string>
    <string>-d</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>UserName</key>
  <string>#{`whoami`}</string>
  <key>WorkingDirectory</key>
  <string>#{HOMEBREW_PREFIX}</string>
</dict>
</plist>
    EOPLIST
  end
end
