require 'formula'

class Xmlstarlet <Formula
  url 'http://downloads.sourceforge.net/project/xmlstar/xmlstarlet/1.0.1/xmlstarlet-1.0.1.tar.gz'
  md5 '8deb71834bcdfb4443c258a1f0042fce'
  homepage 'http://xmlstar.sourceforge.net/'

  def install
    # thanks, xmlstarlet but OS X doesn't have the static versions
    inreplace 'configure', '${LIBXML_PREFIX}/lib/libxml2.a', '-lxml2'
    inreplace 'configure', '${LIBXSLT_PREFIX}/lib/libxslt.a', '-lxslt'
    inreplace 'configure', '${LIBXSLT_PREFIX}/lib/libexslt.a', '-lexslt'

    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make"
    system "make install"
  end
end
