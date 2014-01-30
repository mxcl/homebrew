require "formula"

class Kvazaar < Formula
  homepage "https://github.com/ultravideo/kvazaar"
  url "https://github.com/ultravideo/kvazaar/archive/v0.2.0.tar.gz"
  sha1 "b0f23dc0d421e64183deba8fdcd2347863d711d5"

  depends_on 'yasm' => :build

  def install
    cd 'src' do
      inreplace 'Makefile', 'elf64', 'macho64'
      inreplace 'Makefile', 'elf', 'macho32'
      inreplace 'x64/test64.asm', 'cpuId64', '_cpuId64'
      system 'make'
    end
    bin.install 'src/kvazaar'
  end
end
