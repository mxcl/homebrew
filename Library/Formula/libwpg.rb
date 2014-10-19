require "formula"

class Libwpg < Formula
  homepage 'http://libwpg.sourceforge.net/'
  url 'http://dev-www.libreoffice.org/src/libwpg-0.3.0.tar.bz2'
  sha1 'c8422f9a01e98ff3cb5d64d518e61f6a0bb77551'

  bottle do
    cellar :any
    revision 1
    sha1 "4ffcaff0f379c8be9497fe5783ef1e8ec19a5df5" => :yosemite
    sha1 "869f2ed7ca10f81070797af9f6668ce483013c3b" => :mavericks
    sha1 "23b67bcab674ef8a3d47370fd1fc6c7c2a84fa78" => :mountain_lion
  end

  depends_on 'pkg-config' => :build
  depends_on 'libwpd'
  depends_on 'librevenge'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/'test.cpp').write <<-EOS.undent
      #include <libwpg/libwpg.h>
      int main() {
        return libwpg::WPG_AUTODETECT;
      }
    EOS
    system ENV.cc, "test.cpp", "-o", "test",
                   "-lrevenge-0.0", "-I#{Formula['librevenge'].include}/librevenge-0.0",
                   "-lwpg-0.3", "-I#{include}/libwpg-0.3"
    system "./test"
  end
end
