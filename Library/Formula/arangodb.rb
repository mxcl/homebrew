class Arangodb < Formula
  desc "Universal open-source database with a flexible data model"
  homepage "https://www.arangodb.com/"
  url "https://www.arangodb.com/repositories/Source/ArangoDB-2.7.1.tar.gz"
  sha256 "a0f5cb20bdfa9750f43ee57a559a370a22bfc3f184a9d6d2d30d0bdadf639e12"

  head "https://github.com/arangodb/arangodb.git", :branch => "unstable"

  bottle do
    sha256 "a852b207a9c663c1b4903a76bf437c2a83422fb27d2d93af5e937aac119290a9" => :el_capitan
    sha256 "1ead12d5e6564047bd1c9768523740ed2fc04bf30f42ab7e0ded116043e17b24" => :yosemite
    sha256 "ac672a3d934e92923dd7c72e5c0422f9f3fc778302f62662c7b2bd35875b90af" => :mavericks
  end

  depends_on "go" => :build
  depends_on "openssl"

  needs :cxx11

  fails_with :clang do
    build 600
    cause "Fails with compile errors"
  end

  def install
    # clang on 10.8 will still try to build against libstdc++,
    # which fails because it doesn't have the C++0x features
    # arangodb requires.
    ENV.libcxx

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-relative
      --datadir=#{share}
      --localstatedir=#{var}
    ]

    args << "--program-suffix=-unstable" if build.head?

    system "./configure", *args
    system "make", "install"

    (var/"arangodb").mkpath
    (var/"log/arangodb").mkpath
  end

  def post_install
    system "#{sbin}/arangod" + (build.head? ? "-unstable" : ""), "--upgrade", "--log.file", "-"
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/arangodb/sbin/arangod" + (build.head? ? "-unstable" : "") + " --log.file -"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/arangod</string>
          <string>-c</string>
          <string>#{etc}/arangodb/arangod.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end
end
