class Libmusicbrainz < Formula
  desc "MusicBrainz Client Library"
  homepage "https://musicbrainz.org/doc/libmusicbrainz"
  url "https://github.com/metabrainz/libmusicbrainz/releases/download/release-5.1.0/libmusicbrainz-5.1.0.tar.gz"
  sha1 "1576b474c777bb9c4ff906853ef1d3bb14915f50"

  bottle do
    cellar :any
    sha1 "96390dbcc935eba33bf6908cda20f556991fbf8c" => :yosemite
    sha1 "b985f402432c3bafa240cd6541c518100fbb5230" => :mavericks
    sha1 "b336d4eb2c17a1143cefd2838f614ea685f35e34" => :mountain_lion
  end

  depends_on "cmake" => :build
  depends_on "neon"

  def install
    neon = Formula["neon"]
    neon_args = %W[-DNEON_LIBRARIES:FILEPATH=#{neon.lib}/libneon.dylib
                   -DNEON_INCLUDE_DIR:PATH=#{neon.include}/neon]
    system "cmake", ".", *(std_cmake_args + neon_args)
    system "make", "install"
  end
end
