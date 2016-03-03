class Cegui < Formula
  desc "provides windowing and widget toolkits for GL and other APIs"
  homepage "http://cegui.org.uk/"
  url "https://bitbucket.org/cegui/cegui/get/v0-8-4.tar.gz"
  version "0.8.4"
  sha256 "a435a170e3ca6cca4a32ce369e12d803757264dd0d064935d7b9b4f69c8832a8"

  head "https://bitbucket.org/cegui/cegui", :using => :hg, :branch => "v0-8"

  depends_on "cmake" => :build
  depends_on "glm" => :build
  depends_on "glew"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "pcre"

  def install
    # TODO: Enable fribidi after build problems are fixed
    args = std_cmake_args
    args << "-DCMAKE_OSX_SYSROOT=#{MacOS.sdk_path}"
    args << "-DCEGUI_SAMPLES_ENABLED=0"
    args << "-DCEGUI_USE_FRIBIDI=0"
    args << "-DCEGUI_BUILD_RENDERER_OPENGL3=1"
    args << "-DCEGUI_BUILD_PYTHON_MODULES=0"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <CEGUI/CEGUI.h>
      int main() {
        unsigned int vnum = 10000u * CEGUI::System::getMajorVersion()
                          +   100u * CEGUI::System::getMinorVersion()
                          +          CEGUI::System::getPatchVersion();

        if (804u > vnum) { return 1; }
      }
    EOS
    system ENV.cc, "test.cpp", "-I#{include}/cegui-0", "-L#{lib}", "-lCEGUIBase-0", "-o", "test"
    system "./test"
  end
end
