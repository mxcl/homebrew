class AutoconfArchive < Formula
  homepage "http://savannah.gnu.org/projects/autoconf-archive/"
  url "http://ftpmirror.gnu.org/autoconf-archive/autoconf-archive-2015.02.24.tar.xz"
  mirror "https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-2015.02.24.tar.xz"
  sha1 "3b85294775df75acce4b89d99ad268a6e7219d9c"

  # autoconf-archive is useless without autoconf
  depends_on "autoconf" => :run

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.m4").write <<-EOS.undent
      AC_INIT(myconfig, version-0.1)
      AC_MSG_NOTICE([Hello, world.])

      m4_include([#{share}/aclocal/ax_have_select.m4])

      # from http://www.gnu.org/software/autoconf-archive/ax_have_select.html
      AX_HAVE_SELECT(
        [AX_CONFIG_FEATURE_ENABLE(select)],
        [AX_CONFIG_FEATURE_DISABLE(select)])
      AX_CONFIG_FEATURE(
        [select], [This platform supports select(7)],
        [HAVE_SELECT], [This platform supports select(7).])
    EOS

    system "#{Formula["autoconf"].bin}/autoconf", "test.m4"
  end
end
