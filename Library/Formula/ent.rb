require 'formula'

class Ent < Formula
  homepage 'http://www.fourmilab.ch/random/'
  url 'http://www.fourmilab.ch/random/random.zip'
  md5 '8104a83af1ea5b280da96c92da18eae4'
  version '1.0'

  def install
    # The Makefile only builds the binary, it must be installed manually
    system "make"
    bin.install "ent"

    # Used in the below test
    prefix.install "entest.mas"
    prefix.install "entitle.gif"
  end

  def test
    # Adapted from the test in the Makefile and entest.bat
    mktemp do
      system "#{bin}/ent #{prefix}/entitle.gif > entest.bak"
      # The single > here was also in entest.bat
      system "#{bin}/ent -c #{prefix}/entitle.gif > entest.bak"
      system "#{bin}/ent -fc #{prefix}/entitle.gif >> entest.bak"
      system "#{bin}/ent -b #{prefix}/entitle.gif >> entest.bak"
      system "#{bin}/ent -bc #{prefix}/entitle.gif >> entest.bak"
      system "#{bin}/ent -t #{prefix}/entitle.gif >> entest.bak"
      system "#{bin}/ent -ct #{prefix}/entitle.gif >> entest.bak"
      system "#{bin}/ent -ft #{prefix}/entitle.gif >> entest.bak"
      system "#{bin}/ent -bt #{prefix}/entitle.gif >> entest.bak"
      system "#{bin}/ent -bct #{prefix}/entitle.gif >> entest.bak"

      system "diff entest.bak #{prefix}/entest.mas"
    end
  end
end
