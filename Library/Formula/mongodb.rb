require "language/go"

class Mongodb < Formula
  homepage "https://www.mongodb.org/"
  url "https://fastdl.mongodb.org/src/mongodb-src-r3.0.2.tar.gz"
  sha256 "010522203cdb9bbff52fbd9fe299b67686bb1256e2e55eb78abf35444f668399"

  bottle do
    sha256 "3761153651660207c145da9eac659c7b8ddaed879b44f6127c534d5f79e32f46" => :yosemite
    sha256 "f761d0e8d97fcc924c466165a6193c7c8169153b9afd33ca77b35bbb3a16b5e7" => :mavericks
    sha256 "7b212a87996b0e3cc9a9eddb180ec41bfbe9e056528c5f060029d94c18a8828a" => :mountain_lion
  end

  option "with-boost", "Compile using installed boost, not the version shipped with mongodb"

  depends_on "boost" => :optional
  depends_on "go" => :build
  depends_on :macos => :snow_leopard
  depends_on "scons" => :build
  depends_on "openssl" => :optional

  go_resource "github.com/mongodb/mongo-tools" do
    url "https://github.com/mongodb/mongo-tools.git",
      :tag => "r3.0.2",
      :revision => "a914adfcea7d76f07512415eec5cd8308e67318e"
  end

  def install
    Language::Go.stage_deps resources, buildpath/"src"

    cd "src/github.com/mongodb/mongo-tools" do
      args = %W[]
      # Once https://github.com/mongodb/mongo-tools/issues/11 is fixed, also set CPATH.
      # For now, use default include path
      #
      if build.with? "openssl"
        args << "ssl"
        ENV["LIBRARY_PATH"] = "#{Formula["openssl"].opt_prefix}/lib"
        # ENV["CPATH"] = "#{Formula["openssl"].opt_prefix}/include"
      end
      system "./build.sh", *args
    end

    mkdir "src/mongo-tools"
    cp Dir["src/github.com/mongodb/mongo-tools/bin/*"], "src/mongo-tools/"

    args = %W[
      --prefix=#{prefix}
      -j#{ENV.make_jobs}
      --cc=#{ENV.cc}
      --cxx=#{ENV.cxx}
      --osx-version-min=#{MacOS.version}
    ]

    args << "--use-system-boost" if build.with? "boost"
    args << "--use-new-tools"

    if build.with? "openssl"
      args << "--ssl" << "--extrapath=#{Formula["openssl"].opt_prefix}"
    end

    scons "install", *args

    (buildpath+"mongod.conf").write mongodb_conf
    etc.install "mongod.conf"

    (var+"mongodb").mkpath
    (var+"log/mongodb").mkpath
  end

  def mongodb_conf; <<-EOS.undent
    systemLog:
      destination: file
      path: #{var}/log/mongodb/mongo.log
      logAppend: true
    storage:
      dbPath: #{var}/mongodb
    net:
      bindIp: 127.0.0.1
    EOS
  end

  plist_options :manual => "mongod --config #{HOMEBREW_PREFIX}/etc/mongod.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/mongod</string>
        <string>--config</string>
        <string>#{etc}/mongod.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>HardResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>65536</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>65536</integer>
      </dict>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
