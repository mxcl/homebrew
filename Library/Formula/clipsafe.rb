require 'formula'

class Clipsafe < Formula
  homepage 'http://waxandwane.org/clipsafe.html'
  url 'http://waxandwane.org/download/clipsafe-1.1.tar.gz'
  sha1 '5e940a3f89821bfb3315ff9b1be4256db27e5f6a'

  depends_on :macos => :mountain_lion

  resource "Crypt::Twofish" do
    url "http://search.cpan.org/CPAN/authors/id/A/AM/AMS/Crypt-Twofish-2.17.tar.gz"
    sha1 "f2659d7b9e7d7daadb3b2414174bd6ec8ac68eda"
  end

  resource "Digest::SHA" do
    url "http://search.cpan.org/CPAN/authors/id/M/MS/MSHELOR/Digest-SHA-5.85.tar.gz"
    sha1 "a603cfba95afcd0266c9482c0c93e84241fe0ce0"
  end

  resource "DateTime" do
    url "http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/DateTime-1.03.tar.gz"
    sha1 "23cad043140988ea95ad8dcb3095cc5aded0464e"
  end

  def install
    resource("Crypt::Twofish").stage do
      system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
      system "make"
      system "make", "install"
    end

    resource("Digest::SHA").stage do
      system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
      system "make"
      system "make", "install"
    end

    resource("DateTime").stage do
      system "perl", "Build.PL", "--install_base=#{libexec}"
      system "./Build"
      system "./Build", "install"
    end

    # patch since we need to add the the ressources to perls load_path
    first_doc_string = "# cliPSafe is a command line interface to Password Safe databases."
    inreplace "clipsafe", /#{first_doc_string}/, "use lib '#{libexec}/lib/perl5';\n#{first_doc_string}"

    bin.install "clipsafe"
  end

  test do
    ENV["TERM"] = "dumb"
    system "#{bin}/clipsafe", "--help"
  end
end
