require 'formula'

class Podofo < Formula
  homepage 'http://podofo.sourceforge.net'
  url 'https://downloads.sourceforge.net/podofo/podofo-0.9.3.tar.gz'
  sha1 'e3b08af1266eb480032456e3bde030c75452d380'

  depends_on 'cmake' => :build
  depends_on 'libpng'
  depends_on 'freetype'
  depends_on 'fontconfig'
  depends_on 'jpeg'
  depends_on 'libtiff'

  def install
    mkdir 'build' do
      # Build shared to simplify linking for other programs.
      system "cmake", "..",
                      "-DPODOFO_BUILD_SHARED:BOOL=TRUE",
                      *std_cmake_args
      system "make install"
    end
  end
end
