require 'formula'

class Tinyscheme < Formula
  homepage 'http://tinyscheme.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/tinyscheme/tinyscheme/tinyscheme-1.40/tinyscheme-1.40.tar.gz'
  md5 '776c42ac5528d15e897ef052fa4b0420'
  version '1.40'

  def install
    system 'make', "INITDEST=#{share}"
    lib.install('libtinyscheme.dylib')
    share.install('init.scm')
    bin.install('scheme')
  end

  # Modify compile flags for Mac OS X
  def patches
    DATA
  end

end

__END__
--- a/makefile  2011-01-16 20:51:17.000000000 +1300
+++ b/makefile  2012-04-08 22:38:11.000000000 +1200
@@ -21,7 +21,7 @@
 CC = gcc -fpic
 DEBUG=-g -Wall -Wno-char-subscripts -O
 Osuf=o
-SOsuf=so
+SOsuf=dylib
 LIBsuf=a
 EXE_EXT=
 LIBPREFIX=lib
@@ -34,7 +34,6 @@
 LDFLAGS = -shared
 DEBUG=-g -Wno-char-subscripts -O
 SYS_LIBS= -ldl
-PLATFORM_FEATURES= -DSUN_DL=1
 
 # Cygwin
 #PLATFORM_FEATURES = -DUSE_STRLWR=0
@@ -50,8 +49,7 @@
 #LIBPREFIX = lib
 #OUT = -o $@
 
-FEATURES = $(PLATFORM_FEATURES) -DUSE_DL=1 -DUSE_MATH=0 -DUSE_ASCII_NAMES=0
-
+FEATURES = $(PLATFORM_FEATURES) -DUSE_DL=1 -DUSE_MATH=1 -DUSE_ASCII_NAMES=0 -DOSX -DInitFile="\"$(INITDEST)/init.scm"\"
 OBJS = scheme.$(Osuf) dynload.$(Osuf)
 
 LIBTARGET = $(LIBPREFIX)tinyscheme.$(SOsuf)
