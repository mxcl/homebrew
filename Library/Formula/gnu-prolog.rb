require 'formula'

class GnuProlog < Formula
  homepage 'http://www.gprolog.org/'
  url 'http://gprolog.univ-paris1.fr/gprolog-1.4.0.tar.gz'
  md5 'cc944e5637a04a9184c8aa46c947fd16'

  skip_clean :all

  # Support OSX x86-64. See:
  # https://github.com/mxcl/homebrew/pull/7428
  # http://lists.gnu.org/archive/html/users-prolog/2011-09/msg00004.html
  # Includes previous inreplace fix from:
  # http://lists.gnu.org/archive/html/users-prolog/2011-07/msg00013.html
  def patches
    "https://gist.github.com/raw/1191268/35db85d5cfe5ecd5699286bdd945856ea9cee1a1/patch-x86_64-darwin.diff"
  end

  def install
    ENV.j1 # make won't run in parallel

    cd 'src' do
      args = ["--prefix=#{prefix}"]

      if MacOS.prefer_64_bit?
        args << "--build=x86_64-apple-darwin" << "--host=x86_64-apple-darwin"
      end

      system "./configure", *args
      system "make"
      system "make install-strip"
    end
  end
end
