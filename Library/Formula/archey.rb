class Archey < Formula
  desc "Archey script for OS X"
  homepage "https://obihann.github.io/archey-osx/"
  url "https://github.com/obihann/archey-osx/archive/1.5.2.tar.gz"
  sha256 "01f58ea2f57fa5b23598590cee9b91dfac0b3402e7a9c4a781ff719be2388f1a"
  head "https://github.com/obihann/archey-osx.git"

  bottle :unneeded

  def install
    bin.install "bin/archey"
  end

  test do
    system "#{bin}/archey"
  end
end
