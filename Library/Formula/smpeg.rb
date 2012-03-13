require 'formula'

class Smpeg < Formula
  head 'svn://svn.icculus.org/smpeg/trunk'
  homepage 'http://icculus.org/smpeg/'

  depends_on 'pkg-config' => :build
  depends_on 'sdl'

  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-gtktest",
                          "--disable-sdltest"
    system "make"
    lib.install Dir[".libs/*.dylib"]
    bin.install ".libs/plaympeg"
    bin.install "./smpeg-config"
    include.install Dir["*.h"]
  end
end
