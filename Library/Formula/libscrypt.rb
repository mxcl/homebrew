require "formula"

class Libscrypt < Formula
  homepage "https://lolware.net/libscrypt.html"
  url "https://github.com/technion/libscrypt/archive/v1.20.tar.gz"
  sha1 "e4d510038c593d404961edbc5822948a6b450610"

  bottle do
    cellar :any
    revision 1
    sha1 "9ab1c43f3a714d824fc8350202dbb48781c61ff0" => :yosemite
    sha1 "98da6b52ef80a84beba1d9decdbc8e2230ef5e51" => :mavericks
    sha1 "98248b6497ba04be1191c3fde0cc625849af052a" => :mountain_lion
  end

  def install
    system "make", "install-osx", "PREFIX=#{prefix}", "LDFLAGS=", "CFLAGS_EXTRA="
    system "make", "check", "LDFLAGS=", "CFLAGS_EXTRA="
  end
end
