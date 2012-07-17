require 'formula'

class Ipython < Formula
  homepage 'http://ipython.org/'
  url 'http://archive.ipython.org/release/0.12.1/ipython-0.12.1.tar.gz'
  sha1 'c4af9009d67460a894274cd80fb1d15251822f32'

  depends_on 'readline-python'
  depends_on 'pygments'
  depends_on 'pyzmq'
  depends_on 'pyqt'

  def install
    system "python setup.py config"
    system "python setup.py build"
    system "python setup.py install --prefix=#{prefix}"
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end

  def site_package_dir
    "lib/#{which_python}/site-packages"
  end

  def caveats
    <<-EOS
IPython Python modules have been linked to:
    #{HOMEBREW_PREFIX}/#{site_package_dir}

Make sure this folder is on your PYTHONPATH.
    EOS
  end
end
