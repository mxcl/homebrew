require "formula"

class Fswatch < Formula
  homepage "https://github.com/alandipert/fswatch"
  url "https://github.com/alandipert/fswatch/archive/1.3.8.tar.gz"
  sha1 "a34383a4c3340ba9495186124b469762758c8b27"

  bottle do
    sha1 "9d0cd69f3ce150a94a5e5c90fecafdafae85fdef" => :mavericks
    sha1 "ad5b25ba07a8bc29a1c33ef359e5579170c562e5" => :mountain_lion
    sha1 "d04fd3d57dd593b93f012e37f0c457830b3acebb" => :lion
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  needs :cxx11

  def install
    ENV.cxx11
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules"
    system "make", "install"
  end
end
