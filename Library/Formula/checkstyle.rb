require 'formula'

class Checkstyle < Formula
  homepage 'http://checkstyle.sourceforge.net/'
  url 'http://sourceforge.net/projects/checkstyle/files/checkstyle/5.5/checkstyle-5.5-bin.tar.gz'
  sha1 '757f89f0bb6148718904577d230a9b4f8221b03c'

  def install
    # wrapper script
    (bin/'checkstyle').write <<-EOS.undent
      #! /usr/bin/env bash -e
      java -jar "#{libexec}/checkstyle-5.5-all.jar" "$@"
    EOS

    libexec.install 'checkstyle-5.5-all.jar', 'sun_checks.xml'
  end

  def test
    mktemp do
      # create test file
      (Pathname.pwd/"Test.java").write <<-EOS.undent
        public class Test{ }
      EOS
      system "#{bin}/checkstyle", "-c", "#{libexec}/sun_checks.xml", "-r", "Test.java"
    end
  end
end
