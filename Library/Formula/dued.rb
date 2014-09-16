require "formula"

class Dued < Formula
  homepage "https://gist.github.com/unforswearing/2263f5223e46b647f955"
  url "https://gist.githubusercontent.com/unforswearing/2263f5223e46b647f955/raw/1de9add2f295c3b7bd6c5cadb6b8346916b98558/dued.rbp"
  sha1 "4109335a65cc2deb712c2cf526ff2dd93ef20db6"
  version "0.1"

  def install
    system "make"
    system "make", "install"
  end
end