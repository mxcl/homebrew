require "formula"

class JettyRunner < Formula
  homepage "http://www.eclipse.org/jetty/documentation/9.2.2.v20140723/runner.html"
  url "http://central.maven.org/maven2/org/eclipse/jetty/jetty-runner/9.2.2.v20140723/jetty-runner-9.2.2.v20140723.jar"
  version "9.2.2.v20140723"
  sha1 "0be6af27dbd282bd0a2b566615dd39e53e706145"

  def install
    #put jetty-runner.jar in libexec
    libexec.install Dir['*']

    #put exec script in bin
    bin.mkpath
    (bin+'jetty-runner').write <<-EOS.undent
      #!/bin/bash
      java -jar #{libexec}/jetty-runner-9.2.2.v20140723.jar "$@"
    EOS
  end
end
