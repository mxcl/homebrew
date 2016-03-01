class Rtorrent < Formula
  desc "Console-based BitTorrent client"
  homepage "https://github.com/rakshasa/rtorrent"
  url "http://rtorrent.net/downloads/rtorrent-0.9.6.tar.gz"
  sha256 "1e69c24f1f26f8f07d58d673480dc392bfc4317818c1115265b08a7813ff5b0e"

  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libtorrent"
  depends_on "xmlrpc-c" => :optional

  def install
    ENV.libstdcxx if ENV.compiler == :clang

    args = ["--disable-debug", "--disable-dependency-tracking", "--prefix=#{prefix}"]
    args << "--with-xmlrpc-c" if build.with? "xmlrpc-c"
    if MacOS.version <= :leopard
      inreplace "configure" do |s|
        s.gsub! '  pkg_cv_libcurl_LIBS=`$PKG_CONFIG --libs "libcurl >= 7.15.4" 2>/dev/null`',
          '  pkg_cv_libcurl_LIBS=`$PKG_CONFIG --libs "libcurl >= 7.15.4" | sed -e "s/-arch [^-]*/-arch $(uname -m) /" 2>/dev/null`'
      end
    end

    system "./configure", *args
    system "make"
    system "make", "install"

    doc.install "doc/rtorrent.rc"
  end

  test do
    ENV["TERM"] = "xterm"
    (testpath/"rtorrent.rc").write <<-EOF.undent
      schedule = close_rtorrent,1,1,"execute={killall,-TERM,rtorrent}"
    EOF
    system bin/"rtorrent", "-n", "-o", "import=rtorrent.rc"
  end
end
