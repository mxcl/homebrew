class Uni2ascii < Formula
  homepage "http://billposer.org/Software/uni2ascii.html"
  url "http://billposer.org/Software/Downloads/uni2ascii-4.18.tar.gz"
  sha256 "9e24bb6eb2ced0a2945e2dabed5e20c419229a8bf9281c3127fa5993bfa5930e"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "MKDIRPROG='mkdir -p' make install"
  end

  test do
    # uni2ascii
    assert_equal "0x00E9", shell_output("printf é | #{bin}/uni2ascii -q")

    # ascii2uni
    assert_equal "é\n", shell_output("printf 0x00E9 | #{bin}/ascii2uni -q")
  end
end
