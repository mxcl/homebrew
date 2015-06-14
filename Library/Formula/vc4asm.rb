class Vc4asm < Formula
  desc "Macro assembler for Broadcom VideoCore IV aka Raspberry Pi GPU"
  homepage "http://maazl.de/project/vc4asm/doc/index.html"
  url "https://github.com/maazl/vc4asm/archive/V0.1.7.tar.gz"
  sha256 "db9c50c1cc035a183ce8305a82a01cad08a246d13c718c420a8762296b00e3de"

  depends_on "cmake" => :build

  needs :cxx11

  patch do
    url "https://github.com/maazl/vc4asm/pull/2.patch"
    sha256 "9b7996563a6b15ae7d5578df6d08b43413dc1758e8e2002115ba414daed323e3"
  end

  def install
    ENV.cxx11
    mkdir "build"
    cd "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.qasm").write <<-EOS.undent
      mov -, sacq(9)
      add r0, r4, ra1.unpack8b
      add.unpack8a r0, r4, ra1
      add r0, r4.8a, ra1
    EOS
    system "#{bin}/vc4asm", "-o test.hex", "-V", "#{share}/vc4.qinc", "test.qasm"
  end
end
