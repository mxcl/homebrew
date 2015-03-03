class Plzip < Formula
  homepage "http://www.nongnu.org/lzip/plzip.html"
  url "http://download.savannah.gnu.org/releases/lzip/plzip/plzip-1.3.tar.gz"
  sha1 "e339c06093d8e7905390cc7c39f28f6198a66471"

  bottle do
    cellar :any
    sha1 "f9530aaba99fbd81804a9def33e781880a66d2e2" => :mavericks
    sha1 "0a2283e41795f32f2015ace63936b309df74aec9" => :mountain_lion
    sha1 "c9826ce05d1b5055a3ba5d20fae5c7d1cd4a091b" => :lion
  end

  devel do
    url "http://download.savannah.gnu.org/releases/lzip/plzip/plzip-1.4-pre1.tar.gz"
    sha1 "817b9d1635be6db35907733f7eedcd2b7642ccdd"
    version "1.4-pre1"
  end

  depends_on "lzlib"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "CXX=#{ENV.cxx}",
                          "CXXFLAGS=#{ENV.cflags}"
    system "make"
    system "make", "check"
    system "make", "-j1", "install"
  end

  test do
    text = "Hello Homebrew!"
    compressed = pipe_output("#{bin}/plzip -c", text)
    assert_equal text, pipe_output("#{bin}/plzip -d", compressed)
  end
end
