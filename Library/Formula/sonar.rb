class Sonar < Formula
  desc "Manage code quality"
  homepage "http://www.sonarqube.org/"
  url "https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-5.4.zip"
  sha256 "d0f947f5e4639d58ceaeb046c623193fdafe291289182ef465d1be6100e04274"

  depends_on :java => "1.7+"

  bottle :unneeded

  def install
    # Delete native bin directories for other systems
    rm_rf Dir["bin/{aix,hpux,linux,solaris,windows}-*"]

    if MacOS.prefer_64_bit?
      rm_rf "bin/macosx-universal-32"
    else
      rm_rf "bin/macosx-universal-64"
    end

    # Delete Windows files
    rm_f Dir["war/*.bat"]
    libexec.install Dir["*"]

    if MacOS.prefer_64_bit?
      bin.install_symlink "#{libexec}/bin/macosx-universal-64/sonar.sh" => "sonar"
    else
      bin.install_symlink "#{libexec}/bin/macosx-universal-32/sonar.sh" => "sonar"
    end
  end

  plist_options :manual => "sonar console"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
        <string>#{opt_bin}/sonar</string>
        <string>start</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_match /SonarQube/, shell_output("#{bin}/sonar status", 1)
  end
end
