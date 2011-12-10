require 'formula'

class Polipo < Formula
  url 'http://freehaven.net/~chrisd/polipo/polipo-1.0.4.1.tar.gz'
  homepage 'http://www.pps.jussieu.fr/~jch/software/polipo/'
  head 'git://git.wifi.pps.jussieu.fr/polipo'
  md5 'bfc5c85289519658280e093a270d6703'

  def install
    cache_root = (var + "cache/polipo")
    cache_root.mkpath
    make_opts = "PREFIX=#{prefix} LOCAL_ROOT=#{share}/polipo/www DISK_CACHE_ROOT=#{cache_root} MANDIR=#{man} INFODIR=#{info} PLATFORM_DEFINES=-DHAVE_IPv6"
    system "make all #{make_opts}"
    system "make install #{make_opts}"

    (prefix + 'fr.jussieu.pps.polipo.plist').write startup_plist
    (prefix + 'fr.jussieu.pps.polipo.plist').chmod 0644
  end

  def startup_plist
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>fr.jussieu.pps.polipo</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>UserName</key>
    <string>#{`whoami`.chomp}</string>
    <key>ProgramArguments</key>
    <array>
      <string>#{bin}/polipo</string>
    </array>
  </dict>
</plist>
    EOPLIST
  end

  def caveats; <<-EOS.undent
    You can start polipo automatically on login with:
      mkdir -p ~/Library/LaunchAgents
      cp #{prefix}/fr.jussieu.pps.polipo.plist ~/Library/LaunchAgents/
      launchctl load -w ~/Library/LaunchAgents/fr.jussieu.pps.polipo.plist
    EOS
  end
end
