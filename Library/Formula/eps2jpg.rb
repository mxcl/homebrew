require 'formula'

class Eps2jpg < Formula
  url 'http://www.few.vu.nl/~wkager/download/EPSTools110601.tgz'
  homepage 'http://www.few.vu.nl/~wkager/tools.htm'
  md5 'e3af9adc156fe0a1b90ae6f2b3b487b5'

  depends_on 'coreutils'
  depends_on 'gawk'
  depends_on 'ghostscript'

  def install
    bin.install 'eps2jpg'
    ohai 'You may also want to install eps2pdf and eps2png.'
  end

  def test
    system 'eps2jpg'
  end
end
