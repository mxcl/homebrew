class Afio < Formula
  desc "Creates cpio-format archives"
  homepage "http://members.chello.nl/~k.holtman/afio.html"
  url "http://members.chello.nl/~k.holtman/afio-2.5.1.tgz"
  sha256 "363457a5d6ee422d9b704ef56d26369ca5ee671d7209cfe799cab6e30bf2b99a"
  head "https://github.com/kholtman/afio.git"

  bottle do
    cellar :any
    sha1 "1a3bbc0e6d6ff0926a75141af4204a6f167af533" => :mavericks
    sha1 "ffda2ae983cf6e1212aff8f4933799f124ec136f" => :mountain_lion
    sha1 "68ecadc2fc7e8dd268ac9e6a63fc12927d60f897" => :lion
  end

  # Note - The Freecode website is no longer being updated and alternative
  # links should be found from now on.

  option "with-bzip2", "Use bzip2(1) instead of gzip(1) for compression/decompression"
  deprecated_option "bzip2" => "with-bzip2"

  def install
    if build.with? "bzip2"
      inreplace "Makefile", "-DPRG_COMPRESS='\"gzip\"'", "-DPRG_COMPRESS='\"bzip2\"'"
      inreplace "afio.c", "with -o: gzip files", "with -o: bzip2 files"
      inreplace "afio.1", "gzip", "bzip2"
      inreplace "afio.1", "bzip2, bzip2,", "gzip, bzip2,"
    end

    system "make", "DESTDIR=#{prefix}"
    bin.install "afio"
    man1.install "afio.1"

    prefix.install "ANNOUNCE-2.5.1" => "ANNOUNCE"
    prefix.install %w[INSTALLATION SCRIPTS]
    share.install Dir["script*"]
  end

  test do
    path = testpath/"test"
    path.write "homebrew"
    pipe_output("#{bin}/afio -o archive", "test\n")

    system "#{bin}/afio", "-r", "archive"
    path.unlink

    system "#{bin}/afio", "-t", "archive"
    system "#{bin}/afio", "-i", "archive"
    assert_equal "homebrew", path.read.chomp
  end
end
