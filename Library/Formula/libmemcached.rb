require "formula"

class Libmemcached < Formula
  homepage "http://libmemcached.org"
  url "https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz"
  sha1 "8be06b5b95adbc0a7cb0f232e237b648caf783e1"

  bottle do
    cellar :any
    revision 1
    sha1 "abc6b08082ef18c8abb0df901063e88ee21fa82e" => :mavericks
    sha1 "a4da2082b38e15cd86dffd3f3b3c5b691dee1f90" => :mountain_lion
    sha1 "5029f4a7f05dd5f727b17617e49b424940c3def0" => :lion
  end

  option "with-sasl", "Build with sasl support"

  if build.with? "sasl"
    depends_on "memcached" => "enable-sasl"
  else
    depends_on "memcached"
  end

  # https://bugs.launchpad.net/libmemcached/+bug/1245562
  patch :DATA

  def install
    ENV.append_to_cflags "-undefined dynamic_lookup" if MacOS.version <= :leopard

    args = ["--prefix=#{prefix}"]

    if build.with? "sasl"
      args << "--with-memcached-sasl=#{Formula["memcached"].bin}/memcached"
    end

    system "./configure", *args
    system "make install"
  end
end

__END__
diff --git a/clients/memflush.cc b/clients/memflush.cc
index 8bd0dbf..cdba743 100644
--- a/clients/memflush.cc
+++ b/clients/memflush.cc
@@ -39,7 +39,7 @@ int main(int argc, char *argv[])
 {
   options_parse(argc, argv);
 
-  if (opt_servers == false)
+  if (*opt_servers != NULL)
   {
     char *temp;
 
@@ -48,7 +48,7 @@ int main(int argc, char *argv[])
       opt_servers= strdup(temp);
     }
 
-    if (opt_servers == false)
+    if (*opt_servers != NULL)
     {
       std::cerr << "No Servers provided" << std::endl;
       exit(EXIT_FAILURE);
diff --git a/example/byteorder.cc b/example/byteorder.cc
index fdfa021..8c03d35 100644
--- a/example/byteorder.cc
+++ b/example/byteorder.cc
@@ -42,27 +42,59 @@
 #include <example/byteorder.h>
 
 /* Byte swap a 64-bit number. */
-#ifndef swap64
-static inline uint64_t swap64(uint64_t in)
-{
-#ifndef WORDS_BIGENDIAN
-  /* Little endian, flip the bytes around until someone makes a faster/better
+#if !defined(htonll) && !defined(ntohll)
+#if __BYTE_ORDER == __LITTLE_ENDIAN
+# if defined(__FreeBSD__)
+#  include <sys/endian.h>
+#  define htonll(x) bswap64(x)
+#  define ntohll(x) bswap64(x)
+# elif defined(__APPLE__)
+#  include <libkern/OSByteOrder.h>
+#  define htonll(x) OSSwapInt64(x)
+#  define ntohll(x) OSSwapInt64(x)
+# elif defined(__OpenBSD__)
+#  include <sys/types.h>
+#  define htonll(x) swap64(x)
+#  define ntohll(x) swap64(x)
+# elif defined(__NetBSD__)
+#  include <sys/types.h>
+#  include <machine/bswap.h>
+#  if defined(__BSWAP_RENAME) && !defined(__bswap_32)
+#   define htonll(x) bswap64(x)
+#   define ntohll(x) bswap64(x)
+#  endif
+# elif defined(__sun) || defined(sun)
+#  include <sys/byteorder.h>
+#  define htonll(x) BSWAP_64(x)
+#  define ntohll(x) BSWAP_64(x)
+# elif defined(_MSC_VER)
+#  include <stdlib.h>
+#  define htonll(x) _byteswap_uint64(x)
+#  define ntohll(x) _byteswap_uint64(x)
+# else
+#  include <byteswap.h>
+#  ifndef bswap_64
+   /* Little endian, flip the bytes around until someone makes a faster/better
    * way to do this. */
-  uint64_t rv= 0;
-  for (uint8_t x= 0; x < 8; x++)
-  {
-    rv= (rv << 8) | (in & 0xff);
-    in >>= 8;
-  }
-  return rv;
+   static inline uint64_t bswap_64(uint64_t in)
+   {
+      uint64_t rv= 0;
+      for (uint8_t x= 0; x < 8; x++)
+      {
+        rv= (rv << 8) | (in & 0xff);
+        in >>= 8;
+      }
+      return rv;
+   }
+#  endif
+#  define htonll(x) bswap_64(x)
+#  define ntohll(x) bswap_64(x)
+# endif
 #else
-  /* big-endian machines don't need byte swapping */
-  return in;
-#endif // WORDS_BIGENDIAN
-}
+# define htonll(x) (x)
+# define ntohll(x) (x)
+#endif
 #endif
-
-#ifdef HAVE_HTONLL
 
 uint64_t example_ntohll(uint64_t value)
 {
@@ -73,17 +105,3 @@ uint64_t example_htonll(uint64_t value)
 {
   return htonll(value);
 }
-
-#else // HAVE_HTONLL
-
-uint64_t example_ntohll(uint64_t value)
-{
-  return swap64(value);
-}
-
-uint64_t example_htonll(uint64_t value)
-{
-  return swap64(value);
-}
-
-#endif // HAVE_HTONLL
diff --git a/libmemcached-1.0/memcached.h b/libmemcached-1.0/memcached.h
index bc16e73..dcee395 100644
--- a/libmemcached-1.0/memcached.h
+++ b/libmemcached-1.0/memcached.h
@@ -43,7 +43,11 @@
 #endif
 
 #ifdef __cplusplus
+#ifdef _LIBCPP_VERSION
 #  include <cinttypes>
+#else
+#  include <tr1/cinttypes>
+#endif
 #  include <cstddef>
 #  include <cstdlib>
 #else
diff --git a/libmemcached/byteorder.cc b/libmemcached/byteorder.cc
index 9f11aa8..f167822 100644
--- a/libmemcached/byteorder.cc
+++ b/libmemcached/byteorder.cc
@@ -39,41 +39,66 @@
 #include "libmemcached/byteorder.h"
 
 /* Byte swap a 64-bit number. */
-#ifndef swap64
-static inline uint64_t swap64(uint64_t in)
-{
-#ifndef WORDS_BIGENDIAN
-  /* Little endian, flip the bytes around until someone makes a faster/better
+#if !defined(htonll) && !defined(ntohll)
+#if __BYTE_ORDER == __LITTLE_ENDIAN
+# if defined(__FreeBSD__)
+#  include <sys/endian.h>
+#  define htonll(x) bswap64(x)
+#  define ntohll(x) bswap64(x)
+# elif defined(__APPLE__)
+#  include <libkern/OSByteOrder.h>
+#  define htonll(x) OSSwapInt64(x)
+#  define ntohll(x) OSSwapInt64(x)
+# elif defined(__OpenBSD__)
+#  include <sys/types.h>
+#  define htonll(x) swap64(x)
+#  define ntohll(x) swap64(x)
+# elif defined(__NetBSD__)
+#  include <sys/types.h>
+#  include <machine/bswap.h>
+#  if defined(__BSWAP_RENAME) && !defined(__bswap_32)
+#   define htonll(x) bswap64(x)
+#   define ntohll(x) bswap64(x)
+#  endif
+# elif defined(__sun) || defined(sun)
+#  include <sys/byteorder.h>
+#  define htonll(x) BSWAP_64(x)
+#  define ntohll(x) BSWAP_64(x)
+# elif defined(_MSC_VER)
+#  include <stdlib.h>
+#  define htonll(x) _byteswap_uint64(x)
+#  define ntohll(x) _byteswap_uint64(x)
+# else
+#  include <byteswap.h>
+#  ifndef bswap_64
+   /* Little endian, flip the bytes around until someone makes a faster/better
    * way to do this. */
-  uint64_t rv= 0;
-  for (uint8_t x= 0; x < 8; ++x)
-  {
-    rv= (rv << 8) | (in & 0xff);
-    in >>= 8;
-  }
-  return rv;
+   static inline uint64_t bswap_64(uint64_t in)
+   {
+      uint64_t rv= 0;
+      for (uint8_t x= 0; x < 8; x++)
+      {
+        rv= (rv << 8) | (in & 0xff);
+        in >>= 8;
+      }
+      return rv;
+   }
+#  endif
+#  define htonll(x) bswap_64(x)
+#  define ntohll(x) bswap_64(x)
+# endif
 #else
-  /* big-endian machines don't need byte swapping */
-  return in;
-#endif // WORDS_BIGENDIAN
-}
+# define htonll(x) (x)
+# define ntohll(x) (x)
+#endif
 #endif
-
 
 uint64_t memcached_ntohll(uint64_t value)
 {
-#ifdef HAVE_HTONLL
   return ntohll(value);
-#else
-  return swap64(value);
-#endif
 }
 
 uint64_t memcached_htonll(uint64_t value)
 {
-#ifdef HAVE_HTONLL
   return htonll(value);
-#else
-  return swap64(value);
-#endif
 }
