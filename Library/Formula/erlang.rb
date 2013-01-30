require 'formula'

class ErlangManuals < Formula
  url 'http://erlang.org/download/otp_doc_man_R16A_RELEASE_CANDIDATE.tar.gz'
  sha1 '383f4c7c5cbd09f677abeff9093a86848393417c'
end

class ErlangHtmls < Formula
  url 'http://erlang.org/download/otp_doc_html_R16A_RELEASE_CANDIDATE.tar.gz'
  sha1 '51dac9e1e27e06674d2fb85f556d7168f765cc34'
end

class ErlangHeadManuals < Formula
  url 'http://erlang.org/download/otp_doc_man_R16A_RELEASE_CANDIDATE.tar.gz'
  sha1 '383f4c7c5cbd09f677abeff9093a86848393417c'
end

class ErlangHeadHtmls < Formula
  url 'http://erlang.org/download/otp_doc_html_R16A_RELEASE_CANDIDATE.tar.gz'
  sha1 '51dac9e1e27e06674d2fb85f556d7168f765cc34'
end

class Erlang < Formula
  homepage 'http://www.erlang.org'
  # Download tarball from GitHub; it is served faster than the official tarball.
  url 'https://github.com/erlang/otp/archive/OTP_R16A_RELEASE_CANDIDATE.tar.gz'
  sha1 '25a1c4942c1620c5d5cc60e5a40b3cd79fcd483e'

  head 'https://github.com/erlang/otp.git', :branch => 'dev'

  bottle do
    sha1 '94cbe622b817e8a5bd7797b615aad5e47c5d8660' => :mountainlion
    sha1 'ec5b4749668c95ad55410c0316390046ee576895' => :lion
    sha1 '10b0aa609354c07938ac936578c9d1f12a4249ba' => :snowleopard
  end

  # remove the autoreconf if possible
  depends_on :automake
  depends_on :libtool

  fails_with :llvm do
    build 2334
  end

  option 'disable-hipe', "Disable building hipe; fails on various OS X systems"
  option 'halfword', 'Enable halfword emulator (64-bit builds only)'
  option 'time', '`brew test --time` to include a time-consuming test'
  option 'no-docs', 'Do not install documentation'

  def install
    ohai "Compilation takes a long time; use `brew install -v erlang` to see progress" unless ARGV.verbose?

    if ENV.compiler == :llvm
      # Don't use optimizations. Fixes build on Lion/Xcode 4.2
      ENV.remove_from_cflags /-O./
      ENV.append_to_cflags '-O0'
    end

    # Do this if building from a checkout to generate configure
    system "./otp_build autoconf" if File.exist? "otp_build"

    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--enable-kernel-poll",
            "--enable-threads",
            "--enable-dynamic-ssl-lib",
            "--enable-shared-zlib",
            "--enable-smp-support"]

    args << "--with-dynamic-trace=dtrace" unless MacOS.version == :leopard

    unless build.include? 'disable-hipe'
      # HIPE doesn't strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << '--enable-hipe'
    end

    if MacOS.prefer_64_bit?
      args << "--enable-darwin-64bit"
      args << "--enable-halfword-emulator" if build.include? 'halfword' # Does not work with HIPE yet. Added for testing only
    end

    system "./configure", *args
    touch 'lib/wx/SKIP' if MacOS.version >= :snow_leopard
    system "make"
    system "make install"

    unless build.include? 'no-docs'
      manuals = build.head? ? ErlangHeadManuals : ErlangManuals
      manuals.new.brew { man.install Dir['man/*'] }

      htmls = build.head? ? ErlangHeadHtmls : ErlangHtmls
      htmls.new.brew { doc.install Dir['*'] }
    end
  end

  def test
    `#{bin}/erl -noshell -eval 'crypto:start().' -s init stop`

    # This test takes some time to run, but per bug #120 should finish in
    # "less than 20 minutes". It takes a few minutes on a Mac Pro (2009).
    if build.include? "time"
      `#{bin}/dialyzer --build_plt -r #{lib}/erlang/lib/kernel-2.15/ebin/`
    end
  end
end
