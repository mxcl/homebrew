require "formula"

class EyeD3 < Formula
  homepage "http://eyed3.nicfit.net/"
  url "http://eyed3.nicfit.net/releases/eyeD3-0.7.5.tgz"
  sha1 "bcfd0fe14f5fa40f29ca7e7133138a5112f3c270"

  depends_on :python if MacOS.version <= :snow_leopard

  # Looking for documentation? Please submit a PR to build some!
  # See https://github.com/Homebrew/homebrew/issues/32770 for previous attempt.

  def install
    system "python", "setup.py", "install", "--prefix=#{prefix}"
    share.install "docs/plugins", "docs/api", "docs/cli.rst"
  end
end
