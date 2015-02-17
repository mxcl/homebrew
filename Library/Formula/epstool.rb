class Epstool < Formula
  homepage "http://pages.cs.wisc.edu/~ghost/gsview/epstool.htm"
  url "http://pkgs.fedoraproject.org/repo/pkgs/epstool/epstool-3.08.tar.gz/465a57a598dbef411f4ecbfbd7d4c8d7/epstool-3.08.tar.gz"
  mirror "https://raw.githubusercontent.com/DomT4/LibreMirror/master/Epstool/epstool-3.08.tar.gz"
  sha1 "dc495934f06d3ea8b3209e8b02ea96c66c34f614"

  depends_on "ghostscript"

  def install
    system "make", "install",
                   "EPSTOOL_ROOT=#{prefix}",
                   "EPSTOOL_MANDIR=#{man}",
                   "CC=#{ENV.cc}"
  end

  test do
    system bin/"epstool", "--add-tiff-preview", "--device", "tiffg3", test_fixtures("test.eps"), "test2.eps"
    assert File.exist?("test2.eps")
  end
end
