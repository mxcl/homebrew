require 'formula'

def build_clang?; ARGV.include? '--with-clang'; end
def build_universal?; ARGV.include? '--universal'; end
def build_shared?; ARGV.include? '--shared'; end
def build_rtti?; ARGV.include? '--rtti'; end

class Clang <Formula
  url       'http://llvm.org/releases/2.8/clang-2.8.tgz'
  homepage  'http://llvm.org/'
  md5       '10e14c901fc3728eecbd5b829e011b59'
end

class Llvm <Formula
  url       'http://llvm.org/releases/2.8/llvm-2.8.tgz'
  homepage  'http://llvm.org/'
  md5       '220d361b4d17051ff4bb21c64abe05ba'

  def options
    [['--with-clang', 'Also build & install clang'],
     ['--shared', 'Build shared library'],
     ['--rtti', 'Build with RTTI information'],
     ['--universal', 'Build both i386 and x86_64 architectures']]
  end

  def install
    ENV.gcc_4_2 # llvm can't compile itself

    if build_shared? && build_universal?
      onoe "Cannot specify both shared and universal (will not build)"
      exit 1
    end

    if build_clang?
      clang_dir = Pathname.new(Dir.pwd)+'tools/clang'
      Clang.new.brew { clang_dir.install Dir['*'] }
    end

    if build_universal?
      ENV['UNIVERSAL'] = '1'
      ENV['UNIVERSAL_ARCH'] = 'i386 x86_64'
    end

    ENV['REQUIRES_RTTI'] = '1' if build_rtti?

    configure_options = ["--prefix=#{prefix}",
                         "--enable-targets=host-only",
                         "--enable-optimized"]

    configure_options << "--enable-shared" if build_shared?

    system "./configure", *configure_options

    system "make" # separate steps required, otherwise the build fails
    system "make install"

    if build_clang?
      Dir.chdir clang_dir do
        system "make install"
      end
    end
  end

  def caveats; <<-EOS
    If you already have LLVM installed, then "brew upgrade llvm" might not
    work. Instead, try:
        $ brew rm llvm
        $ brew install llvm
    EOS
  end
end
