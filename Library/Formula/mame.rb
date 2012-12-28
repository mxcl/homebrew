require 'formula'

class Mame < Formula
  homepage 'http://mamedev.org/'
  url 'svn://dspnet.fr/mame/trunk', :revision => 17961
  version '0.147'
  head 'svn://dspnet.fr/mame/trunk'

  depends_on :x11
  depends_on 'sdl'

  def install
    ENV['MACOSX_USE_LIBSDL'] = '1'
    ENV['INCPATH'] = "-I./src/lib/util -I#{MacOS::X11.include}"
    ENV['PTR64'] = (MacOS.prefer_64_bit? ? '1' : '0')

    system 'unzip mame.zip'
    system 'make', 'TARGET=mame', 'SUBTARGET=mame'

    if MacOS.prefer_64_bit?
      bin.install 'mame64' => 'mame'
    else
      bin.install 'mame'
    end
  end
end
