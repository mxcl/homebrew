class Keybase < Formula
  desc "Command-line interface to Keybase.io"
  homepage "https://keybase.io/"
  url "https://github.com/keybase/client/archive/v1.0.1-0.tar.gz"
  sha256 "accb7a232ab3788034c3bd992e65a3152f3e675f1333462c93020c537efa0a6c"
  version "1.0.1-0"

  head "https://github.com/keybase/client.git"

  bottle do
    sha256 "0082c09c96cf19d1443723a5d91345547a4e6ce90d4139ec55ed017626bf0202" => :el_capitan
    sha256 "6f30a1b8f5d04fe767f42437852a4d3445624988f152c73dbf5a00d6bc4a2010" => :yosemite
    sha256 "3cfd77bd3ae34a93f200d9e0800b615b129bd8bd330d5d0d036743b2548bca14" => :mavericks
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GOBIN"] = buildpath
    ENV["GO15VENDOREXPERIMENT"] = "1"
    (buildpath/"src/github.com/keybase/client/").install "go"

    system "go", "build", "-a", "-tags", "production brew", "github.com/keybase/client/go/keybase"

    bin.install "keybase"
  end

  test do
    system "#{bin}/keybase", "-standalone", "id", "homebrew"
  end
end
