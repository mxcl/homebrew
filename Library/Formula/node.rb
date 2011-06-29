require 'formula'

class Node < Formula
  url 'http://nodejs.org/dist/node-v0.4.9.tar.gz'
  head 'https://github.com/joyent/node.git'
  homepage 'http://nodejs.org/'
  md5 'e525b8b99d949bf2f031bc262c138e96'

  # Leopard OpenSSL is not new enough, so use our keg-only one
  depends_on 'openssl' if MacOS.leopard?

  fails_with_llvm

  # Stripping breaks dynamic loading
  skip_clean :all

  def options
    [["--debug", "Build with debugger hooks."]]
  end

  def install
    inreplace 'wscript' do |s|
      s.gsub! '/usr/local', HOMEBREW_PREFIX
      s.gsub! '/opt/local/lib', '/usr/lib'
    end

    args = ["--prefix=#{prefix}"]
    args << "--debug" if ARGV.include? '--debug'

    system "./configure", *args
    system "make install"
  end

  def caveats
    "Please add #{HOMEBREW_PREFIX}/lib/node to your NODE_PATH environment variable to have node libraries picked up."
  end
end
