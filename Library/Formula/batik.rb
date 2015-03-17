class Batik < Formula
  homepage "https://xmlgraphics.apache.org/batik/"
  url "https://www.apache.org/dist/xmlgraphics/batik/binaries/batik-bin-1.8.zip"
  sha256 "d1e5d6c08ef769bb53289250f17ba2d8b18a803d2a82aa082c8bbfae07c648f0"

  def install
    libexec.install "lib", Dir["*.jar"]
    prefix.install_metafiles

    bin.write_jar_script libexec/"batik-rasterizer-#{version}.jar", "batik-rasterizer"
    bin.write_jar_script libexec/"batik-#{version}.jar", "batik"
    bin.write_jar_script libexec/"batik-ttf2svg-#{version}.jar", "batik-ttf2svg"
  end
end
