class Python < Formula
  desc "Interpreted, interactive, object-oriented programming language"
  homepage "https://www.python.org"
  head "https://hg.python.org/cpython", :using => :hg, :branch => "2.7"
  url "https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz"
  sha256 "eda8ce6eec03e74991abb5384170e7c65fcd7522e409b8e83d7e6372add0f12a"
  revision 2

  bottle do
    revision 3
    sha256 "ccba730727091bd73020348787077b224bfd93272ea5c8202ec3415e68c3351b" => :yosemite
    sha256 "3406eb398c7d89bdf670e2c53feecd54df981d2b5562f7bf6586ac7689e580db" => :mavericks
    sha256 "35c5e98031dbddf10cc02686e97c9cc8ca53429e1c299185303b49a8408516be" => :mountain_lion
  end

  # Please don't add a wide/ucs4 option as it won't be accepted.
  # More details in: https://github.com/Homebrew/homebrew/pull/32368
  option :universal
  option "with-quicktest", "Run `make quicktest` after the build (for devs; may fail)"
  option "with-tcl-tk", "Use Homebrew's Tk instead of OS X Tk (has optional Cocoa and threads support)"
  option "with-poll", "Enable select.poll, which is not fully implemented on OS X (https://bugs.python.org/issue5154)"

  deprecated_option "quicktest" => "with-quicktest"
  deprecated_option "with-brewed-tk" => "with-tcl-tk"

  depends_on "pkg-config" => :build
  depends_on "readline" => :recommended
  depends_on "sqlite" => :recommended
  depends_on "gdbm" => :recommended
  depends_on "openssl"
  depends_on "homebrew/dupes/tcl-tk" => :optional
  depends_on :x11 if build.with?("tcl-tk") && Tab.for_name("homebrew/dupes/tcl-tk").with?("x11")

  skip_clean "bin/pip", "bin/pip-2.7"
  skip_clean "bin/easy_install", "bin/easy_install-2.7"

  resource "setuptools" do
    url "https://pypi.python.org/packages/source/s/setuptools/setuptools-18.0.1.tar.gz"
    sha256 "4d49c99fd51edf22baa997fb6105b07482feaebcb174b7d348a4307c29264b94"
  end

  resource "pip" do
    url "https://pypi.python.org/packages/source/p/pip/pip-7.1.0.tar.gz"
    sha256 "d5275ba3221182a5dd1b6bcfbfc5ec277fb399dd23226d6fa018048f7e0f10f2"
  end

  resource "wheel" do
    url "https://pypi.python.org/packages/source/w/wheel/wheel-0.24.0.tar.gz"
    sha256 "ef832abfedea7ed86b6eae7400128f88053a1da81a37c00613b1279544d585aa"
  end

  # Patch for pyport.h macro issue
  # https://bugs.python.org/issue10910
  # https://trac.macports.org/ticket/44288
  patch do
    url "https://bugs.python.org/file30805/issue10910-workaround.txt"
    sha256 "c075353337f9ff3ccf8091693d278782fcdff62c113245d8de43c5c7acc57daf"
  end

  # Patch to disable the search for Tk.framework, since Homebrew's Tk is
  # a plain unix build. Remove `-lX11`, too because our Tk is "AquaTk".
  patch :DATA if build.with? "tcl-tk"

  def lib_cellar
    prefix/"Frameworks/Python.framework/Versions/2.7/lib/python2.7"
  end

  def site_packages_cellar
    lib_cellar/"site-packages"
  end

  # The HOMEBREW_PREFIX location of site-packages.
  def site_packages
    HOMEBREW_PREFIX/"lib/python2.7/site-packages"
  end

  # setuptools remembers the build flags python is built with and uses them to
  # build packages later. Xcode-only systems need different flags.
  def pour_bottle?
    MacOS::CLT.installed?
  end

  def install
    if build.with? "poll"
      opoo "The given option --with-poll enables a somewhat broken poll() on OS X (https://bugs.python.org/issue5154)."
    end

    # Unset these so that installing pip and setuptools puts them where we want
    # and not into some other Python the user has installed.
    ENV["PYTHONHOME"] = nil
    ENV["PYTHONPATH"] = nil

    args = %W[
      --prefix=#{prefix}
      --enable-ipv6
      --datarootdir=#{share}
      --datadir=#{share}
      --enable-framework=#{frameworks}
      --without-ensurepip
    ]

    args << "--without-gcc" if ENV.compiler == :clang

    unless MacOS::CLT.installed?
      # Help Python's build system (setuptools/pip) to build things on Xcode-only systems
      # The setup.py looks at "-isysroot" to get the sysroot (and not at --sysroot)
      cflags = "CFLAGS=-isysroot #{MacOS.sdk_path}"
      ldflags = "LDFLAGS=-isysroot #{MacOS.sdk_path}"
      args << "CPPFLAGS=-I#{MacOS.sdk_path}/usr/include" # find zlib
      # For the Xlib.h, Python needs this header dir with the system Tk
      if build.without? "tcl-tk"
        cflags += " -I#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers"
      end
      args << cflags
      args << ldflags
    end

    # Avoid linking to libgcc https://code.activestate.com/lists/python-dev/112195/
    args << "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"

    # We want our readline and openssl! This is just to outsmart the detection code,
    # superenv handles that cc finds includes/libs!
    inreplace "setup.py" do |s|
      s.gsub! "do_readline = self.compiler.find_library_file(lib_dirs, 'readline')",
              "do_readline = '#{Formula["readline"].opt_lib}/libhistory.dylib'"
      s.gsub! "/usr/local/ssl", Formula["openssl"].opt_prefix
    end

    if build.universal?
      ENV.universal_binary
      args << "--enable-universalsdk=/" << "--with-universal-archs=intel"
    end

    # Allow sqlite3 module to load extensions:
    # https://docs.python.org/library/sqlite3.html#f1
    if build.with? "sqlite"
      inreplace("setup.py", 'sqlite_defines.append(("SQLITE_OMIT_LOAD_EXTENSION", "1"))', "")
    end

    # Allow python modules to use ctypes.find_library to find homebrew's stuff
    # even if homebrew is not a /usr/local/lib. Try this with:
    # `brew install enchant && pip install pyenchant`
    inreplace "./Lib/ctypes/macholib/dyld.py" do |f|
      f.gsub! "DEFAULT_LIBRARY_FALLBACK = [", "DEFAULT_LIBRARY_FALLBACK = [ '#{HOMEBREW_PREFIX}/lib',"
      f.gsub! "DEFAULT_FRAMEWORK_FALLBACK = [", "DEFAULT_FRAMEWORK_FALLBACK = [ '#{HOMEBREW_PREFIX}/Frameworks',"
    end

    if build.with? "tcl-tk"
      tcl_tk = Formula["homebrew/dupes/tcl-tk"].opt_prefix
      ENV.append "CPPFLAGS", "-I#{tcl_tk}/include"
      ENV.append "LDFLAGS", "-L#{tcl_tk}/lib"
    end

    system "./configure", *args

    # HAVE_POLL is "broken" on OS X. See:
    # https://trac.macports.org/ticket/18376
    # https://bugs.python.org/issue5154
    if build.without? "poll"
      inreplace "pyconfig.h", /.*?(HAVE_POLL[_A-Z]*).*/, '#undef \1'
    end

    system "make"

    ENV.deparallelize # installs must be serialized
    # Tell Python not to install into /Applications
    system "make", "install", "PYTHONAPPSDIR=#{prefix}"
    # Demos and Tools
    system "make", "frameworkinstallextras", "PYTHONAPPSDIR=#{share}/python"
    system "make", "quicktest" if build.include? "quicktest"

    # Symlink the pkgconfig files into HOMEBREW_PREFIX so they're accessible.
    (lib/"pkgconfig").install_symlink Dir["#{frameworks}/Python.framework/Versions/Current/lib/pkgconfig/*"]

    # Fixes setting Python build flags for certain software
    # See: https://github.com/Homebrew/homebrew/pull/20182
    # https://bugs.python.org/issue3588
    inreplace lib_cellar/"config/Makefile" do |s|
      s.change_make_var! "LINKFORSHARED",
        "-u _PyMac_Error $(PYTHONFRAMEWORKINSTALLDIR)/Versions/$(VERSION)/$(PYTHONFRAMEWORK)"
    end

    # Remove the site-packages that Python created in its Cellar.
    site_packages_cellar.rmtree

    (libexec/"setuptools").install resource("setuptools")
    (libexec/"pip").install resource("pip")
    (libexec/"wheel").install resource("wheel")
  end

  def post_install
    # Fix up the site-packages so that user-installed Python software survives
    # minor updates, such as going from 2.7.0 to 2.7.1:

    # Create a site-packages in HOMEBREW_PREFIX/lib/python2.7/site-packages
    site_packages.mkpath

    # Symlink the prefix site-packages into the cellar.
    site_packages_cellar.unlink if site_packages_cellar.exist?
    site_packages_cellar.parent.install_symlink site_packages

    # Write our sitecustomize.py
    rm_rf Dir["#{site_packages}/sitecustomize.py[co]"]
    (site_packages/"sitecustomize.py").atomic_write(sitecustomize)

    # Remove old setuptools installations that may still fly around and be
    # listed in the easy_install.pth. This can break setuptools build with
    # zipimport.ZipImportError: bad local file header
    # setuptools-0.9.5-py3.3.egg
    rm_rf Dir["#{site_packages}/setuptools*"]
    rm_rf Dir["#{site_packages}/distribute*"]
    rm_rf Dir["#{site_packages}/pip[-_.][0-9]*", "#{site_packages}/pip"]

    setup_args = ["-s", "setup.py", "--no-user-cfg", "install", "--force",
                  "--verbose",
                  "--single-version-externally-managed",
                  "--record=installed.txt",
                  "--install-scripts=#{bin}",
                  "--install-lib=#{site_packages}"]

    (libexec/"setuptools").cd { system "#{bin}/python", *setup_args }
    (libexec/"pip").cd { system "#{bin}/python", *setup_args }
    (libexec/"wheel").cd { system "#{bin}/python", *setup_args }

    # When building from source, these symlinks will not exist, since
    # post_install happens after linking.
    %w[pip pip2 pip2.7 easy_install easy_install-2.7 wheel].each do |e|
      (HOMEBREW_PREFIX/"bin").install_symlink bin/e
    end

    # Help distutils find brewed stuff when building extensions
    include_dirs = [HOMEBREW_PREFIX/"include", Formula["openssl"].opt_include]
    library_dirs = [HOMEBREW_PREFIX/"lib", Formula["openssl"].opt_lib]

    if build.with? "sqlite"
      include_dirs << Formula["sqlite"].opt_include
      library_dirs << Formula["sqlite"].opt_lib
    end

    if build.with? "tcl-tk"
      include_dirs << Formula["homebrew/dupes/tcl-tk"].opt_include
      library_dirs << Formula["homebrew/dupes/tcl-tk"].opt_lib
    end

    cfg = lib_cellar/"distutils/distutils.cfg"
    cfg.atomic_write <<-EOF.undent
      [install]
      prefix=#{HOMEBREW_PREFIX}

      [build_ext]
      include_dirs=#{include_dirs.join ":"}
      library_dirs=#{library_dirs.join ":"}
    EOF
  end

  def sitecustomize
    <<-EOF.undent
      # This file is created by Homebrew and is executed on each python startup.
      # Don't print from here, or else python command line scripts may fail!
      # <https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Homebrew-and-Python.md>
      import re
      import os
      import sys

      if sys.version_info[0] != 2:
          # This can only happen if the user has set the PYTHONPATH for 3.x and run Python 2.x or vice versa.
          # Every Python looks at the PYTHONPATH variable and we can't fix it here in sitecustomize.py,
          # because the PYTHONPATH is evaluated after the sitecustomize.py. Many modules (e.g. PyQt4) are
          # built only for a specific version of Python and will fail with cryptic error messages.
          # In the end this means: Don't set the PYTHONPATH permanently if you use different Python versions.
          exit('Your PYTHONPATH points to a site-packages dir for Python 2.x but you are running Python ' +
               str(sys.version_info[0]) + '.x!\\n     PYTHONPATH is currently: "' + str(os.environ['PYTHONPATH']) + '"\\n' +
               '     You should `unset PYTHONPATH` to fix this.')

      # Only do this for a brewed python:
      if os.path.realpath(sys.executable).startswith('#{rack}'):
          # Shuffle /Library site-packages to the end of sys.path and reject
          # paths in /System pre-emptively (#14712)
          library_site = '/Library/Python/2.7/site-packages'
          library_packages = [p for p in sys.path if p.startswith(library_site)]
          sys.path = [p for p in sys.path if not p.startswith(library_site) and
                                             not p.startswith('/System')]
          # .pth files have already been processed so don't use addsitedir
          sys.path.extend(library_packages)

          # the Cellar site-packages is a symlink to the HOMEBREW_PREFIX
          # site_packages; prefer the shorter paths
          long_prefix = re.compile(r'#{rack}/[0-9\._abrc]+/Frameworks/Python\.framework/Versions/2\.7/lib/python2\.7/site-packages')
          sys.path = [long_prefix.sub('#{site_packages}', p) for p in sys.path]

          # LINKFORSHARED (and python-config --ldflags) return the
          # full path to the lib (yes, "Python" is actually the lib, not a
          # dir) so that third-party software does not need to add the
          # -F/#{HOMEBREW_PREFIX}/Frameworks switch.
          try:
              from _sysconfigdata import build_time_vars
              build_time_vars['LINKFORSHARED'] = '-u _PyMac_Error #{opt_prefix}/Frameworks/Python.framework/Versions/2.7/Python'
          except:
              pass  # remember: don't print here. Better to fail silently.

          # Set the sys.executable to use the opt_prefix
          sys.executable = '#{opt_bin}/python2.7'
    EOF
  end

  def caveats; <<-EOS.undent
    Pip and setuptools have been installed. To update them
      pip install --upgrade pip setuptools

    You can install Python packages with
      pip install <package>

    They will install into the site-package directory
      #{site_packages}

    See: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Homebrew-and-Python.md
    EOS
  end

  test do
    # Check if sqlite is ok, because we build with --enable-loadable-sqlite-extensions
    # and it can occur that building sqlite silently fails if OSX's sqlite is used.
    system "#{bin}/python", "-c", "import sqlite3"
    # Check if some other modules import. Then the linked libs are working.
    system "#{bin}/python", "-c", "import Tkinter; root = Tkinter.Tk()"
    system bin/"pip", "list"
  end
end

__END__
diff --git a/setup.py b/setup.py
index 716f08e..66114ef 100644
--- a/setup.py
+++ b/setup.py
@@ -1810,9 +1810,6 @@ class PyBuildExt(build_ext):
         # Rather than complicate the code below, detecting and building
         # AquaTk is a separate method. Only one Tkinter will be built on
         # Darwin - either AquaTk, if it is found, or X11 based Tk.
-        if (host_platform == 'darwin' and
-            self.detect_tkinter_darwin(inc_dirs, lib_dirs)):
-            return

         # Assume we haven't found any of the libraries or include files
         # The versions with dots are used on Unix, and the versions without
@@ -1858,21 +1855,6 @@ class PyBuildExt(build_ext):
             if dir not in include_dirs:
                 include_dirs.append(dir)

-        # Check for various platform-specific directories
-        if host_platform == 'sunos5':
-            include_dirs.append('/usr/openwin/include')
-            added_lib_dirs.append('/usr/openwin/lib')
-        elif os.path.exists('/usr/X11R6/include'):
-            include_dirs.append('/usr/X11R6/include')
-            added_lib_dirs.append('/usr/X11R6/lib64')
-            added_lib_dirs.append('/usr/X11R6/lib')
-        elif os.path.exists('/usr/X11R5/include'):
-            include_dirs.append('/usr/X11R5/include')
-            added_lib_dirs.append('/usr/X11R5/lib')
-        else:
-            # Assume default location for X11
-            include_dirs.append('/usr/X11/include')
-            added_lib_dirs.append('/usr/X11/lib')

         # If Cygwin, then verify that X is installed before proceeding
         if host_platform == 'cygwin':
@@ -1897,9 +1879,6 @@ class PyBuildExt(build_ext):
         if host_platform in ['aix3', 'aix4']:
             libs.append('ld')

-        # Finally, link with the X11 libraries (not appropriate on cygwin)
-        if host_platform != "cygwin":
-            libs.append('X11')

         ext = Extension('_tkinter', ['_tkinter.c', 'tkappinit.c'],
                         define_macros=[('WITH_APPINIT', 1)] + defs,
