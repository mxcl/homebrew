require 'formula'

class Gnutls < Formula
  homepage 'http://www.gnu.org/software/gnutls/gnutls.html'
  url 'ftp://ftp.gnu.org/gnu/gnutls/gnutls-2.12.3.tar.bz2'
  sha256 '9fb3dba10d3fa6c2817cd47260b4c39026c69128fb39fc5026f179b3672539d3'

  depends_on 'pkg-config' => :build
  depends_on 'libgcrypt'
  depends_on 'libtasn1' => :optional

  def patches
    # lib/configure.ac patched to remove dependency on inexistent zlib.pc 
    DATA
  end

  fails_with_llvm "Undefined symbols when linking", :build => "2326"

  def install
    ENV.universal_binary	# build fat so wine can use it
    system "autoreconf"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--disable-guile",
                          "--disable-static",
                          "--prefix=#{prefix}",
                          "--with-libgcrypt"
    system "make install"
  end
end

__END__
diff --git a/src/serv.c b/src/serv.c
index 0307b05..ecd8725 100644
--- a/src/serv.c
+++ b/src/serv.c
@@ -440,6 +440,7 @@ static const char DEFAULT_DATA[] =
  */
 #define tmp2 &http_buffer[strlen(http_buffer)], len-strlen(http_buffer)
 static char *
+#undef snprintf
 peer_print_info (gnutls_session_t session, int *ret_length,
		 const char *header)
 {
diff --git a/lib/configure.ac b/lib/configure.ac
index 84c31e9..8c41a36 100644
--- a/lib/configure.ac
+++ b/lib/configure.ac
@@ -80,13 +80,6 @@ else
  AC_MSG_RESULT(no)
 fi
 
-if test x$ac_zlib != xno; then
-  if test x$GNUTLS_REQUIRES_PRIVATE = x; then
-    GNUTLS_REQUIRES_PRIVATE="Requires.private: zlib"
-  else
-    GNUTLS_REQUIRES_PRIVATE="$GNUTLS_REQUIRES_PRIVATE , zlib"
-  fi
-fi
 AC_SUBST(GNUTLS_REQUIRES_PRIVATE)
 
 lgl_INIT

