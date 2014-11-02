require "formula"

class Acpica < Formula
  homepage "https://www.acpica.org/"
  head "https://github.com/acpica/acpica.git"
  url "https://acpica.org/sites/acpica/files/acpica-unix2-20140926.tar.gz"
  sha1 "f4a2c8e7afd7441e98b0878c1fff5ffaba2258bd"

  bottle do
    cellar :any
    sha1 "355fadcc05a553d6ce9e07ff3093c6656e9b3270" => :mavericks
    sha1 "fd2dfabd50acb1952273d7d8981737f65112359e" => :mountain_lion
    sha1 "f9969f8a4c60c82de1c1f51b96d32146e4f94a22" => :lion
  end

  def install
    ENV.deparallelize
    system "make", "HOST=_APPLE", "PREFIX=#{prefix}"
    system "make", "install", "HOST=_APPLE", "PREFIX=#{prefix}"
  end
end
