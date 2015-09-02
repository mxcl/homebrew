class Dcd < Formula
  desc "Auto-complete program for the D programming language"
  homepage "https://github.com/Hackerpilot/DCD"
  url "https://github.com/Hackerpilot/DCD.git",
      :tag => "v0.7.0",
      :revision => "5310b346304e060c7633521fe3fd5afc2a16de88"
  head "https://github.com/Hackerpilot/dcd.git", :shallow => false

  bottle do
    sha256 "b2bfea971d1cce8f221a524d3ddd10f5b2e6775acfe29754d765785d875a6bb6" => :yosemite
    sha256 "f159386dfbfb7d225010f3fa24e9b0dc911a718bd81a059be243edb6af4f880c" => :mavericks
    sha256 "84a24c63e3b05ce812ffb7453f1fd5edfb47dfe053bd6c02401f264dd9febc60" => :mountain_lion
  end

  depends_on "dmd" => :build

  def install
    system "make"
    bin.install "bin/dcd-client", "bin/dcd-server"
  end

  test do
    begin
      # spawn a server, using a non-default port to avoid
      # clashes with pre-existing dcd-server instances
      server = fork do
        exec "#{bin}/dcd-server", "-p9167"
      end
      # Give it generous time to load
      sleep 0.5
      # query the server from a client
      system "#{bin}/dcd-client", "-q", "-p9167"
    ensure
      Process.kill "TERM", server
      Process.wait server
    end
  end
end
