class Gringo < Formula
  desc "Grounder to translate user-provided logic programs"
  homepage "http://potassco.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/potassco/gringo/4.5.1/gringo-4.5.1-source.tar.gz"
  sha256 "942be5977070859dc164347368248c1d22c451a55c2fd002081fa9abe0b5c50c"

  bottle do
    cellar :any
    sha256 "61e06e100961608e832b74a8221adfbea645269a268485d42808300cb0014c8d" => :yosemite
    sha256 "987a5a8c950f5df5d5626ed4cc9ba174cb011313ba9ee60263dff94c854202f3" => :mavericks
    sha256 "c800b81cec82149a45dfa2485d3e4e99ad26b71c7a5543841aa01259ff199dd7" => :mountain_lion
  end

  depends_on "re2c" => :build
  depends_on "scons" => :build
  depends_on "bison" => :build

  needs :cxx11

  def install
    # Allow pre-10.9 clangs to build in C++11 mode
    ENV.libcxx

    inreplace "SConstruct",
              "env['CXX']            = 'g++'",
              "env['CXX']            = '#{ENV.cxx}'"

    scons "--build-dir=release", "gringo", "clingo", "reify"
    bin.install "build/release/gringo", "build/release/clingo", "build/release/reify"
  end

  test do
    assert_match /#{version}/, shell_output("#{bin}/gringo --version")
  end
end
