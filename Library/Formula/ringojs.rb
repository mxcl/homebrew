require 'formula'

class Ringojs < Formula
  homepage 'http://ringojs.org'
  url 'https://github.com/downloads/ringo/ringojs/ringojs-0.8.tar.gz'
  sha1 '28fd76fce28b41e2abcbe27a8b1731744d340e94'

  def install
    rm Dir['bin/*.cmd']
    libexec.install Dir['*']
    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end
end
