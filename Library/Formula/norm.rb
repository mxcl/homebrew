class Norm < Formula
  desc "NACK-Oriented Reliable Multicast"
  homepage "https://www.nrl.navy.mil/itd/ncs/products/norm"
  url "https://downloads.pf.itd.nrl.navy.mil/norm/archive/src-norm-1.5r6.tgz"
  version "1.5r6"
  sha256 "20ea2e8dd5d5e1ff1ff91dc7dab6db53a77d7b7183d8cf2425c215fd294f22a7"

  bottle do
    cellar :any
    sha256 "ae2a33d4034fa0f3d4845c7269ab0f178725185be028198a4cb541865a9e595d" => :yosemite
    sha256 "52cf6e92bffd6f67e050172c7956f071c5e5d457db87dca957c30dd23bbf9704" => :mavericks
    sha256 "1dc0340c8f0fe4fb6360cf4763080987e62180cc454e09c1a6da587f950c4b7f" => :mountain_lion
  end

  def install
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf", "install"
    include.install "include/normApi.h"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <assert.h>
      #include <normApi.h>

      int main()
      {
        NormInstanceHandle i;
        i = NormCreateInstance(false);
        assert(i != NORM_INSTANCE_INVALID);
        NormDestroyInstance(i);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lnorm", "-o", "test"
    system "./test"
  end
end
