require "formula"

class Tcpreplay < Formula
  homepage "http://tcpreplay.appneta.com"
  url "https://github.com/appneta/tcpreplay/releases/download/v4.1.0/tcpreplay-4.1.0.tar.gz"
  sha1 "9723d82a0136d963bcc2665d562cb562d216a1c1"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-debug",
                          "--prefix=#{prefix}",
                          "--enable-dynamic-link"
    system "make", "install"
  end
end
