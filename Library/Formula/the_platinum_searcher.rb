require "formula"

class ThePlatinumSearcher < Formula
    homepage "https://github.com/monochromegane/the_platinum_searcher"
    head "https://github.com/monochromegane/the_platinum_searcher.git"
    url "https://github.com/monochromegane/the_platinum_searcher/archive/v1.6.4.tar.gz"
    sha1 "362df20068c9ea19dfb3126c267012356dc7958c"

    depends_on "go" => :build
    depends_on :hg => :build

    def install
        # Setup buildpath for local dependencies
        (buildpath + "src/github.com/monochromegane/the_platinum_searcher").install "search"

        ENV["GOPATH"] = buildpath

        # Install Go dependencies
        system "go", "get", "github.com/shiena/ansicolor"
        system "go", "get", "github.com/monochromegane/terminal"
        system "go", "get", "github.com/jessevdk/go-flags"
        system "go", "get", "code.google.com/p/go.text/transform"

        # Build and install the_silver_searcher
        system "go", "build", "-o", "pt"
        bin.install "pt"
    end

    test do
        path = testpath/"hello_world.txt"
        data = "Hello World!"
        path.open("wb") { |f| f.write data}

        lines = `#{bin}/pt 'Hello World!' #{path}`.strip.split(":")
        assert_equal "Hello World!", lines[2]
    end
end
