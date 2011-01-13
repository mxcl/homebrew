require 'formula'

class Thrift <Formula
  homepage 'http://incubator.apache.org/thrift/'
  head 'http://svn.apache.org/repos/asf/incubator/thrift/trunk'
  url 'http://www.apache.org/dist/incubator/thrift/0.5.0-incubating/thrift-0.5.0.tar.gz'
  md5 '14c97adefb4efc209285f63b4c7f51f2'

  depends_on 'boost'

  def install
    cp "/usr/X11/share/aclocal/pkg.m4", "aclocal"
    system "./bootstrap.sh" if version == 'HEAD'

    # Language bindings try to install outside of Homebrew's prefix, so
    # omit them here. For ruby you can install the gem, and for Python
    # you can use pip or easy_install.
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--libdir=#{lib}",
                          "--without-python",
                          "--without-ruby",
                          "--without-perl",
                          "--without-php",
                          ## haskell requires some dependencies that I'm not qualified to figure out
                          "--without-haskell"
    ## there is a bug with dependency specification in the makefile in 0.5.0 the '-j 1' works around the issue
    system "make -j 1"
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
