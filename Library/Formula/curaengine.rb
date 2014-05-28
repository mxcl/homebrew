require "formula"

class Curaengine < Formula
  homepage "https://github.com/Ultimaker/CuraEngine"
  head "https://github.com/Ultimaker/CuraEngine.git"
  url "https://github.com/Ultimaker/CuraEngine/archive/14.03.tar.gz"
  sha1 "d782c90d6e66580cc7e4b43a013da399e4623259"

  def install
    ENV.deparallelize
    system "make"
    # Newer version compile to build, older versions compile to bin
    bin.install(build.head? ? "build/CuraEngine" : "CuraEngine")
  end
end
