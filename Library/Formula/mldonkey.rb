require 'formula'

class Mldonkey <Formula
  url 'http://downloads.sourceforge.net/project/mldonkey/mldonkey/3.0.7/mldonkey-3.0.7.tar.bz2'
  homepage 'http://mldonkey.sourceforge.net/Main_Page'
  md5 '162b78fc4e20335a8fe31d91e1656db2'

  depends_on 'objective-caml'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
