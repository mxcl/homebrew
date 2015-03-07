require 'formula'

class Libqglviewer < Formula
  homepage 'http://www.libqglviewer.com/'
  url 'http://www.libqglviewer.com/src/libQGLViewer-2.6.1.tar.gz'
  sha1 '9220b3f2b8629df36bf91cc8de397e65b2cab476'

  head 'https://github.com/GillesDebunne/libQGLViewer.git'

  bottle do
    cellar :any
    sha1 "874e8facfb89023da5b52fb380d0de0db83f0585" => :yosemite
    sha1 "8cd9c48486c8d244e5b8cffc113a825fb1dd0aa5" => :mavericks
    sha1 "f47da1b16cbbb6a5405e065a539daa356609f57d" => :mountain_lion
  end

  option :universal

  depends_on 'qt'

  # This patches makes the package install QGLViewer.framework under
  # #{lib}, where it will be picked by homebrew.
  # Patch has been submitted to the developer, check with versions
  # newer than 2.6.1 if this is still required.
  patch :DATA

  def install
    args = ["PREFIX=#{prefix}"]
    args << "CONFIG += x86 x86_64" if build.universal?

    cd 'QGLViewer' do
      system "qmake", *args
      system "make"
    end
  end
end

__END__
diff --git a/QGLViewer/QGLViewer.pro b/QGLViewer/QGLViewer.pro
index d805aa0..736a58f 100644
--- a/QGLViewer/QGLViewer.pro
+++ b/QGLViewer/QGLViewer.pro
@@ -240,26 +240,14 @@ macx|darwin-g++ {
	FRAMEWORK_HEADERS.path = Headers
	QMAKE_BUNDLE_DATA += FRAMEWORK_HEADERS

-	DESTDIR = $${HOME_DIR}/Library/Frameworks/
-
-	# For a Framework, 'include' and 'lib' do no make sense.
-	# These and prefix will all define the DESTDIR, in that order in case several are defined
-	!isEmpty( INCLUDE_DIR ) {
-	  DESTDIR = $${INCLUDE_DIR}
-	}
-
-	!isEmpty( LIB_DIR ) {
-	  DESTDIR = $${LIB_DIR}
-	}
-
-	!isEmpty( PREFIX ) {
-	  DESTDIR = $${PREFIX}
-	}
-
-	QMAKE_POST_LINK=cd $$DESTDIR/QGLViewer.framework/Headers && (test -L QGLViewer || ln -s . QGLViewer)
-
-	#QMAKE_LFLAGS_SONAME  = -Wl,-install_name,@executable_path/../Frameworks/
-	#QMAKE_LFLAGS_SONAME  = -Wl,-install_name,
+        !isEmpty( LIB_DIR ) {
+            DESTDIR = $${LIB_DIR}
+        }
+
+        # or to $${PREFIX}/lib otherwise
+        !isEmpty( PREFIX ) {
+            DESTDIR = $${PREFIX}/lib
+        }

	# Framework already installed, with includes
	INSTALLS -= include target
