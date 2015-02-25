class Redpen < Formula
  homepage "http://redpen.cc/"
  url "https://github.com/recruit-tech/redpen/releases/download/v1.1.2/redpen-1.1.2.tar.gz"
  sha1 "d9ba46a7c5813b444cbbc1dca5c24aa2d75cb126"

  depends_on :java => "1.8"

  def install
    # Don't need Windows files.
    rm_f Dir["bin/*.bat"]
    libexec.install %w[conf lib sample-doc]

    prefix.install "bin"
    bin.env_script_all_files(libexec/"bin", :JAVA_HOME => ENV["JAVA_HOME"])
  end

  test do
    path = "#{libexec}/sample-doc/en/sampledoc-en.txt"
    output = "#{bin}/redpen -l 20 -c #{libexec}/conf/redpen-conf-en.xml #{path}"
    assert_match /^sampledoc-en.txt:1: ValidationError[SymbolWithSpace]*/, shell_output(output).split("\n").select { |line| line.start_with?("sampledoc-en.txt") }[0]
  end
end
