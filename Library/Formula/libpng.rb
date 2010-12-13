require 'formula'

class Libpng <Formula
  #url 'http://downloads.sourceforge.net/project/libpng/libpng-previous/1.2.44/libpng-1.2.44.tar.bz2'
  url 'http://sourceforge.net/projects/libpng/files/libpng14/1.4.4/libpng-1.4.4.tar.bz2'
  homepage 'http://www.libpng.org/pub/png/libpng.html'
  #md5 'e3ac7879d62ad166a6f0c7441390d12b'
  md5 'e6446d6cc10621ce0ed27ff82a70a7e8'

  keg_only :provided_by_osx

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end
end
