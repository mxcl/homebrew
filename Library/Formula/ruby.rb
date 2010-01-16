require 'formula'

# TODO de-version the include and lib directories

class Ruby <Formula
  @url='http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p376.tar.gz'
  @homepage='http://www.ruby-lang.org/en/'
  @md5='ebb20550a11e7f1a2fbd6fdec2a3e0a3'

  depends_on 'readline'
  
  def install
    ENV.gcc_4_2
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-shared"
    system "make"
    system "make install"
  end
  
  def caveats; <<-EOS
If you install gems with the RubyGems installed with this formula they will
to this formula's prefix. This needs to be fixed, as for example, upgrading
Ruby will lose all your gems.
    EOS
  end
  
  def skip_clean? path
    # TODO only skip the clean for the files that need it, we didn't get a
    # comment about why we're skipping the clean, so you'll need to figure
    # that out first --mxcl
    true
  end
end
