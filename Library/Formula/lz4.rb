require "formula"

class Lz4 < Formula
  homepage "http://code.google.com/p/lz4/"
  url "https://github.com/Cyan4973/lz4/archive/r126.tar.gz"
  sha1 "4e22222844b914f9f2878e9acf0ed1d9deca7f12"
  version "r126"

  bottle do
    cellar :any
    sha1 "be041935d4ae854cc7ba6a349ee03ff69175640b" => :yosemite
    sha1 "a6e13f4d00922ef0ced700b46050e530c5d4d1d6" => :mavericks
    sha1 "c94abe27367accdff36b91db1fdeabcd412abea2" => :mountain_lion
  end

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    input = "testing compression and decompression"
    input_file = testpath/"in"
    input_file.write input
    output_file = testpath/"out"
    system "sh", "-c", "cat #{input_file} | #{bin}/lz4 | #{bin}/lz4 -d > #{output_file}"
    assert_equal output_file.read, input
  end
end
