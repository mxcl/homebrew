require 'formula'

class NoBdb5 < Requirement
  satisfy(:build_env => false) { !Formula.factory("berkeley-db").installed? }

  def message; <<-EOS.undent
    This software can fail to compile when Berkeley-DB 5.x is installed.
    You may need to try:
      brew unlink berkeley-db
      brew install squid
      brew link berkeley-db
    EOS
  end
end

class Squid < Formula
  homepage 'http://www.squid-cache.org/'
  url 'http://www.squid-cache.org/Versions/v3/3.3/squid-3.3.5.tar.gz'
  sha1 '66210259645f50bd4af0f6aa4e871381c0bf35be'

  depends_on NoBdb5

  option "with-ipfw-transparent", "Enable Transparent Proxy support for systems using FreeBSD IPFW-style firewalling. Also works with PF"

  def install
    # For --disable-eui, see:
    # http://squid-web-proxy-cache.1019090.n4.nabble.com/ERROR-ARP-MAC-EUI-operations-not-supported-on-this-operating-system-td4659335.html
    args =%W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --localstatedir=#{var}
      --enable-ssl
      --enable-ssl-crtd
      --disable-eui
    ]

    args << "--enable-ipfw-transparent" if build.with?("ipfw-transparent")

    system "./configure", *args
    system "make install"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/sbin/squid</string>
        <string>-N</string>
        <string>-d 1</string>
        <string>-D</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}</string>
    </dict>
    </plist>
    EOS
  end
end
