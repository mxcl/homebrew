# Libedit 3.0
# rhubarb@ruction.org

require 'formula'

class Libedit < Formula
  url 'http://www.thrysoee.dk/editline/libedit-20110802-3.0.tar.gz'
  homepage ''
  md5 '0ea42e2c794da8ed32f6307b427f6590'

  # depends_on 'cmake'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    # system "cmake . #{std_cmake_parameters}"
    system "make install"
  end

  def test
    # This test will fail and we won't accept that! It's enough to just
    # replace "false" with the main program this formula installs, but
    # it'd be nice if you were more thorough. Test the test with
    # `brew test libedit`. Remove this comment before submitting
    # your pull request!
    system "false"
  end
end
