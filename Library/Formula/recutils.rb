class Recutils < Formula
  homepage "http://www.gnu.org/software/recutils/"
  url "http://ftpmirror.gnu.org/recutils/recutils-1.7.tar.gz"
  mirror "http://ftp.gnu.org/gnu/recutils/recutils-1.7.tar.gz"
  sha1 "20d265aecb05ca4e4072df9cfac08b1392da6919"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.csv").write <<-EOS.undent
      a,b,c
      1,2,3
    EOS
    system "#{bin}/csv2rec", "test.csv"
  end
end
