require 'formula'

class Trafshow < Formula
  homepage 'http://soft.risp.ru/trafshow/index_en.shtml'
  url 'ftp://ftp.FreeBSD.org/pub/FreeBSD/ports/distfiles/trafshow-5.2.3.tgz'
  sha1 '1c68f603f12357e932c83de850366c9b46e53d89'

  depends_on :libtool

  {
    "domain_resolver.c" => "1e7b470e65ed5df0a5ab2b8c52309d19430a6b9b",
    "colormask.c"       => "25086973e067eb205b67c63014b188af3b3477ab",
    "trafshow.c"        => "3a7f7e1cd740c8f027dee7e0d5f9d614b83984f2",
    "trafshow.1"        => "99c1d930049b261a5848c34b647d21e6980fa671",
    "configure"         => "94e9667a86f11432e3458fae6acc593db75936b5",
  }.each do |name, sha|
    patch :p0 do
      url "https://trac.macports.org/export/68507/trunk/dports/net/trafshow/files/patch-#{name}"
      sha1 sha
    end
  end

  def copy_libtool_files!
    if not MacOS::Xcode.provides_autotools?
      s = Formula['libtool'].share
      d = "#{s}/libtool/config"
      cp ["#{d}/config.guess", "#{d}/config.sub"], "."
    elsif MacOS.version <= :leopard
      cp Dir["#{MacOS::Xcode.prefix}/usr/share/libtool/config.*"], "."
    else
      cp Dir["#{MacOS::Xcode.prefix}/usr/share/libtool/config/config.*"], "."
    end
  end

  def install
    copy_libtool_files!
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-slang"
    system "make"

    bin.install "trafshow"
    man1.install "trafshow.1"
    etc.install ".trafshow" => "trafshow.default"
  end
end
