require "language/haskell"

class Idris < Formula
  include Language::Haskell::Cabal

  homepage "http://www.idris-lang.org"
  url "https://github.com/idris-lang/Idris-dev/archive/v0.9.16.tar.gz"
  sha1 "01f794c4e516454b8352266c26c92549e90c708f"
  head "https://github.com/idris-lang/Idris-dev.git"

  bottle do
    sha1 "1fd1c7c3f223512d2869e8790c4e5afb0f196409" => :yosemite
    sha1 "b8a7ffc5ed4429665658e54cefe400bacbc26c53" => :mavericks
    sha1 "6dc50e41562eef4d18987f6f673b8a77f22a5512" => :mountain_lion
  end

  depends_on "ghc" => :build
  depends_on "cabal-install" => :build
  depends_on "gmp"

  depends_on "libffi" => :recommended
  depends_on "pkg-config" => :build if build.with? "libffi"

  def install
    if build.with? "libffi"
      ENV.prepend_path "PKG_CONFIG_PATH",
                       "#{Formula["libffi"].opt_prefix}/lib/pkgconfig"
    end
    cabal_sandbox do
      flags = []
      flags << "-f FFI" if build.with? "libffi"
      flags << "-f release" if build.stable?
      cabal_install "--only-dependencies", *flags
      cabal_install "--prefix=#{prefix}", *flags
    end
    cabal_clean_lib
  end

  test do
    (testpath/"hello.idr").write <<-EOS.undent
      module Main
      main : IO ()
      main = putStrLn "Hello, Homebrew!"
    EOS
    shell_output "#{bin}/idris #{testpath}/hello.idr -o #{testpath}/hello"
    result = shell_output "#{testpath}/hello"
    assert_match /Hello, Homebrew!/, result

    if build.with? "libffi"
      cmd = "#{bin}/idris --exec 'putStrLn \"Hello, interpreter!\"'"
      result = shell_output cmd
      assert_match /Hello, interpreter!/, result
    end
  end
end
