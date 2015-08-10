class Cmocka < Formula
  desc "Unit testing framework for C"
  homepage "https://cmocka.org/"
  url "https://cmocka.org/files/1.0/cmocka-1.0.1.tar.xz"
  mirror "https://mirrors.kernel.org/debian/pool/main/c/cmocka/cmocka_1.0.1.orig.tar.xz"
  sha256 "b36050d7a1224296803d216cba1a9d4c58c31bf308b2d6d6649d61aa5a36753b"

  bottle do
    sha1 "7ce09408d9d5d7b08c19dd7d483058c9fd6bd9fa" => :yosemite
    sha1 "d9f4f45dd1338eaf3b19d42fc3b5b88f538c997d" => :mavericks
    sha1 "4e365b5ba01862722e3d91e1c1cdc8d34c6e3e34" => :mountain_lion
  end

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", "-DUNIT_TESTING=On", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdarg.h>
      #include <stddef.h>
      #include <setjmp.h>
      #include <cmocka.h>

      static void null_test_success(void **state) {
        (void) state; /* unused */
      }

      int main(void) {
        const struct CMUnitTest tests[] = {
            cmocka_unit_test(null_test_success),
        };
        return cmocka_run_group_tests(tests, NULL, NULL);
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lcmocka", "-o", "test"
    system "./test"
  end
end
