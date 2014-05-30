require 'formula'

class Fleetctl < Formula
  homepage 'https://github.com/coreos/fleet'
  url 'https://github.com/coreos/fleet/archive/v0.4.0.tar.gz'
  sha1 '153dd05ae4c317051cab2921cda62784ee0d0521'
  head 'https://github.com/coreos/fleet.git'

  bottle do
    sha1 "96b02915f2b3f5ea32ccdb72776c6cac3232678f" => :mavericks
    sha1 "4156313fb8d0b37718c916a06002bf66f89302f0" => :mountain_lion
    sha1 "7aa84216b036219dfe2107812161d73cd0036596" => :lion
  end

  depends_on 'go' => :build

  def install
    ENV['GOPATH'] = buildpath
    system "./build"
    bin.install 'bin/fleetctl'
  end
end
