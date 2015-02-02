class Metashell < Formula
  homepage "https://github.com/sabel83/metashell"
  url "https://github.com/sabel83/metashell/archive/v2.0.0.tar.gz"
  sha1 "4dec47b6ee32cdf179b2eb297c289b296d3fba8f"

  depends_on "cmake" => :build

  needs :cxx11

  def install
    ENV.cxx11
    # Build internal Clang
    mkdir "templight/build" do
      system "cmake", "../llvm", "-DLIBCLANG_BUILD_STATIC=ON", *std_cmake_args
      system "make", "clang"
      system "make", "libclang"
      system "make", "libclang_static"
    end

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.hpp").write <<-EOS.undent
      #include <boost/mpl/int.hpp>
      #include <boost/mpl/plus.hpp>
      using namespace boost::mpl;
      plus<int_<6>, int_<7>>::type
    EOS
    assert_match /mpl_::integral_c/, shell_output("cat #{testpath}/test.hpp | #{bin}/metashell")
  end
end
