require 'formula'

class Libcld < Formula
  head 'git://github.com/mzsanford/cld.git', :tag => 'v0.1.1'
  url 'https://github.com/mzsanford/cld/tarball/v0.1.1'
  homepage 'https://github.com/mzsanford/cld'
  md5 'd8913e2acf594ea98d8988d1718cb732'
  version '0.1.1'


  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make check"
    system "make install"
  end

end

