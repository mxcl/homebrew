require 'formula'

class Hamlib < Formula
  homepage 'http://hamlib.sourceforge.net'
  url 'http://pkgs.fedoraproject.org/repo/pkgs/hamlib/hamlib-1.2.15.3.tar.gz/3cad8987e995a00e5e9d360e2be0eb43/hamlib-1.2.15.3.tar.gz'
  sha1 '15ab404ea37e5627abea89f9e051d393966918ba'

  bottle do
    revision 1
    sha1 "065230b0278836ac59ff9cfaef2c0c5a3447c4be" => :yosemite
    sha1 "a84950c2f3415fddd514121d3638b53671d74727" => :mavericks
    sha1 "febb53a406f79f38d8a7ba1cbdebb88e3aeca966" => :mountain_lion
  end

  depends_on 'pkg-config' => :build
  depends_on 'libtool' => :run
  depends_on 'libusb-compat'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end

  test do
    system "#{bin}/rigctl", "-V"
  end
end
