require 'formula'

class Pil < Formula
  url 'http://effbot.org/downloads/Imaging-1.1.7.tar.gz'
  homepage 'http://www.pythonware.com/products/pil/'
  sha1 '76c37504251171fda8da8e63ecb8bc42a69a5c81'

  depends_on :x11
  depends_on 'jpeg' => :recommended
  depends_on 'little-cms' => :optional

  # The patch is to fix a core dump in Bug in PIL's quantize() with 64 bit architectures.
  def patches
    DATA
  end

  def install
    # Find the arch for the Python we are building against.
    # We remove 'ppc' support, so we can pass Intel-optimized CFLAGS.
    archs = archs_for_command("python")
    archs.remove_ppc!
    # Can't build universal on 32-bit hardware. See:
    # https://github.com/mxcl/homebrew/issues/5844
    archs.delete :x86_64 if Hardware.is_32_bit?
    ENV['ARCHFLAGS'] = archs.as_arch_flags

    inreplace "setup.py" do |s|
      # Tell setup where Freetype2 is on 10.5/10.6
      s.gsub! 'add_directory(include_dirs, "/sw/include/freetype2")',
              "add_directory(include_dirs, \"#{MacOS::X11.include}\")"

      s.gsub! 'add_directory(include_dirs, "/sw/lib/freetype2/include")',
              "add_directory(library_dirs, \"#{MacOS::X11.lib}\")"

      # Tell setup where our stuff is
      s.gsub! 'add_directory(library_dirs, "/sw/lib")',
              "add_directory(library_dirs, \"#{HOMEBREW_PREFIX}/lib\")"

      s.gsub! 'add_directory(include_dirs, "/sw/include")',
              "add_directory(include_dirs, \"#{HOMEBREW_PREFIX}/include\")"
    end

    system "python", "setup.py", "build_ext"
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end

  def caveats; <<-EOS.undent
    This formula installs PIL against whatever Python is first in your path.
    This Python needs to have either setuptools or distribute installed or
    the build will fail.
    EOS
  end
end

__END__
--- a/libImaging/Quant.c
+++ b/libImaging/Quant.c
@@ -914,7 +914,7 @@
    unsigned long bestdist,bestmatch,dist;
    unsigned long initialdist;
    HashTable h2;
-   int pixelVal;
+   unsigned long pixelVal;

    h2=hashtable_new(unshifted_pixel_hash,unshifted_pixel_cmp);
    for (i=0;i<nPixels;i++) {
