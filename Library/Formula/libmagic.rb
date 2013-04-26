require 'formula'

class Libmagic < Formula
  homepage 'http://www.darwinsys.com/file/'
  url 'ftp://ftp.astron.com/pub/file/file-5.13.tar.gz'
  mirror 'http://fossies.org/unix/misc/file-5.13.tar.gz'
  sha1 '927651df90ead6b3e036e243109137c7d42c4fb6'

  option "with-python", "Build Python bindings."

  # Fixed upstream, should be in next release
  # See http://bugs.gw.com/view.php?id=230
  def patches; DATA; end if MacOS.version < :lion

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-fsect-man5"
    system "make install"

    # Don't dupe this system utility
    rm bin/"file"
    rm man1/"file.1"

    # Check for building python bindings
    build_python = build.include? "with-python"
    cd "python" do
      # In order to install into the Cellar, the dir must exist and be in the PYTHONPATH.
      temp_site_packages = lib/which_python/'site-packages'
      mkdir_p temp_site_packages
      ENV['PYTHONPATH'] = temp_site_packages

      args = [
        "--no-user-cfg",
        "--verbose",
        "install",
        "--force",
        "--install-scripts=#{bin}",
        "--install-lib=#{temp_site_packages}",
        "--install-data=#{share}",
        "--install-headers=#{include}",
      ]
      system "python", "setup.py", *args
    end if build_python

  end

 def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end

__END__
diff --git a/src/getline.c b/src/getline.c
index e3c41c4..74c314e 100644
--- a/src/getline.c
+++ b/src/getline.c
@@ -76,7 +76,7 @@ getdelim(char **buf, size_t *bufsiz, int delimiter, FILE *fp)
  }
 }
 
-ssize_t
+public ssize_t
 getline(char **buf, size_t *bufsiz, FILE *fp)
 {
  return getdelim(buf, bufsiz, '\n', fp);
