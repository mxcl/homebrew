require 'formula'

class Phash < Formula
  url 'http://www.phash.org/releases/pHash-0.9.4.tar.gz'
  homepage 'http://www.phash.org/'
  sha1 '9710b8a1d4d24e7fc3ac43c33eac8e89d9e727d7'
  
  unless Formula.factory('cimg').linked_keg.exist?
    depends_on 'cimg' unless ARGV.include? "--disable-image-hash" and ARGV.include? "--disable-video-hash"
  end
  
  depends_on 'ffmpeg' unless ARGV.include? "--disable-video-hash"

  unless ARGV.include? "--disable-audio-hash"
    depends_on 'libsndfile'
    depends_on 'libsamplerate'
    depends_on 'mpg123'
  end

  def options
    [
     ["--disable-image-hash", "Disable image hash"],
     ["--disable-video-hash", "Disable video hash"],
     ["--disable-audio-hash", "Disable audio hash"]
    ]
  end

  # fix compilation on ffmpeg <= 0.7
  # source: https://launchpad.net/ubuntu/+source/libphash/0.9.4-1.2
  def patches
    "https://launchpad.net/ubuntu/+archive/primary/+files/libphash_0.9.4-1.2.diff.gz"
  end

  def install
    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--enable-shared"]

    # disable specific hashes if specified as an option
    if Formula.factory('cimg').linked_keg.exist?
      args << "--disable-image-hash" if ARGV.include? "--disable-image-hash"
      args << "--disable-video-hash" if ARGV.include? "--disable-video-hash"
    else
      args << "--disable-image-hash" << "--disable-video-hash"
    end
    
    args << "--disable-audio-hash" if ARGV.include? "--disable-audio-hash"

    system "./configure", *args
    system "make install"
  end
end
