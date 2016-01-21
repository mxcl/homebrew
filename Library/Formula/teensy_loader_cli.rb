class TeensyLoaderCli < Formula
  desc "Command-line integration for Teensy USB development boards"
  homepage "https://www.pjrc.com/teensy/loader_cli.html"
  url "https://www.pjrc.com/teensy/teensy_loader_cli.2.1.zip"
  head "https://github.com/PaulStoffregen/teensy_loader_cli.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "6328eeb1ed51edb8527874bd7c0f1a45cdf4052f0c35863dd1a67b5e0644c57e" => :el_capitan
    sha256 "90d5b5bf9adbece0001da72b1881617406bb9eeb76ff97ad5989e779179f5590" => :yosemite
    sha256 "dcd10140babb4d2937ce376c89e9c24a2e8046d2cabdad2cfdbc2542afa14471" => :mavericks
  end

  devel do
    url "https://github.com/PaulStoffregen/teensy_loader_cli.git", :revision => "0cca2087afb54173ce03109cabb1e29658703fc8"
    version "2.1.devel"
  end

  option "with-libusb-compat", "Uses libusb instead od OS X HID api to connect with teensy boards. Available only for --devel and upwards."
  depends_on "libusb-compat"  => :optional

  def pour_bottle?
      build.without? "libusb-compat"
  end

  def install
    ENV["OS"] = "MACOSX"

    if build.with? "libusb-compat"
      ENV["USE_LIBUSB"] = "YES"
    else
      ENV["SDK"] = MacOS.sdk_path || "/"
    end

    system "make"
    bin.install "teensy_loader_cli"
  end

  test do
    output = shell_output("#{bin}/teensy_loader_cli 2>&1", 1)
    assert_match /Filename must be specified/, output
    # system "#{bin}/teensy_loader_cli --list-mcus"
  end
end
