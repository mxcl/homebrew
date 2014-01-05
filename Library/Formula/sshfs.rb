require 'formula'

class Sshfs < Formula
  homepage 'http://osxfuse.github.io/'
  url 'https://github.com/osxfuse/sshfs/archive/osxfuse-sshfs-2.4.1.tar.gz'
  sha1 'cf614508db850a719529dec845ae59309f8a79c2'

  option 'without-sshnodelay', 'Don\'t compile NODELAY workaround for ssh'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on :libtool

  depends_on 'pkg-config' => :build
  depends_on 'osxfuse'
  depends_on 'glib'
  depends_on :xcode

  def patches
    "https://gist.github.com/denji/ce3c628d7def7f6ea490/raw/c441e0426dfb83decc0031ee54c48a8c22a35201/sshfs-fix.patch"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]
    args << "--disable-sshnodelay" if build.include? 'without-sshnodelay'

    # Compatibility with Automake 1.13 and newer.
    inreplace 'configure.ac', 'AM_CONFIG_HEADER', 'AC_CONFIG_HEADERS'
    inreplace 'configure.ac', 'AM_INIT_AUTOMAKE', 'AM_INIT_AUTOMAKE([subdir-objects])'

    system "autoreconf", "--force", "--install"
    system "./configure", *args
    system "make install"
  end

  def caveats; <<-EOS.undent
    Make sure to follow the directions given by `brew info osxfuse`
    before trying to use a FUSE-based filesystem.
    EOS
  end
end
