require 'formula'

class Fwknop < Formula
  homepage 'http://www.cipherdyne.org/fwknop/'
  url 'http://www.cipherdyne.org/fwknop/download/fwknop-2.5.1.tar.bz2'
  sha1 '65bed25e9d7f4a7ccc3f15cab35b95a6f7b21873'

  # build from github/mrash/fwknop/master
  head do
    url 'https://github.com/mrash/fwknop.git'
    depends_on :automake
    depends_on :autoconf
  end

  # needed for gpg support
  depends_on 'gpgme' => :optional

  def install
    if build.head?
      system 'autoreconf', '-fvi'
      system 'autoconf'
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end

  def test
    system "#{bin}/fwknop", "--version"
  end
end
