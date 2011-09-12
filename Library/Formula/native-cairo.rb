require 'formula'

class NativeCairo < Formula
  homepage 'http://cairographics.org/'
  url 'http://www.cairographics.org/releases/cairo-1.10.2.tar.gz'
  sha1 'ccce5ae03f99c505db97c286a0c9a90a926d3c6e'

  depends_on 'pkg-config' => :build
  depends_on 'pixman'

  keg_only :provided_by_osx,
            "The Cairo provided by Leopard is too old for newer software to link against."

  fails_with_llvm "Gives an LLVM ERROR with Xcode 4 on some CPUs"

  def install
    # Cairo doesn't build correctly with llvm-gcc 4.2, so force normal gcc.
    # See:
    # https://github.com/mxcl/homebrew/issues/6631
    # https://trac.macports.org/ticket/30370
    # https://trac.macports.org/browser/trunk/dports/graphics/cairo/Portfile
    ENV.gcc_4_2
    ENV.append 'CFLAGS', '-g3 -O0'
    ENV.append 'CXXFLAGS', '-g3 -O0'
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-quartz", "--enable-quartz-font", "--enable-quartz-image",
                          "--disable-xlib", "--disable-xcb", "--without-x",
                          # enable useful features
                          "--enable-ft", "--enable-pdf", "--enable-png", "--enable-ps", 
                          "--enable-script", "--enable-svg", "--enable-tee", "--enable-xml"
    system "make install"
  end
end
