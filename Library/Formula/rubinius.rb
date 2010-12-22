require 'formula'

class Rubinius < Formula
  url 'http://asset.rubini.us/rubinius-1.2.0-20101221.tar.gz'
  version '1.2.0'
  homepage 'http://rubini.us/'
  md5 '4284c2660f1f648942de35d4fc871f70'
  head 'git://github.com/evanphx/rubinius.git'

  # Do not strip binaries, or else it fails to run.
  skip_clean :all

  def install
    # Let Rubinius define its own flags; messing with these causes build breaks.
    %w{CC CXX LD CFLAGS CXXFLAGS CPPFLAGS LDFLAGS}.each { |e| ENV.delete(e) }

    # Set to stop Rubinius messing with our prefix.
    ENV["RELEASE"] = "1"

    system "/usr/bin/ruby", "./configure",
                          "--skip-system", # download and use the prebuilt LLVM
                          "--bindir", bin,
                          "--prefix", prefix,
                          "--includedir", "#{include}/rubinius",
                          "--libdir", lib,
                          "--mandir", man, # For completeness; no manpages exist yet.
                          "--gemsdir", "#{lib}/rubinius/gems"

    ohai "config.rb", File.open('config.rb').to_a if ARGV.debug? or ARGV.verbose?

    system "/usr/bin/ruby", "-S", "rake", "install"
  end

  def caveats; <<-EOS.undent
    Consider using RVM or Cinderella to manage Ruby environments:
      * RVM: http://rvm.beginrescueend.com/
      * Cinderella: http://www.atmos.org/cinderella/
    EOS
  end
end
