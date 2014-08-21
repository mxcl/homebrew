require "formula"
class GitLatexdiff < Formula
  homepage "https://gitorious.org/git-latexdiff"
  url "git://gitorious.org/git-latexdiff/git-latexdiff.git", :revision => "cdb6c1b"

  def install
    system "make", "install"
  end

  test do
    system "git", "latexdiff", "-h"
  end
end
