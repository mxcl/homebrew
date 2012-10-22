require 'formula'

class Cmatrix < Formula
  url 'http://www.asty.org/cmatrix/dist/cmatrix-1.2a.tar.gz'
  homepage 'http://www.asty.org/cmatrix/'
  sha1 'ca078c10322a47e327f07a44c9a42b52eab5ad93'

  def install
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make"
    system "make install"
  end
end
