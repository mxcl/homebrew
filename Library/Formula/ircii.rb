class Ircii < Formula
  desc "IRC and ICB client"
  homepage "http://www.eterna.com.au/ircii/"
  url "http://ircii.warped.com/ircii-20150903.tar.bz2"
  sha256 "617502e17788d619510f3f5efc1217e6c9d3a55e8227ece591c56981b0901324"

  bottle do
    sha1 "a91d564a3a3241e6684785d0a3a7a256ee319def" => :yosemite
    sha1 "4691d4bbbe491b729af842870773b6d899a95433" => :mavericks
    sha1 "826c088f54ddcf68afabc989c1915beb3ee0265d" => :mountain_lion
  end

  depends_on "openssl"

  def install
    ENV.append "LIBS", "-liconv"
    system "./configure", "--prefix=#{prefix}",
                          "--with-default-server=irc.freenode.net",
                          "--enable-ipv6"
    system "make"
    ENV.deparallelize
    system "make", "install"
  end
end
