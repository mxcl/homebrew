require 'formula'

class Qt5HeadDownloadStrategy < GitDownloadStrategy
  include FileUtils

  def support_depth?
    # We need to make a local clone so we can't use "--depth 1"
    false
  end

  def stage
    @clone.cd { reset }
    safe_system 'git', 'clone', @clone, '.'
    ln_s @clone, 'qt'
    safe_system './init-repository', '--mirror', "#{Dir.pwd}/"
    rm 'qt'
  end
end

class Qt5 < Formula
  homepage 'http://qt-project.org/'
  url 'http://download.qt-project.org/official_releases/qt/5.2/5.2.0/single/qt-everywhere-opensource-src-5.2.0.tar.gz'
  sha1 'd0374c769a29886ee61f08a6386b9af39e861232'
  head 'git://gitorious.org/qt/qt5.git', :branch => 'stable',
    :using => Qt5HeadDownloadStrategy

  bottle do
    revision 1
    sha1 '7cf5fec167c1b0d8a8a719fad79756b9892d04dd' => :mountain_lion
    sha1 '5d6a4a10362ba66d6471cd45a40b1bcde8137f62' => :lion
    sha1 'd1790e3b17b5a0855efa8df68187a62774aad9b9' => :snow_leopard
  end

  keg_only "Qt 5 conflicts Qt 4 (which is currently much more widely used)."

  option :universal
  option 'with-docs', 'Build documentation'
  option 'developer', 'Build and link with developer options'

  depends_on "d-bus" => :optional
  depends_on "mysql" => :optional
  depends_on "icu4c" => :optional

  odie 'qt5: --with-qtdbus has been renamed to --with-d-bus' if build.include? 'with-qtdbus'
  odie 'qt5: --with-demos-examples is no longer supported' if build.include? 'with-demos-examples'
  odie 'qt5: --with-debug-and-release is no longer supported' if build.include? 'with-debug-and-release'

  def install
    ENV.universal_binary if build.universal?
    args = ["-prefix", prefix,
            "-system-zlib",
            "-confirm-license", "-opensource",
            "-nomake", "examples",
            "-release"]

    unless MacOS::CLT.installed?
      # ... too stupid to find CFNumber.h, so we give a hint:
      ENV.append 'CXXFLAGS', "-I#{MacOS.sdk_path}/System/Library/Frameworks/CoreFoundation.framework/Headers"
    end

    # https://bugreports.qt-project.org/browse/QTBUG-34382
    args << "-no-xcb"

    args << "-L#{MacOS::X11.lib}" << "-I#{MacOS::X11.include}" if MacOS::X11.installed?

    args << "-plugin-sql-mysql" if build.with? 'mysql'

    if build.with? 'd-bus'
      dbus_opt = Formula.factory('d-bus').opt_prefix
      args << "-I#{dbus_opt}/lib/dbus-1.0/include"
      args << "-I#{dbus_opt}/include/dbus-1.0"
      args << "-L#{dbus_opt}/lib"
      args << "-ldbus-1"
    end

    if build.with? 'icu4c'
      icu4c_prefix = Formula.factory('icu4c').opt_prefix
      args << "-icu"
      args << "-L#{icu4c_prefix}/lib"
      args << "-I#{icu4c_prefix}/include"
    end

    if MacOS.prefer_64_bit? or build.universal?
      args << '-arch' << 'x86_64'
    end

    if !MacOS.prefer_64_bit? or build.universal?
      args << '-arch' << 'x86'
    end

    args << '-developer-build' if build.include? 'developer'

    system "./configure", *args
    system "make"
    ENV.j1
    system "make install"

    # Some config scripts will only find Qt in a "Frameworks" folder
    cd prefix do
      ln_s lib, frameworks
    end

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob(lib + '*.framework/Headers').each do |path|
      framework_name = File.basename(File.dirname(path), '.framework')
      ln_s path.realpath, include+framework_name
    end

    Pathname.glob(bin + '*.app').each do |path|
      mv path, prefix
    end
  end

  test do
    system "#{bin}/qmake", "-project"
  end

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end
end
