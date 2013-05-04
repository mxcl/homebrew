require 'formula'

class DBus < Formula
  homepage 'http://www.freedesktop.org/wiki/Software/dbus'
  url 'http://dbus.freedesktop.org/releases/dbus/dbus-1.6.10.tar.gz'
  sha256 '1f3d6f4a53a7121328f6cd685fc14440d72e6c0006ecb3312cc779c495915e86'

  def install
    # Fix the TMPDIR to one D-Bus doesn't reject due to odd symbols
    ENV["TMPDIR"] = "/tmp"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}",
                          "--disable-xml-docs",
                          "--disable-doxygen-docs",
                          "--enable-launchd",
                          "--with-launchd-agent-dir=#{prefix}",
                          "--without-x",
                          "--disable-tests"
    system "make"
    ENV.deparallelize
    system "make install"

    (prefix+'org.freedesktop.dbus-session.plist').chmod 0644

    # Generate D-Bus's UUID for this machine
    system "#{bin}/dbus-uuidgen", "--ensure=#{var}/lib/dbus/machine-id"
  end

  def caveats; <<-EOS.undent
    If this is your first install, automatically load on login with:
        mkdir -p ~/Library/LaunchAgents
        cp #{prefix}/org.freedesktop.dbus-session.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/org.freedesktop.dbus-session.plist

    If this is an upgrade and you already have the org.freedesktop.dbus-session.plist loaded:
        launchctl unload -w ~/Library/LaunchAgents/org.freedesktop.dbus-session.plist
        cp #{prefix}/org.freedesktop.dbus-session.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/org.freedesktop.dbus-session.plist
    EOS
  end
end
