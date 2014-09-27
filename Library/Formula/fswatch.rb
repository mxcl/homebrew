require "formula"

class Fswatch < Formula
  homepage "https://github.com/emcrisostomo/fswatch"
  url "https://github.com/emcrisostomo/fswatch/releases/download/1.4.5/fswatch-1.4.5.zip"
  sha1 "3cd9b293713a855a13cbcbd6393d2444bcfdb65b"

  bottle do
    sha1 "af562b71444b74662878a118ba7fb7801b20efd7" => :mavericks
    sha1 "d83226f60c1aa3293810c191ac29062346b76e69" => :mountain_lion
    sha1 "0d1a6aaee16bf043aa2e0f6bb4448ee8c24846c4" => :lion
  end

  needs :cxx11

  def install
    ENV.cxx11
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules"
    system "make", "install"
  end
end
