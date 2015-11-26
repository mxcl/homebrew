class Gptfdisk < Formula
  desc "Text-mode partitioning tools"
  homepage "http://www.rodsbooks.com/gdisk/"
  url "https://downloads.sourceforge.net/project/gptfdisk/gptfdisk/1.0.1/gptfdisk-1.0.1.tar.gz"
  sha256 "864c8aee2efdda50346804d7e6230407d5f42a8ae754df70404dd8b2fdfaeac7"

  bottle do
    cellar :any
    sha256 "5fac6a86a0775f5ee1b964c424943f89a80fcb381020e2b2b9150e2027aa4696" => :el_capitan
    sha256 "5c8f8f714cd50ece24a4a126e2c28ca9d69874c04dd4dfc436f2d62a610c7dbc" => :yosemite
    sha256 "7925fc5b193566014430e59c2a109b557e46750f80555cd4b045b1447be1a282" => :mavericks
    sha256 "95593d9ce977a9529b11c9de8ee1089e56c67d76a642e13bdac31097aa5c7f69" => :mountain_lion
  end

  # Due to SIP
  depends_on MaximumMacOSRequirement => :yosemite

  depends_on "popt"
  depends_on "icu4c"

  def install
    inreplace "Makefile.mac", "/opt/local/lib/libncurses.a", "/usr/lib/libncurses.dylib"

    system "make", "-f", "Makefile.mac"
    sbin.install "gdisk", "cgdisk", "sgdisk", "fixparts"
    man8.install Dir["*.8"]
  end

  test do
    assert_match /GPT fdisk \(gdisk\) version #{Regexp.escape(version)}/,
                 pipe_output("#{sbin}/gdisk", "\n")
  end
end
