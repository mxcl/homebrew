class TestballBottle < Formula
  def initialize(name = "testball_bottle", path = Pathname.new(__FILE__).expand_path, spec = :stable)
    self.class.instance_eval do
      stable.url "file://#{File.expand_path("..", __FILE__)}/tarballs/testball-0.1.tbz"
      stable.sha256 "1dfb13ce0f6143fe675b525fc9e168adb2215c5d5965c9f57306bb993170914f"
    end
    super
  end

  bottle do
    root_url "file://#{File.expand_path("..", __FILE__)}/bottles"
    sha256 "7cf1d893838bc940beb3671f28a85de8e636489843b272772fbcba4bfb056c4a" => :yosemite
    sha256 "7cf1d893838bc940beb3671f28a85de8e636489843b272772fbcba4bfb056c4a" => :mavericks
    sha256 "7cf1d893838bc940beb3671f28a85de8e636489843b272772fbcba4bfb056c4a" => :mountain_lion
  end
end
