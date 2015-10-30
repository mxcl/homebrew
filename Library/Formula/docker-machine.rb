require "language/go"

class DockerMachine < Formula
  desc "Create Docker hosts locally and on cloud providers"
  homepage "https://docs.docker.com/machine"
  url "https://github.com/docker/machine/archive/v0.4.1.tar.gz"
  sha256 "f089657b2de7a3ce15374e69be3f654b0866f75eb077ca363f8a5933ccf51cda"
  head "https://github.com/docker/machine.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "1999548d84ddade819c21e6b6bc89f4590d20efed575a8996e9e87398afd3458" => :el_capitan
    sha256 "ec656857e23724204cb94cf6eea10feb887b9db0ae6027c751b95ae62e77d315" => :yosemite
    sha256 "4890545e0d50d8920394803313b95af81368414aa3a27f3fa16475e4fe9b69a7" => :mavericks
    sha256 "f282138ad3860b2b05c86f1a070c6fe3722220ea358c61ece16e8098b0798430" => :mountain_lion
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/docker/"
    ln_sf buildpath, buildpath/"src/github.com/docker/machine"
    Language::Go.stage_deps resources, buildpath/"src"

    system "make", "build"
    system "make", "install"
  end

  test do
    system bin/"docker-machine", "ls"
  end
end
