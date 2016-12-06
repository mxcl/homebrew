require 'formula'

class Nuttcp < Formula
  url 'ftp://ftp.lcp.nrl.navy.mil/pub/nuttcp/nuttcp-6.1.2.tar.bz2'
  homepage 'http://www.nuttcp.net/nuttcp/Welcome%20Page.html'
  md5 'a16d4d6d5def02cea980e57feaf30500'

  def install
    system 'make'
    bin.install 'nuttcp-6.1.2' => 'nuttcp'
    man8.install 'nuttcp.cat' => 'nuttcp.8'
  end
end
