require 'formula'

class Neo4j < Formula
  homepage 'http://neo4j.org'
  url 'http://download.neo4j.org/artifact?edition=community&version=2.0.3&distribution=tarball&dlid=3981613'
  sha1 'ec68744c10fb387153227221d41deda6aee88976'
  version '2.0.3'

  def install
    # Remove windows files
    rm_f Dir["bin/*.bat"]

    # Install jars in libexec to avoid conflicts
    libexec.install Dir['*']

    # Symlink binaries
    bin.install_symlink Dir["#{libexec}/bin/neo4j{,-shell}"]

    # Adjust UDC props
    open("#{libexec}/conf/neo4j-wrapper.conf", 'a') { |f|
      f.puts "wrapper.java.additional.4=-Dneo4j.ext.udc.source=homebrew"

      # suppress the empty, focus-stealing java gui
      f.puts "wrapper.java.additional=-Djava.awt.headless=true"
    }
  end
end
