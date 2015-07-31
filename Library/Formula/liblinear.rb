require 'formula'

class Liblinear < Formula
  desc "Library for large linear classification"
  homepage "http://www.csie.ntu.edu.tw/~cjlin/liblinear/"
  url "http://www.csie.ntu.edu.tw/~cjlin/liblinear/oldfiles/liblinear-2.01.tar.gz"
  sha256 "ebc71999224f5779574b11e248f1e2ef647b5d839c0380c1c5a4ac8789aa95a9"

  head "https://github.com/cjlin1/liblinear.git"

  bottle do
    cellar :any
    sha256 "9d1752ea126fc0b195c1502813645a462160442855bafe0e2545e007c39f84e8" => :yosemite
    sha256 "15c7d64502088e250f3b61089f276691c4b5a0bf3382663a3c24e2581a8e4bf8" => :mavericks
    sha256 "f6c2546bb3b2716c08c5acc80fcbb7b333460209db5c8debd9983c906d30e067" => :mountain_lion
  end

  # Fix sonames
  patch :p0 do
    url "https://trac.macports.org/export/94156/trunk/dports/math/liblinear/files/patch-Makefile.diff"
    sha1 "3eab2f28bd9964bacb515ecc1ce9bea35ad29298"
  end

  def install
    system "make", "all"
    bin.install "predict", "train"
    lib.install "liblinear.dylib"
    lib.install_symlink "liblinear.dylib" => "liblinear.1.dylib"
    include.install "linear.h"
  end
end
