class Swiftlint < Formula
  desc "Experimental tool to enforce Swift style and conventions"
  homepage "https://github.com/realm/SwiftLint"
  url "https://github.com/realm/SwiftLint.git", :tag => "0.1.2", :revision => "4c91500e7b90a1d651d16e9c604ab927da050e8f"
  head "https://github.com/realm/SwiftLint.git"

  bottle do
    cellar :any
    sha256 "c2d3dfadfe93370770d98d0aa8c562a79a279228f7aa4d04ae2226c5d276bad0" => :yosemite
  end

  depends_on :xcode => ["6.4", :build]

  def install
    system "make", "prefix_install", "PREFIX=#{prefix}", "TEMPORARY_FOLDER=#{buildpath}/SwiftLint.dst"
  end

  test do
    (testpath/"Test.swift").write "import Foundation\n"
    system "#{bin}/swiftlint"
  end
end
