class Docutils < Formula
  desc "Text processing system for reStructuredText"
  homepage "http://docutils.sourceforge.net"
  url "https://downloads.sourceforge.net/project/docutils/docutils/0.12/docutils-0.12.tar.gz"
  sha256 "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa"

  resource "docutils" do
    url "https://downloads.sourceforge.net/project/docutils/docutils/0.12/docutils-0.12.tar.gz"
    sha256 "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa"
  end

  def install
    ENV["PYTHONPATH"] = libexec+"lib/python2.7/site-packages"

    resources.each do |r|
      r.stage { system "python", *Language::Python.setup_install_args(libexec) }
    end

    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/rst2*.py"]
    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/rst2man.py", "#{prefix}/HISTORY.txt"
  end
end
