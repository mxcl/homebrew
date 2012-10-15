require 'formula'

class Puf < Formula
  url 'http://downloads.sourceforge.net/project/puf/puf/1.0.0/puf-1.0.0.tar.gz'
  homepage 'http://puf.sourceforge.net/'
  sha1 '2e804cf249faf29c58aac26933cfa10b437710c3'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--mandir=#{man}"
    system "make install"
  end
end
