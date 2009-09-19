require 'brewkit'

class Soprano <Formula
  @url='http://surfnet.dl.sourceforge.net/project/soprano/Soprano/2.3.1/soprano-2.3.1.tar.bz2'
  @homepage='http://soprano.sourceforge.net/'
  @md5='c9a2c008b80cd5d76599e9d48139dfe9'

  def deps
    LibraryDep.new 'qt'
    LibraryDep.new 'clucene'
    LibraryDep.new 'redland'
  end

  def install
    ENV['CLUCENE_HOME'] = HOMEBREW_PREFIX
    
    system "cmake . #{std_cmake_parameters}"
    system "make install"
  end
end
