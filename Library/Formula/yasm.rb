require 'formula'

class Yasm < Formula
  homepage 'http://yasm.tortall.net/'
  url 'http://tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz'
  sha256 '768ffab457b90a20a6d895c39749adb547c1b7cb5c108e84b151a838a23ccf31'

  head 'https://github.com/yasm/yasm.git'

  option 'enable-python', 'Enable Python bindings'

  if build.head?
    depends_on 'gettext'
    depends_on :automake
  end

  depends_on 'Cython' => :python if build.include? 'enable-python'

  def install
    ENV.deparallelize
    args = %W[
      --disable-debug
      --prefix=#{prefix}
    ]

    if build.include? 'enable-python'
      args << '--enable-python'
      args << '--enable-python-bindings'
    end

    # Avoid "ld: library not found for -lcrt1.10.6.o" on Xcode without CLT
    ENV['LIBS'] = ENV.ldflags
    ENV['INCLUDES'] = ENV.cppflags
    system './autogen.sh' if build.head?
    system './configure', *args
    system 'make install'
  end

  def caveats
    if build.include? 'enable-python' then <<-EOS.undent
      Python bindings installed to:
        #{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages

      For non-homebrew Python, you need to amend your PYTHONPATH like so:
        export PYTHONPATH=#{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages:$PYTHONPATH
      EOS
    end
  end

  def which_python
    'python' + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
