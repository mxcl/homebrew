require 'formula'

class Udpxy < Formula
  homepage 'http://www.udpxy.com/'
  url 'http://www.udpxy.com/download/1_23/udpxy.1.0.23-9-prod.tar.gz'
  sha1 '4194fc98d51284da48d07c44bbc5bdfa4813a4b8'
  version '1.0.23-9'

  patch :DATA

  def install
    system 'make'
    system 'make', 'install', "DESTDIR=#{prefix}", 'PREFIX=""'
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
        <string>#{opt_bin}/udpxy</string>
        <string>-p</string>
        <string>4022</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
    EOS
  end
end

__END__
--- a/Makefile  2014-07-30 23:15:11.000000000 +0200
+++ b/Makefile 2014-07-30 23:15:02.000000000 +0200
@@ -32,7 +32,7 @@
 ALL_FLAGS = -W -Wall -Werror --pedantic $(CFLAGS)

 SYSTEM=$(shell uname 2>/dev/null)
-ifeq ($(SYSTEM), FreeBSD)
+ifeq ($(SYSTEM), Darwin)
 MAKE := gmake
 GZIP := /usr/bin/gzip
 endif