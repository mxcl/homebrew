require 'formula'

class Mdbtools < Formula
  homepage 'http://sourceforge.net/projects/mdbtools/'
  # Use the github repo of the author instead of project CVS
  head "https://github.com/brianb/mdbtools.git"

  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on 'gawk' => :optional # To generate docs

  if MacOS.xcode_version >= "4.3"
    depends_on "automake"
    depends_on "libtool"
  end

  def install
    inreplace 'autogen.sh', 'libtool', 'glibtool'

    %w{src/libmdb/Makefile.am src/libmdb/Makefile.am src/sql/Makefile.am}.each do |f|
      inreplace f, /,?\s*--version-script=.*?(?:[ \t,]|$)/, ''
    end

    inreplace 'configure.in', /\s*--as-needed/, ''

    system "NOCONFIGURE='yes' ACLOCAL_FLAGS='-I#{HOMEBREW_PREFIX}/share/aclocal' ./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make install"
  end
end
