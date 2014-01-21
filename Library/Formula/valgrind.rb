require 'formula'

class Valgrind < Formula
  homepage 'http://www.valgrind.org/'
  url 'http://valgrind.org/downloads/valgrind-3.9.0.tar.bz2'
  sha1 '9415e28933de9d6687f993c4bb797e6bd49583f1'
  depends_on 'automake' => :build
  depends_on 'autoconf' => :build
  depends_on 'libtool' => :build

  head do
    url 'svn://svn.valgrind.org/valgrind/trunk'
  end

  depends_on :macos => :snow_leopard

  # Valgrind needs vcpreload_core-*-darwin.so to have execute permissions.
  # See #2150 for more information.
  skip_clean 'lib/valgrind'

  def patches
    # 1: For Xcode-only systems, we have to patch hard-coded paths, use xcrun &
    #    add missing CFLAGS. See: https://bugs.kde.org/show_bug.cgi?id=295084
    # 2: Fix for 10.7.4 w/XCode-4.5, duplicate symbols. Reported upstream in
    #    https://bugs.kde.org/show_bug.cgi?id=307415
    # 3: Fix for 10.9 Mavericks, note that offically Mavericks is not supported
    #    by Valgrind 3.9.0, the patch is hacking way, but not a stable one.
    #    The patch comes from: https://bugs.kde.org/show_bug.cgi?id=326724#c12
    p = []
    p << 'https://gist.github.com/raw/3784836/f046191e72445a2fc8491cb6aeeabe84517687d9/patch1.diff' unless MacOS::CLT.installed?
    p << 'https://gist.github.com/raw/3784930/dc8473c0ac5274f6b7d2eb23ce53d16bd0e2993a/patch2.diff' if MacOS.version == :lion
    p << 'https://gist.github.com/mckelvin/8514475/raw/1939e5dfeb1dfc2974582f0dbbf5e3aaeb46d17a/valgrind-3.9.0-marericks.patch' if MacOS.version == :mavericks?
    return p
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]
    if MacOS.prefer_64_bit?
      args << "--enable-only64bit" << "--build=amd64-darwin"
    else
      args << "--enable-only32bit"
    end

    system "./autogen.sh" if build.head or MacOS.version == :mavericks?
    system "./configure", *args
    system "make"
    system "make install"
  end

  def test
    system "#{bin}/valgrind", "ls", "-l"
  end
end
