require "formula"

class Chinadns < Formula
  homepage "https://github.com/clowwindy/ChinaDNS-C"
  url "https://github.com/clowwindy/ChinaDNS-C/releases/download/1.1.8/chinadns-c-1.1.8.tar.gz"
  sha1 "e712aab436e555a242f6c3c8acd7474b0b445bf1"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
