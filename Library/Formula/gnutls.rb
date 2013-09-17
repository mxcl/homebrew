require 'formula'

class Gnutls < Formula
  homepage 'http://gnutls.org'
  url 'ftp://ftp.gnutls.org/gcrypt/gnutls/v3.1/gnutls-3.1.10.tar.xz'
  sha1 '1097644b0e58754217c4f9edbdf68e9f7aa7e08d'
  
  option 'with-guile', 'Build with Guile bindings'

  depends_on 'xz' => :build
  depends_on 'pkg-config' => :build
  depends_on 'libtasn1'
  depends_on 'p11-kit'
  depends_on 'nettle'
  depends_on 'guile' => :optional

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end
  
  def patches
    # quick and dirty fix for the incorrect
    # --with-guile-site-dir option being generated
    # by configure.ac 
    DATA
  end

  def install
    args = %W[
            --disable-dependency-tracking
             --disable-static
             --prefix=#{prefix}
           ]
    
    if build.with? 'guile'
      args << '--enable-guile'
      args << '--with-guile-site-dir=no'
    end

    system "./configure", *args
    system "make install"

    # certtool shadows the OS X certtool utility
    mv bin+'certtool', bin+'gnutls-certtool'
    mv man1+'certtool.1', man1+'gnutls-certtool.1'
  end
end

__END__
diff --git a/configure b/configure
index 92c8fdc..1b5293e 100755
--- a/configure
+++ b/configure
@@ -2084,7 +2084,7 @@ with_default_trust_store_pkcs11
 with_default_trust_store_file
 with_default_crl_file
 enable_guile
-with___with_guile_site_dir
+with_guile_site_dir
 enable_crywrap
 '
       ac_precious_vars='build_alias
@@ -56433,8 +56433,8 @@ $as_echo "$opt_guile_bindings" >&6; }
 
 
 # Check whether --with---with-guile-site-dir was given.
-if test "${with___with_guile_site_dir+set}" = set; then :
-  withval=$with___with_guile_site_dir;
+if test "${with_guile_site_dir+set}" = set; then :
+  withval=$with_guile_site_dir;
 fi
 
 

