require "language/go"

class Asciinema < Formula
  homepage "https://asciinema.org/"
  url "https://github.com/asciinema/asciinema-cli/archive/v0.9.9.tar.gz"
  sha1 "155c19366ffb3347e97026e9ab8006c16d2a52c6"

  depends_on "go" => :build

  go_resource "github.com/kr/pty" do
    url "https://github.com/kr/pty.git", :revision => "67e2db24c831afa6c64fc17b4a143390674365ef"
  end

  go_resource "code.google.com/p/go.crypto" do
    url "https://code.google.com/p/go.crypto/", :revision => "aa2644fe4aa5", :using => :hg
  end

  go_resource "code.google.com/p/gcfg" do
    url "https://code.google.com/p/gcfg/", :revision => "c2d3050044d05357eaf6c3547249ba57c5e235cb", :using => :git
  end

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/asciinema"
    ln_s buildpath, buildpath/"src/github.com/asciinema/asciinema-cli"
    Language::Go.stage_deps resources, buildpath/"src"

    system "go", "build", "-o", "asciinema"

    bin.install "asciinema"
  end

  test do
    assert_match /browser/, pipe_output("HOME=#{testpath} #{bin}/asciinema auth")
    assert File.exists?("#{testpath}/.asciinema/config")
  end

end
