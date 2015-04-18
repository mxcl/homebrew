require "formula"

class Npth < Formula
  homepage "https://gnupg.org/index.html"
  url "ftp://ftp.gnupg.org/gcrypt/npth/npth-1.2.tar.bz2"
  sha256 "6ddbdddb2cf49a4723f9d1ad6563c480d6760dcb63cb7726b8fc3bc2e1b6c08a"

  bottle do
    cellar :any
    sha1 "9c933c021a84a1fe71531f6deda2c368c0dc3e08" => :yosemite
    sha1 "8eedb70363bbdded692e29e8021527a17b6cfd17" => :mavericks
    sha1 "0fd048150a802f5a8f9f392faf7a55ed30eb60f7" => :mountain_lion
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/npth-config", "--version"
  end
end
