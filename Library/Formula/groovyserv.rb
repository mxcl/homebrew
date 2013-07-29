require 'formula'

class Groovyserv < Formula
  homepage 'http://kobo.github.io/groovyserv/'
  url 'https://bitbucket.org/kobo/groovyserv-mirror/downloads/groovyserv-0.13-src.zip'
  sha1 '68e4d80b8309b71849d46590d9122a5fee2d36c3'

  head 'https://github.com/kobo/groovyserv.git'

  # This fix is upstream and can be removed in the next released version.
  def patches
    "https://github.com/kobo/groovyserv/commit/53b77ab2b4a7bcf6e232bc54f4e50e8b78d3006a.patch"
  end

  def install
    system './gradlew clean executables'

    # Install executables in libexec to avoid conflicts
    libexec.install Dir["build/executables/native/{bin,lib}"]

    # Remove windows files
    rm_f Dir["#{libexec}/bin/*.bat"]

    # Symlink binaries
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end
end
