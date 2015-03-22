class Sshguard < Formula
  homepage "http://www.sshguard.net/"
  url "https://downloads.sourceforge.net/project/sshguard/sshguard/sshguard-1.5/sshguard-1.5.tar.bz2"
  sha256 "b537f8765455fdf8424f87d4bd695e5b675b88e5d164865452137947093e7e19"

  # Fix blacklist flag (-b) so that it doesn't abort on first usage.
  # Upstream bug report:
  # http://sourceforge.net/tracker/?func=detail&aid=3252151&group_id=188282&atid=924685
  patch do
    url "http://sourceforge.net/p/sshguard/bugs/_discuss/thread/3d94b7ef/c062/attachment/sshguard.c.diff"
    sha256 "1bdf1db9e0bd730cfc6926dde683fcf5cd7b420ae003f9ec44dce083fe8eb54b"
  end

  def install
    mkdir_p var/"log"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-firewall=#{firewall}"
    system "make", "install"
  end

  def firewall
    MacOS.version >= :lion ? "pf" : "ipfw"
  end

  def log_path
    MacOS.version >= :lion ? "/var/log/system.log" : "/var/log/secure.log"
  end

  def caveats
    if MacOS.version >= :lion then <<-EOS.undent
      Add the following lines to /etc/pf.conf to block entries in the sshguard
      table (replace $ext_if with your WAN interface):

        table <sshguard> persist
        block in quick on $ext_if proto tcp from <sshguard> to any port 22 label "ssh bruteforce"

      Then run sudo pfctl -f /etc/pf.conf to reload the rules.
      EOS
    end
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>KeepAlive</key>
      <true/>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/sshguard</string>
        <string>-l</string>
        <string>#{log_path}</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end
end
