require "formula"

class Mongodb < Formula
  homepage "https://www.mongodb.org/"

  stable do
    url "https://fastdl.mongodb.org/src/mongodb-src-r2.6.5.tar.gz"
    sha1 "f5a68505a0de1152b534d62a8f0147d258d503a0"

    # Review this patch with the next stable release.
    # Note it is a different patch to the one applied to all builds further below.
    # This is already fixed in the devel & HEAD builds.
    if MacOS.version == :yosemite
      patch do
        url "https://github.com/mongodb/mongo/commit/759b6e8.diff"
        sha1 "63d901ac81681fbe8b92dc918954b247990ab2fb"
      end
    end
  end

  bottle do
    revision 2
    sha1 "e6da509908fdacf9eb0f16e850e0516cd0898072" => :yosemite
    sha1 "5ab96fe864e725461eea856e138417994f50bb32" => :mavericks
    sha1 "193e639b7b79fbb18cb2e0a6bbabfbc9b8cbc042" => :mountain_lion
  end

  devel do
    # This can't be bumped past 2.7.7 until we decide what to do with
    # https://github.com/Homebrew/homebrew/pull/33652
    url "https://fastdl.mongodb.org/src/mongodb-src-r2.7.7.tar.gz"
    sha1 "ce223f5793bdf5b3e1420b0ede2f2403e9f94e5a"

    # Remove this with the next devel release. Already merged in HEAD.
    # https://github.com/mongodb/mongo/commit/8b8e90fb
    patch do
      url "https://github.com/mongodb/mongo/commit/8b8e90fb.diff"
      sha1 "9f9ce609c7692930976690cae68aa4fce1f8bca3"
    end
  end

  # Mongo HEAD now requires mongo-tools, and Golang
  # https://jira.mongodb.org/browse/SERVER-15806
  head do
    url "https://github.com/mongodb/mongo.git"

    depends_on "go" => :build
  end

  go_resource "github.com/mongodb/mongo-tools" do
     url "https://github.com/mongodb/mongo-tools.git", :tag => "2.7.8"
  end

  option "with-boost", "Compile using installed boost, not the version shipped with mongodb"

  depends_on "boost" => :optional
  depends_on :macos => :snow_leopard
  depends_on "scons" => :build
  depends_on "openssl" => :optional

  # Review this patch with each release.
  # This modifies the SConstruct file to include 10.10 as an accepted build option.
  if MacOS.version == :yosemite
    patch do
      url "https://raw.githubusercontent.com/DomT4/scripts/fbc0cda/Homebrew_Resources/Mongodb/mongoyosemite.diff"
      sha1 "f4824e93962154aad375eb29527b3137d07f358c"
    end
  end

  def install
    if build.head?
      Language::Go.stage_deps resources, buildpath/"src"
      ENV["GOPATH"] = "#{buildpath}:#{buildpath}/src/github.com/mongodb/mongo-tools/vendor"

      cd "src/github.com/mongodb/mongo-tools" do
       system "go", "build", "-o", "#{buildpath}/src/mongo-tools/bsondump", "#{buildpath}/src/github.com/mongodb/mongo-tools/bsondump/main/bsondump.go"
       system "go", "build", "-o", "#{buildpath}/src/mongo-tools/mongostat", "#{buildpath}/src/github.com/mongodb/mongo-tools/mongostat/main/mongostat.go"
       system "go", "build", "-o", "#{buildpath}/src/mongo-tools/mongofiles", "#{buildpath}/src/github.com/mongodb/mongo-tools/mongofiles/main/mongofiles.go"
       system "go", "build", "-o", "#{buildpath}/src/mongo-tools/mongoexport", "#{buildpath}/src/github.com/mongodb/mongo-tools/mongoexport/main/mongoexport.go"
       system "go", "build", "-o", "#{buildpath}/src/mongo-tools/mongoimport", "#{buildpath}/src/github.com/mongodb/mongo-tools/mongoimport/main/mongoimport.go"
       system "go", "build", "-o", "#{buildpath}/src/mongo-tools/mongorestore", "#{buildpath}/src/github.com/mongodb/mongo-tools/mongorestore/main/mongorestore.go"
       system "go", "build", "-o", "#{buildpath}/src/mongo-tools/mongodump", "#{buildpath}/src/github.com/mongodb/mongo-tools/mongodump/main/mongodump.go"
       system "go", "build", "-o", "#{buildpath}/src/mongo-tools/mongotop", "#{buildpath}/src/github.com/mongodb/mongo-tools/mongotop/main/mongotop.go"
       system "go", "build", "-o", "#{buildpath}/src/mongo-tools/mongooplog", "#{buildpath}/src/github.com/mongodb/mongo-tools/mongooplog/main/mongooplog.go"
      end
    end

    args = %W[
      --prefix=#{prefix}
      -j#{ENV.make_jobs}
      --cc=#{ENV.cc}
      --cxx=#{ENV.cxx}
      --osx-version-min=#{MacOS.version}
    ]

    # --full installs development headers and client library, not just binaries
    # (only supported pre-2.7)
    args << "--full" if build.stable?
    args << "--use-system-boost" if build.with? "boost"
    args << "--64" if MacOS.prefer_64_bit?

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
        <integer>1024</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
