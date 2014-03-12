require 'formula'

class Scons < Formula
  homepage 'http://www.scons.org'
  url 'https://downloads.sourceforge.net/scons/scons-2.3.0.tar.gz'
  sha1 '728edf20047a9f8a537107dbff8d8f803fd2d5e3'

  bottle do
    revision 1
    sha1 "839f2f8506ffeeab91acfe5f786ed97c41cc3c5a" => :mavericks
    sha1 "74023d56d5ae0db3ab07bf18cd505b5c550cf4bd" => :mountain_lion
    sha1 "7f4ebc6ec9252557b0684b798a81cc3b8b3a229c" => :lion
  end

  def install
    bin.mkpath # Script won't create this if it doesn't already exist
    man1.install gzip('scons-time.1', 'scons.1', 'sconsign.1')
    system "/usr/bin/python", "setup.py", "install",
             "--prefix=#{prefix}",
             "--standalone-lib",
             # SCons gets handsy with sys.path---`scons-local` is one place it
             # will look when all is said and done.
             "--install-lib=#{libexec}/scons-local",
             "--install-scripts=#{bin}",
             "--install-data=#{libexec}",
             "--no-version-script", "--no-install-man"

    # Re-root scripts to libexec so they can import SCons and symlink back into
    # bin. Similar tactics are used in the duplicity formula.
    bin.children.each do |p|
      mv p, "#{libexec}/#{p.basename}.py"
      bin.install_symlink "#{libexec}/#{p.basename}.py" => p.basename
    end
  end
end
