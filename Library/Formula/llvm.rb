class CodesignRequirement < Requirement
  include FileUtils
  fatal true

  satisfy(:build_env => false) do
    mktemp do
      touch "llvm_check.txt"
      quiet_system "/usr/bin/codesign", "-s", "lldb_codesign", "--dryrun", "llvm_check.txt"
    end
  end

  def message
    <<-EOS.undent
      lldb_codesign identity must be available to build with LLDB.
      See: https://llvm.org/svn/llvm-project/lldb/trunk/docs/code-signing.txt
    EOS
  end
end

class Llvm < Formula
  desc "llvm (Low Level Virtual Machine): a next-gen compiler infrastructure"
  homepage "http://llvm.org/"

  stable do
    url "http://llvm.org/releases/3.6.2/llvm-3.6.2.src.tar.xz"
    sha256 "f60dc158bfda6822de167e87275848969f0558b3134892ff54fced87e4667b94"

    resource "clang" do
      url "http://llvm.org/releases/3.6.2/cfe-3.6.2.src.tar.xz"
      sha256 "ae9180466a23acb426d12444d866b266ff2289b266064d362462e44f8d4699f3"
    end

    resource "libcxx" do
      url "http://llvm.org/releases/3.6.2/libcxx-3.6.2.src.tar.xz"
      sha256 "52f3d452f48209c9df1792158fdbd7f3e98ed9bca8ebb51fcd524f67437c8b81"
    end

    resource "libcxxabi" do
      url "http://llvm.org/releases/3.6.2/libcxxabi-3.6.2.src.tar.xz"
      sha256 "6fb48ce5a514686b9b75e73e59869f782ed374a86d71be8423372e4b3329b09b"
    end

    resource "lld" do
      url "http://llvm.org/releases/3.6.2/lld-3.6.2.src.tar.xz"
      sha256 "43f553c115563600577764262f1f2fac3740f0c639750f81e125963c90030b33"
    end

    resource "lldb" do
      url "http://llvm.org/releases/3.6.2/lldb-3.6.2.src.tar.xz"
      sha256 "940dc96b64919b7dbf32c37e0e1d1fc88cc18e1d4b3acf1e7dfe5a46eb6523a9"
    end

    resource "extra-tools" do
      url "http://llvm.org/releases/3.6.2/clang-tools-extra-3.6.2.src.tar.xz"
      sha256 "6a0ec627d398f501ddf347060f7a2ccea4802b2494f1d4fd7bda3e0442d04feb"
    end

    resource "polly" do
      url "http://llvm.org/releases/3.6.2/polly-3.6.2.src.tar.xz"
      sha256 "f2a956730b76212f22a1c10f35f195795e4d027ad28c226f97ddb8c0fd16bcbc"
    end

    resource "sanitizers" do
      url "http://llvm.org/releases/3.6.2/compiler-rt-3.6.2.src.tar.xz"
      sha256 "0f2ff37d80a64575fecd8cf0d5c50f7ac1f837ddf700d1855412bb7547431d87"
    end
  end

  bottle do
    cellar :any
    sha256 "fa04afc62800a236e32880efe30e1dbb61eace1e7e9ec20d2d53393ef9d68636" => :el_capitan
    sha256 "a0ec4b17ae8c1c61071e603d0dcf3e1c39a5aae63c3f8237b4363a06701a3319" => :yosemite
    sha256 "17a62c19d119c88972fa3dce920cfbc6150af8892ba8e29ce551ae7e2e84f42e" => :mavericks
    sha256 "6d780faae2647ebce704b2f0a246b52d4037ebf4a2f796644814607e7751af93" => :mountain_lion
  end

  head do
    url "http://llvm.org/git/llvm.git"

    resource "clang" do
      url "http://llvm.org/git/clang.git"
    end

    resource "libcxx" do
      url "http://llvm.org/git/libcxx.git"
    end

    resource "libcxxabi" do
      url "http://llvm.org/git/libcxxabi.git"
    end

    resource "lld" do
      url "http://llvm.org/git/lld.git"
    end

    resource "lldb" do
      url "http://llvm.org/git/lldb.git"
    end

    resource "extra-tools" do
      url "http://llvm.org/git/clang-tools-extra.git"
    end

    resource "sanitizers" do
      url "http://llvm.org/git/compiler-rt.git"
    end

    resource "polly" do
      url "http://llvm.org/git/polly.git"
    end
  end

  option :universal
  option "with-clang", "Build Clang support library"
  option "with-extra-tools", "Build extra tools for Clang"
  option "with-libcxx", "Build the libc++ standard library"
  option "with-lld", "Build LLD linker"
  option "with-lldb", "Build LLDB debugger"
  option "with-rtti", "Build with C++ RTTI"
  option "with-polly", "Build with the experimental Polly optimizer"
  option "with-python", "Build Python bindings against Homebrew Python"
  option "with-sanitizers", "Enable Clang code sanitizers"
  option "with-tests", "Run the basic regression test suite after the build"
  option "without-assertions", "Speeds up LLVM, but provides less debug information"

  deprecated_option "rtti" => "with-rtti"
  deprecated_option "disable-assertions" => "without-assertions"

  if MacOS.version <= :snow_leopard
    depends_on :python
  else
    depends_on :python => :optional
  end
  depends_on "cmake" => :build

  if build.with? "lldb"
    depends_on "swig"
    depends_on CodesignRequirement
  end

  if build.with? "polly"
    depends_on "isl"
  end

  keg_only :provided_by_osx

  # Apple's libstdc++ is too old to build LLVM
  fails_with :gcc
  fails_with :llvm

  def install
    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang
    # compiler-rt has some iOS simulator features that require i386 symbols
    # I'm assuming the rest of clang needs support too for 32-bit compilation
    # to work correctly, but if not, perhaps universal binaries could be
    # limited to compiler-rt. llvm makes this somewhat easier because compiler-rt
    # can almost be treated as an entirely different build from llvm.
    ENV.permit_arch_flags

    if build.with?("lldb") && build.without?("clang")
      raise "Building LLDB needs Clang support library."
    end

    prep.call("clang", "tools/clang", nil)
    prep.call("extra-tools", "tools/clang/tools/extra", "clang")
    prep.call("libcxx", "projects/libcxx", nil)
    prep.call("lld", "tools/lld", nil)
    prep.call("lldb", "tools/lldb", "clang")
    prep.call("polly", "tools/polly", "clang")
    prep.call("sanitizers", "projects/compiler-rt", "clang")

    if build.with?("libcxx")
      (buildpath/"projects/libcxxabi").install resource("libcxxabi")
    end

    if build.with?("tests") &&
       build.with?("sanitizers") &&
       build.without?("libcxx")
      raise "Building and running sanitizer tests requires libc++"
    end

    (buildpath/"tools/lld").install resource("lld") if build.with? "lld"
    (buildpath/"tools/lldb").install resource("lldb") if build.with? "lldb"
    (buildpath/"tools/polly").install resource("polly") if build.with? "polly"

    args = %w[
      -DLLVM_OPTIMIZED_TABLEGEN=On
    ]

    args << "-DLLVM_ENABLE_RTTI=On" if build.with? "rtti"

    if build.with? "assertions"
      args << "-DLLVM_ENABLE_ASSERTIONS=On"
    else
      args << "-DCMAKE_CXX_FLAGS_RELEASE='-DNDEBUG'"
    end

    if build.universal?
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.universal_archs.as_cmake_arch_flags}"
    end

    if build.with?("polly")
      args << "-DLINK_POLLY_INTO_TOOLS:Bool=ON"
    end

    mktemp do
      system "cmake", "-G", "Unix Makefiles", buildpath, *(std_cmake_args + args)
      system "make"
      system "make", "check-all" if build.with?("tests") && build.with?("clang")
      system "make", "test" if build.with?("tests") && build.with?("clang")
      system "make", "install"
    end

    if build.with? "clang"
      (share/"clang/tools").install Dir["tools/clang/tools/scan-{build,view}"]
      inreplace "#{share}/clang/tools/scan-build/scan-build", "$RealBin/bin/clang", "#{bin}/clang"
      bin.install_symlink share/"clang/tools/scan-build/scan-build", share/"clang/tools/scan-view/scan-view"
      man1.install_symlink share/"clang/tools/scan-build/scan-build.1"
    end

    # install llvm python bindings
    (lib/"python2.7/site-packages").install buildpath/"bindings/python/llvm"
    (lib/"python2.7/site-packages").install buildpath/"tools/clang/bindings/python/clang" if build.with? "clang"
  end

  def caveats
    <<-EOS.undent
      LLVM executables are installed in #{opt_bin}.
      Extra tools are installed in #{opt_share}/llvm.
    EOS
  end

  test do
    system "#{bin}/llvm-config", "--version"
  end
end
