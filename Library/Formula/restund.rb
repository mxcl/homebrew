require "formula"

class Restund < Formula
  homepage "http://www.creytiv.com"
  url "http://www.creytiv.com/pub/restund-0.4.11.tar.gz"
  sha1 "7fb98e6d8dd5e48b62f5ad23d3dc5ee6546f8c15"

  depends_on "libre"

  patch :p0 do
    url "http://www.creytiv.com/tmp/restund-homebrew.patch"
    sha1 "a7ddaf0da0396e50ffe40552eeab5436b3141180"
  end

  def install
    libre = Formula["libre"]
    system "make", "install", "PREFIX=#{prefix}",
                              "LIBRE_MK=#{libre.opt_share}/re/re.mk",
                              "LIBRE_INC=#{libre.opt_include}/re",
                              "LIBRE_SO=#{libre.opt_lib}"
    system "make", "config", "DESTDIR=#{prefix}",
                              "PREFIX=#{prefix}",
                              "LIBRE_MK=#{libre.opt_share}/re/re.mk",
                              "LIBRE_INC=#{libre.opt_include}/re",
                              "LIBRE_SO=#{libre.opt_lib}"
  end

  test do
    system "#{sbin}/restund", "-tdnf", "#{etc}/restund.conf"
  end
end
