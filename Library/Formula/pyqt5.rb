require 'formula'

class Pyqt5 < Formula
  homepage 'http://www.riverbankcomputing.co.uk/software/pyqt/download5'
  url 'https://downloads.sf.net/project/pyqt/PyQt5/PyQt-5.2.1/PyQt-gpl-5.2.1.tar.gz'
  sha1 '7d72ec27bfe547223b4b11db8a90603fe4796530'

  option 'enable-debug', "Build with debug symbols"

  depends_on :python3 => :recommended
  depends_on :python => :optional

  if build.without?("python3") && build.without?("python")
    odie "pyqt5: --with-python3 must be specified when using --without-python"
  end

  depends_on 'qt5'

  if build.with? 'python3'
    depends_on 'sip' => 'with-python3'
  else
    depends_on 'sip'
  end

  def install
    Language::Python.each_python(build) do |python, version|
      args = [ "--confirm-license",
               "--bindir=#{bin}",
               "--destdir=#{lib}/python#{version}/site-packages",
               # To avoid conflicts with PyQt (for Qt4):
               "--sipdir=#{share}/sip/Qt5/",
               # sip.h could not be found automatically
               "--sip-incdir=#{Formula["sip"].opt_include}",
               # Make sure the qt5 version of qmake is found.
               # If qt4 is linked it will pickup that version otherwise.
               "--qmake=#{Formula["qt5"].bin}/qmake",
               # Force deployment target to avoid libc++ issues
               "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}" ]
      args << '--debug' if build.include? 'enable-debug'

      system python, "configure.py", *args
      system "make"
      system "make", "install"
      system "make", "clean"
    end
    doc.install Dir['doc/html'], 'examples'
  end

  test do
    system "pyuic5", "--version"
    system "pylupdate5", "-version"
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import PyQt5"
    end
  end
end
