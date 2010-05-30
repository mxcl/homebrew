require 'formula'

class Dia <Formula
  depends_on 'intltool'
  depends_on 'gettext'

  depends_on 'pango'
  depends_on 'libtiff'
  depends_on 'gtk+'

  url 'http://ftp.gnome.org/pub/gnome/sources/dia/0.97/dia-0.97.tar.bz2'
  homepage 'http://live.gnome.org/Dia'
  md5 '3d11f9aaa5a4923f0a5533962c87bdfb'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
