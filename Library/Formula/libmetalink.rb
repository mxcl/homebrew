require 'formula'

class Libmetalink < Formula
  homepage 'https://launchpad.net/libmetalink/'
  url 'https://launchpad.net/libmetalink/trunk/libmetalink-0.1.1/+download/libmetalink-0.1.1.tar.bz2'
  sha1 '261b9c5ec63f62c7dfa5a84fc280858005b14e20'
<<<<<<< HEAD
=======

  depends_on 'pkg-config' => :build
>>>>>>> 47c464115d9b205dd4c96bc02478fb38cfef3e26

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
