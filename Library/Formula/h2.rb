require 'formula'

class H2 < Formula
  desc "Java SQL database"
  homepage 'http://www.h2database.com/'
  url 'http://www.h2database.com/h2-2015-04-10.zip'
  version '1.4.187'
  sha1 '20241dfbe12c1986d46b928f8ca1689b1be1fc97'

  def script; <<-EOS.undent
    #!/bin/sh
    cd #{libexec} && bin/h2.sh "$@"
    EOS
  end

  def install
    # Remove windows files
    rm_f Dir["bin/*.bat"]

    # Fix the permissions on the script
    chmod 0755, "bin/h2.sh"

    libexec.install Dir['*']
    (bin+'h2').write script
  end

  plist_options :manual => 'h2'

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/h2</string>
            <string>-tcp</string>
            <string>-web</string>
            <string>-pg</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end
end
