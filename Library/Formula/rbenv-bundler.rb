require 'formula'

class RbenvBundler < Formula
  homepage 'https://github.com/carsomyr/rbenv-bundler'
  url 'https://github.com/carsomyr/rbenv-bundler/tarball/0.94'
  sha1 '73b1aa192f22571b38d4e110d76f4138c5233c8f'

  depends_on 'rbenv'

  def install
    prefix.install Dir['*']
  end

  def caveats
    s = ""
    s += <<-EOS.undent
      To enable rbenv bundler create an rbenv plugins folder:

      mkdir $HOME/.rbenv/plugins

      And symlink the rbenv-bundler plugin:

      ln -s #{prefix} $HOME/.rbenv/plugins/bundler
      
      EOS

    return s
  end
end
