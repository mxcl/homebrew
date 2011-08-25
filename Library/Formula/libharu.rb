require 'formula'

class Libharu < Formula
  homepage 'http://www.libharu.org'
  url 'http://libharu.org/files/libharu-2.2.1.tar.bz2'
  md5 '4febd7e677b1c5d54db59a608b84e79f'

  def patches
    "http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/libharu/files/libharu-2.2.1-libpng-1.5.patch?revision=1.1"
  end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          # ENV.x11 doesn't get picked up
                          "--with-png=/usr/X11"
    system "make install"
  end
end
