require 'formula'

class Tkdiff < Formula
  homepage 'http://tkdiff.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/tkdiff/tkdiff/4.2/tkdiff-4.2.tar.gz'
  sha1 '64b07e3aca75bcfa73f43773716bdac88769f685'

  def install
    bin.install 'tkdiff'
  end

  def test
    system "#{bin}/tkdiff", "--help"
  end
end
