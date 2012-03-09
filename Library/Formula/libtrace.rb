require 'formula'

class Libtrace < Formula
  url 'http://research.wand.net.nz/software/libtrace/libtrace-3.0.14.tar.bz2'
  homepage 'http://research.wand.net.nz/software/libtrace.php'
  md5 '277125db3f976e03b1b774b5607c890e'

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
