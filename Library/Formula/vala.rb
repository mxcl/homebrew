require 'formula'

class Vala < Formula
  homepage 'http://live.gnome.org/Vala'
  url 'http://download.gnome.org/sources/vala/0.17/vala-0.17.4.tar.xz'
  sha1 'e7ac9fa432eedb480827f7664ad1e26f55aaed87'

  head 'git://git.gnome.org/vala'

  depends_on 'pkg-config' => :build
  depends_on 'xz' => :build
  depends_on 'gettext'
  depends_on 'glib'

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make" # Fails to compile as a single step
    system "make install"
  end

  def test
    system "#{bin}/valac", "--version"
  end
end
