require "formula"

class Hevea < Formula
  homepage "http://hevea.inria.fr/"
  url "http://hevea.inria.fr/distri/hevea-2.21.tar.gz"
  sha1 "37a13c587f008d4376a7245c43beb52d567828dd"

  bottle do
    sha1 "85895fc6d991f57fe1a0e9ecbc083d335c7cf704" => :yosemite
    sha1 "d45bb32ad08211b304ae6c87f49727505ad81d33" => :mavericks
    sha1 "85d66fad38057feaa11c615dfdd7be4c921baca5" => :mountain_lion
  end

  depends_on "objective-caml"
  depends_on "ghostscript" => :optional

  def install
    ENV["PREFIX"] = prefix
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.tex").write <<-EOS.undent
      \\documentclass{article}
      \\begin{document}
      \\end{document}
    EOS
    system "#{bin}/hevea", "test.tex"
  end
end
