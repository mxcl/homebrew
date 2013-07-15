require 'formula'

class Libplist < Formula
  homepage 'http://cgit.sukimashita.com/libplist.git/'
  url 'http://cgit.sukimashita.com/libplist.git/snapshot/libplist-1.10.tar.bz2'
  sha1 'a642bb37eaa4bec428d0b2a4fa8399d80ee73a18'

  head 'http://git.sukimashita.com/libplist.git'

  # Improve the default option descr. generated by `depends_on :python => :optional`
  option 'with-python', 'Enable Cython Python bindings'

  depends_on 'cmake' => :build
  depends_on :python => :optional
  depends_on 'Cython' => :python if build.with? 'python'

  def install
    ENV.deparallelize # make fails on an 8-core Mac Pro

    args = std_cmake_args

    # Disable Swig Python bindings
    args << "-DENABLE_SWIG='OFF'"

    if python do
      # For Xcode-only systems, the headers of system's python are inside of Xcode:
      args << "-DPYTHON_INCLUDE_DIR='#{python.incdir}'"
      # Cmake picks up the system's python dylib, even if we have a brewed one:
      args << "-DPYTHON_LIBRARY='#{python.libdir}/lib#{python.xy}.dylib'"
    end; else
      # Also disable Cython Python bindings if we're not building --with-python
      args << "-DENABLE_CYTHON='OFF'"
    end

    system "cmake", ".", "-DCMAKE_INSTALL_NAME_DIR=#{lib}", *args
    system "make install"
  end

  def caveats
    python.standard_caveats if python
  end
end
