require "formula"

class Libcdio < Formula
  homepage "http://www.gnu.org/software/libcdio/"
  url "http://ftpmirror.gnu.org/libcdio/libcdio-0.93.tar.gz"
  mirror "http://ftp.gnu.org/gnu/libcdio/libcdio-0.93.tar.gz"
  sha1 "bc3f599b0b77d8d186c0afc66495f721747c5293"

  bottle do
    cellar :any
    revision 1
    sha1 "d873d37cdcd905a525e2595be1ea06b1c33d1530" => :yosemite
    sha1 "70bd8d87dbffab5e7ed4c725829fbac4a06ea0f2" => :mavericks
  end

  depends_on "pkg-config" => :build

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end
end
