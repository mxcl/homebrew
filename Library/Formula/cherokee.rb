require 'formula'

class Cherokee < Formula
  homepage 'http://www.cherokee-project.com/'
  url 'http://www.cherokee-project.com/download/1.2/1.2.99/cherokee-1.2.99.tar.gz'
  md5 'c83115c3eebb29e6f2b4cc6fe699affe'

  depends_on 'gettext'

  skip_clean "var/run"
  skip_clean "var/log"
  skip_clean "var/lib/cherokee/graphs/images"

  def caveats
    <<-EOS.undent
      Cherokee is setup to run with your user permissions as part of the
      www group on port 80. This can be changed in the cherokee-admin
      but be aware the new user will need permissions to write to:
        #{var}/cherokee
      for logging and runtime files.

       If this is your first install, automatically load on startup with:
          sudo cp #{prefix}/org.cherokee.webserver.plist /Library/LaunchDaemons
          sudo launchctl load -w /Library/LaunchDaemons/org.cherokee.webserver.plist

      If this is an upgrade and you already have the plist loaded:
          sudo launchctl unload -w /Library/LaunchDaemons/org.cherokee.webserver.plist
          sudo cp #{prefix}/org.cherokee.webserver.plist /Library/LaunchDaemons
          sudo launchctl load -w /Library/LaunchDaemons/org.cherokee.webserver.plist
    EOS
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}/cherokee",
                          "--with-wwwuser=#{ENV['USER']}",
                          "--with-wwwgroup=www"
    system "make install"

    prefix.install "org.cherokee.webserver.plist"
    (prefix+'org.cherokee.webserver.plist').chmod 0644
    (share+'cherokee/admin/server.py').chmod 0755
  end
end
