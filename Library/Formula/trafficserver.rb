require 'formula'

class Trafficserver < Formula
  url 'http://www.apache.org/dyn/closer.cgi/trafficserver/trafficserver-3.0.2.tar.bz2'
  homepage 'http://trafficserver.apache.org/'
  md5 '0f8e5ce658d28511001c6585d1e1813a'

  depends_on 'pcre'

  def install
    ENV.enable_warnings
    system "./configure", "--prefix=#{prefix}", "--with-user=#{ENV['USER']}", "--with-group=admin"
    system "make install"
  end

  def test
    system "trafficserver status"
  end
end
