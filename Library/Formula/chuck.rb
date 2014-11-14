require "formula"

class Chuck < Formula
  homepage "http://chuck.cs.princeton.edu/"
  url "http://chuck.cs.princeton.edu/release/files/chuck-1.3.4.0.tgz"
  sha1 "d32faae2cb60fc81d2716b477cf2d54bc548d9c6"

  # Homebrew already takes care of setting the sysroot;
  # also lets the build work on CLT.
  # Also fixes the version regex for 10.10+; reported to chuck-dev.
  patch :DATA

  def install
    system "make", "-C", "src", "osx"
    bin.install "src/chuck"
    (share/"chuck").install "examples"
  end
end

__END__
diff --git a/src/makefile.osx b/src/makefile.osx
index 4531ee1..65cee97 100644
--- a/src/makefile.osx
+++ b/src/makefile.osx
@@ -1,9 +1,7 @@
 # uncomment the following to force 32-bit compilation
 # FORCE_M32=-m32
 
-ifneq ($(shell sw_vers -productVersion | egrep '10\.[6789](\.[0-9]+)?'),)
-SDK=$(shell xcodebuild -sdk macosx -version | grep '^Path:' | sed 's/Path: \(.*\)/\1/')
-ISYSROOT=-isysroot $(SDK)
+ifneq ($(shell sw_vers -productVersion | egrep '10\.([6789]|1[0-9]+)(\.[0-9]+)?'),)
 LINK_EXTRAS=-F/System/Library/PrivateFrameworks \
     -weak_framework MultitouchSupport
 else
