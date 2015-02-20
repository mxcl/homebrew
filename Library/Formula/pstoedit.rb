class Pstoedit < Formula
  homepage "http://www.pstoedit.net"
  url "https://downloads.sourceforge.net/project/pstoedit/pstoedit/3.62/pstoedit-3.62.tar.gz"
  sha1 "50d5a4e2fe0e0ff2f73cb094cb945b221083e742"
  revision 1

  depends_on "pkg-config" => :build
  depends_on "plotutils"
  depends_on "ghostscript"
  depends_on "imagemagick"
  depends_on "xz" if MacOS.version < :mavericks

  def install
    ENV.deparallelize
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"pstoedit", "-f", "pdf", test_fixtures("test.ps"), "test.pdf"
    assert File.exist?("test.pdf")
  end
end
