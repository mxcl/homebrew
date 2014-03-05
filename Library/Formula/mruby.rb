require "formula"

class Mruby < Formula
  homepage "http://www.mruby.org"
  url "https://github.com/mruby/mruby/archive/1.0.0.zip"
  sha1 "48861f5e01019fd82da4543c01d163fc03ec4643"

  head "https://github.com/mruby/mruby.git"

  bottle do
    cellar :any
    sha1 "22bbdac4d6f903b24b1d79d64b311464fdd42161" => :mavericks
    sha1 "5076d06d254730a052d88b4a9b4b2d1f630a0449" => :mountain_lion
    sha1 "a88b7302f383dae1f9ca67a3fcbbd603841eec86" => :lion
  end

  depends_on "bison" => :build

  def install
    system "make"

    cd "build/host/" do
      lib.install Dir["lib/*.a"]
      prefix.install %w{bin mrbgems mrblib tools}
    end
  end

  test do
    system "#{bin}/mruby", "-e", "true"
  end
end
