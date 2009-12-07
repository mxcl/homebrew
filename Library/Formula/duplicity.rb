require 'formula'

class Duplicity <Formula
  url 'http://code.launchpad.net/duplicity/0.6-series/0.6.06/+download/duplicity-0.6.06.tar.gz'
  homepage 'http://www.nongnu.org/duplicity/'
  md5 'abbbbcde4af24efffbc218583d581453'

  depends_on 'librsync'

  def install
    ENV.universal_binary
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
