require "formula"

# Note that x.even are stable releases, x.odd are devel releases
class Libuv < Formula
  homepage "https://github.com/joyent/libuv"
  url "https://github.com/joyent/libuv/archive/v0.10.21.tar.gz"
  sha1 "883bb240d84e1db11b22b5b0dfdd117ed6bc6318"

  head do
    url "https://github.com/joyent/libuv.git", :branch => "master"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  devel do
    url "https://github.com/joyent/libuv/archive/v0.11.26.tar.gz"
    sha1 "907d0eb6c71731b112c94829c77255ed24ad2a0f"

    depends_on "pkg-config" => :build
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    if build.stable?
      system "make", "libuv.dylib"
      prefix.install "include"
      lib.install "libuv.dylib"
    else
      system "./autogen.sh"
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make", "install"
    end
  end
end
