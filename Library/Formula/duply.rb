class Duply < Formula
  desc "Frontend to the duplicity backup system"
  homepage "http://duply.net"
  url "https://downloads.sourceforge.net/project/ftplicity/duply%20\(simple%20duplicity\)/1.11.x/duply_1.11.tgz"
  sha256 "234fc6e2cb7ad53966e40aabb5ca6447217b7b6179d5f6f18240ac5b5071f75c"

  bottle :unneeded

  depends_on "duplicity"

  def install
    bin.install "duply"
    # Homebrew uses env_script_all_files in the duplicity script, so calling it
    # with the python interpreter doesn't work
    inreplace "#{bin}/duply", "DEFAULT_PYTHON=\'python2\'", "DEFAULT_PYTHON=\'bash\'"
  end
end
