require 'formula'

# todo: Use graphite loop optimizations? (would depends_on 'cloog')

class Gfortran < Formula
  homepage 'http://gcc.gnu.org/wiki/GFortran'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.7.2/gcc-4.7.2.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gcc/gcc-4.7.2/gcc-4.7.2.tar.bz2'
  sha1 'a464ba0f26eef24c29bcd1e7489421117fb9ee35'

  bottle do
    sha1 '684879d100c02ac9ba5c23ded4860da19c02650d' => :mountainlion
    sha1 '3d958ffe0f126d1add6e2f5236b333870b1a826b' => :lion
    sha1 '9708ac5fa35db9789b8e050fbe410acee9ec9e45' => :snowleopard
  end

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'

  option 'enable-profiled-build', 'Make use of profile guided optimization when bootstrapping GCC'
  option 'check', 'Run the make check fortran. This is for maintainers.'

  begin
    depends_on 'dejagnu'
    depends_on 'expect'
  end if build.include? 'check'  # http://gcc.gnu.org/install/test.html

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      "fatal error: error in backend: ran out of registers during register allocation"

      If you have any knowledge to share or can provide a fix, please open an issue.
      Thanks!
      EOS
  end

  def install
    # Sandbox the GCC lib, libexec and include directories so they don't wander
    # around telling small children there is no Santa Claus. This results in a
    # partially keg-only brew following suggestions outlined in the "How to
    # install multiple versions of GCC" section of the GCC FAQ:
    #     http://gcc.gnu.org/faq.html#multiple
    gfortran_prefix = prefix/'gfortran'

    args = [
      # Sandbox everything...
      "--prefix=#{gfortran_prefix}",
      # ...except the stuff in share...
      "--datarootdir=#{share}",
      # ...and the binaries...
      "--bindir=#{bin}",
      "--with-system-zlib",
      # ...opt_prefix survives upgrades and works even if `brew unlink gmp`
      "--with-gmp=#{Formula.factory('gmp').opt_prefix}",
      "--with-mpfr=#{Formula.factory('mpfr').opt_prefix}",
      "--with-mpc=#{Formula.factory('libmpc').opt_prefix}",
      # ...we build the stage 1 gcc with clang (which is know to fail checks)
      "--enable-checking=release",
      "--disable-stage1-checking",
      # ...speed up build by ignoring cxx
      "--disable-build-poststage1-with-cxx",
      "--disable-libstdcxx-pc",
      # ...disable translations avoid conflict with brew install gcc --enable-nls
      '--disable-nls'
    ]

    mkdir 'build' do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # 'native-system-header's will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system '../configure', "--enable-languages=fortran", *args

      if build.include? 'enable-profiled-build'
        # Takes longer to build, may bug out. Provided for those who want to
        # optimise all the way to 11.
        system 'make profiledbootstrap'
      else
        system 'make bootstrap'
      end

      system "make"
      system "make check-fortran" if build.include? 'check'
      system 'make install'
    end

    # This package installs a whole GCC suite. Removing non-fortran components:
    bin.children.reject{ |p| p.basename.to_s.match(/gfortran/) }.each{ |p| rm p }
    man1.children.reject{ |p| p.basename.to_s.match(/gfortran/) }.each{ |p| rm p }
    man7.rmtree  # dupes: fsf fundraising and gpl will be added by gcc formula
    # (share/'locale').rmtree
  end

  def test
    mktemp do
      fixture = <<-EOS.undent
        integer,parameter::m=10000
        real::a(m), b(m)
        real::fact=0.5

        do concurrent (i=1:m)
          a(i) = a(i) + fact*b(i)
        end do
        print *, "done"
        end
      EOS
      Pathname('in.f90').write(fixture)
      system "#{bin}/gfortran -c in.f90"
      system "#{bin}/gfortran -o test in.o"
      `./test`.strip =='done'
    end
  end

  def caveats; <<-EOS.undent
    Brews that require a Fortran compiler should not use:
      depends_on 'gfortran'

    The preferred method of declaring Fortran support is to use:
      def install
        ...
        ENV.fortran
        ...
      end

    EOS
  end
end
