require 'formula'

class GitManuals < Formula
  url 'http://git-core.googlecode.com/files/git-manpages-1.8.1.4.tar.gz'
  sha1 '98c41b38d02f09e1fcde335834694616d0a615f7'
end

class GitHtmldocs < Formula
  url 'http://git-core.googlecode.com/files/git-htmldocs-1.8.1.4.tar.gz'
  sha1 'bb71df6bc1fdb55b45c59af83102e901d484ef53'
end

class Git < Formula
  homepage 'http://git-scm.com'
  url 'http://git-core.googlecode.com/files/git-1.8.1.4.tar.gz'
  sha1 '553191fe02cfac77386d5bb01df0a79eb7f163c8'

  head 'https://github.com/git/git.git'

  option 'with-blk-sha1', 'Compile with the block-optimized SHA1 implementation'

  depends_on 'pcre' => :optional

  def install
    # If these things are installed, tell Git build system to not use them
    ENV['NO_FINK'] = '1'
    ENV['NO_DARWIN_PORTS'] = '1'
    ENV['V'] = '1' # build verbosely
    ENV['NO_R_TO_GCC_LINKER'] = '1' # pass arguments to LD correctly
    ENV['NO_GETTEXT'] = '1'
    ENV['PERL_PATH'] = which 'perl' # workaround for users of perlbrew
    ENV['PYTHON_PATH'] = which 'python' # python can be brewed or unbrewed

    # Clean XCode 4.x installs don't include Perl MakeMaker
    ENV['NO_PERL_MAKEMAKER'] = '1' if MacOS.version >= :lion

    ENV['BLK_SHA1'] = '1' if build.include? 'with-blk-sha1'

    if build.with? 'pcre'
      ENV['USE_LIBPCRE'] = '1'
      ENV['LIBPCREDIR'] = HOMEBREW_PREFIX
    end

    system "make", "prefix=#{prefix}",
                   "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "LDFLAGS=#{ENV.ldflags}",
                   "install"

    # Install the OS X keychain credential helper
    cd 'contrib/credential/osxkeychain' do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install 'git-credential-osxkeychain'
      system "make", "clean"
    end

    # Install git-subtree
    cd 'contrib/subtree' do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install 'git-subtree'
    end

    # install the completion script first because it is inside 'contrib'
    bash_completion.install 'contrib/completion/git-completion.bash'
    bash_completion.install 'contrib/completion/git-prompt.sh'

    zsh_completion.install 'contrib/completion/git-completion.zsh' => '_git'
    cp "#{bash_completion}/git-completion.bash", zsh_completion

    (share+'git-core').install 'contrib'

    # We could build the manpages ourselves, but the build process depends
    # on many other packages, and is somewhat crazy, this way is easier.
    GitManuals.new.brew { man.install Dir['*'] }
    GitHtmldocs.new.brew { (share+'doc/git-doc').install Dir['*'] }
  end

  def caveats; <<-EOS.undent
    The OS X keychain credential helper has been installed to:
      #{HOMEBREW_PREFIX}/bin/git-credential-osxkeychain

    The 'contrib' directory has been installed to:
      #{HOMEBREW_PREFIX}/share/git-core/contrib
    EOS
  end

  test do
    HOMEBREW_REPOSITORY.cd do
      `#{bin}/git ls-files -- bin`.chomp == 'bin/brew'
    end
  end
end
