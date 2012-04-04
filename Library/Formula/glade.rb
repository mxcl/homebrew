require 'formula'

class Glade < Formula
  homepage 'http://glade.gnome.org/'
  url 'http://ftp.gnome.org/pub/GNOME/sources/glade3/3.8/glade3-3.8.2.tar.xz'
  sha256 'f180a5018eee6e3fe574854cb025af897dd9962b01d17d5752e626876d388b19'

  depends_on 'pkg-config' => :build
  depends_on 'xz' => :build
  depends_on 'gettext'
  depends_on 'intltool'
  depends_on 'libglade'
  depends_on 'hicolor-icon-theme'

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make" # separate steps required
    system "make", "install"
  end
end
