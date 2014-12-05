require 'formula'

class Juju < Formula
  homepage 'https://juju.ubuntu.com'
  url 'https://launchpad.net/juju-core/1.20/1.20.14/+download/juju-core_1.20.14.tar.gz'
  sha1 'aca9765276c3c60c0c4d6c4b7a8d72d0ab3c5fcd'

  bottle do
    sha1 "ceaa0f001483c3cd4e25b62905293bb36d24c8ab" => :yosemite
    sha1 "ab9c19e731ec71e239a48f1ecbd46714c0626148" => :mavericks
    sha1 "f43b4e5a920ebf3c80d9fdef89a226fe9450b1a8" => :mountain_lion
  end

  depends_on 'go' => :build

  def install
    ENV["GOPATH"] = buildpath
    system "go", "build", "github.com/juju/juju/cmd/juju"
    system "go", "build", "github.com/juju/juju/cmd/plugins/juju-metadata"
    bin.install "juju", "juju-metadata"
    bash_completion.install "src/github.com/juju/juju/etc/bash_completion.d/juju-core"
  end

  test do
    system "#{bin}/juju", "version"
  end
end
