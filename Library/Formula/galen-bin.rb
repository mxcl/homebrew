class GalenBin < Formula
  homepage "http://galenframework.com/"
  url "https://github.com/galenframework/galen/releases/download/galen-1.4.10/galen-bin-1.4.10.zip"
  sha1 "237896138a244d1a168a3220d07edd88f6f39da9"

  depends_on :java => "1.6"

  def galen_wrapper; <<-EOS.undent
    #!/bin/sh
    set -e
    java -cp "#{libexec}/galen.jar:lib/*:libs/*" net.mindengine.galen.GalenMain "$@"
    EOS
  end

  def install
    libexec.install "galen.jar"
    (bin/"galen").write(galen_wrapper)
  end

  test do
    output = shell_output("#{bin}/galen -v")
    assert output.include?("Galen Framework\nVersion: 1.4.10")
  end
end
