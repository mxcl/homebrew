require 'formula'

class Ssdb < Formula
  homepage "http://ssdb.io/?lang=en"
  url "https://github.com/ideawu/ssdb/archive/1.6.8.8.tar.gz"
  sha1 "2d63cb0ba176bf6c463a70e7a3b39f8cc326d5d7"

  head 'https://github.com/ideawu/ssdb.git', :branch => 'master'

  depends_on :python

  def install
    inreplace "Makefile" do |s|
      s.gsub! "PREFIX=/usr/local/ssdb", "PREFIX=#{prefix}"
    end

    system "make", "prefix=#{prefix} CC=#{ENV.cc} CXX=#{ENV.cxx}"
    system "make", "install"

    %w[bench dump ins.sh repair server].each { |p| bin.install "#{prefix}/ssdb-#{p}" }

    %w[run db/ssdb log].each { |p| (var + p).mkpath }

    inreplace "ssdb.conf" do |s|
      s.gsub! "work_dir = ./var", "work_dir = #{var}/db/ssdb/"
      s.gsub! "pidfile = ./var/ssdb.pid", "pidfile = #{var}/run/ssdb.pid"
      s.gsub! "\toutput: log.txt", "\toutput: #{var}/log/ssdb.log"
    end

    inreplace "ssdb_slave.conf" do |s|
      s.gsub! "work_dir = ./var_slave", "work_dir = #{var}/db/ssdb/"
      s.gsub! "pidfile = ./var_slave/ssdb.pid", "pidfile = #{var}/run/ssdb_slave.pid"
      s.gsub! "\toutput: log_slave.txt", "\toutput: #{var}/log/ssdb_slave.log"
    end

    etc.install 'ssdb.conf'
    etc.install 'ssdb_slave.conf'
  end

  plist_options :manual => "ssdb-server #{HOMEBREW_PREFIX}/etc/ssdb.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/ssdb-server</string>
          <string>#{etc}/ssdb.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/ssdb.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/ssdb.log</string>
      </dict>
    </plist>
    EOS
  end

  test do
    pid = fork do
       Signal.trap("TERM") { system("#{bin}/ssdb-server -d #{HOMEBREW_PREFIX}/etc/ssdb.conf"); exit }
    end
    sleep(3)
    Process.kill("TERM", pid)
  end
end
