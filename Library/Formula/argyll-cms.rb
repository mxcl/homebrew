class ArgyllCms < Formula
  desc "ICC compatible color management system"
  homepage "http://www.argyllcms.com/"
  url "http://www.argyllcms.com/Argyll_V1.7.0_src.zip"
  version "1.7.0"
  sha256 "dac51cf5d8f6d04bb02f2f5b119fa0e8b773a010e6377116768b082ef018f663"

  bottle do
    cellar :any
    sha1 "555b6383cdf85acd91a21dbff6d3aaaa2308c713" => :mavericks
    sha1 "02cbcdb8abcd0dc2534b8c54b8ebdcdb0ffc92e7" => :mountain_lion
    sha1 "716adfdabde0d81124ca57388655dc36e9e1c365" => :lion
  end

  depends_on "jam" => :build
  depends_on "jpeg"
  depends_on "libtiff"

  def install
    system "sh", "makeall.sh"
    system "./makeinstall.sh"
    rm "bin/License.txt"
    prefix.install "bin", "ref", "doc"
  end

  test do
    system bin/"targen", "-d", "0", "test.ti1"
    system bin/"printtarg", testpath/"test.ti1"
    %w[test.ti1.ps test.ti1.ti1 test.ti1.ti2].each { |f| File.exist? f }
  end
end
