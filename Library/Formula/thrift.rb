require 'formula'

class Thrift < Formula
  homepage 'http://thrift.apache.org'
  head 'http://svn.apache.org/repos/asf/thrift/trunk'
  url 'http://www.apache.org/dyn/closer.cgi?path=thrift/0.7.0/thrift-0.7.0.tar.gz'
  md5 '7a57a480745eab3dd25e02f5d5cc3770'

  depends_on 'boost'

  def install
    # No reason for this step is known. On Lion at least the pkg.m4 doesn't
    # even exist. Turns out that it isn't needed on Lion either. Possibly it
    # isn't needed anymore at all but I can't test that.
    cp "/usr/X11/share/aclocal/pkg.m4", "aclocal" if MACOS_VERSION < 10.7

    system "./bootstrap.sh" if version == 'HEAD'

    # This is a known bug in Thrift 0.7
    system "chmod +x ./configure ./install*sh"

    # Language bindings try to install outside of Homebrew's prefix, so
    # omit them here. For ruby you can install the gem, and for Python
    # you can use pip or easy_install.
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--libdir=#{lib}",
                          "--without-haskell",
                          "--without-java",
                          "--without-python",
                          "--without-ruby",
                          "--without-perl",
                          "--without-php"
    ENV.j1
    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    Some bindings were not installed. You may like to do the following:

        gem install thrift
        easy_install thrift

    Perl and PHP bindings are a mystery someone should solve.
    EOS
  end
end
