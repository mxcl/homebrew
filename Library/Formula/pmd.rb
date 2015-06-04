require "formula"

class Pmd < Formula
  homepage "http://pmd.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/pmd/pmd/5.3.2/pmd-src-5.3.2.zip"
  sha1 "036cdb7583de3ea0d24e7486bf7b9f9f14bfb1ec"

  depends_on "maven" => :build

  patch :DATA

  def install
    system "mvn", "clean", "package"

    doc.install "LICENSE", "NOTICE", "README.md"

    libexec.install "pmd-dist/target/pmd-bin-5.3.2/pmd-bin-5.3.2/bin", "pmd-dist/target/pmd-bin-5.3.2/pmd-bin-5.3.2/lib"

    bin.install_symlink "#{libexec}/bin/run.sh" => "pmd"
    inreplace "#{libexec}/bin/run.sh", "${script_dir}/../lib", "#{libexec}/lib"
  end

  def caveats; <<-EOS.undent
    The install process needs maven3. It's not listed as a dependency since you may have a specific version installed. If you don't, do: brew install maven
    Once pmd is installed, maven isn't needed anymore.
    Run with `pmd` (instead of `run.sh` as described in the documentation).
    EOS
  end

  test do
    (testpath/"java/testClass.java").write <<-EOS.undent
      public class BrewTestClass {
        // dummy constant
        public String SOME_CONST = "foo";

        public boolean doTest () {
          return true;
        }
      }
    EOS

    system "#{bin}/pmd", "pmd", "-d", "#{testpath}/java", "-R",
      "rulesets/java/basic.xml", "-f", "textcolor", "-l", "java"
  end
end

__END__
diff --git a/pmd-dist/src/main/assembly/bin.xml b/pmd-dist/src/main/assembly/bin.xml
index 2b44241..685badb 100755
--- a/pmd-dist/src/main/assembly/bin.xml
+++ b/pmd-dist/src/main/assembly/bin.xml
@@ -3,7 +3,7 @@
 
     <id>bin</id>
     <formats>
-        <format>zip</format>
+        <format>dir</format>
     </formats>
 
     <includeBaseDirectory>true</includeBaseDirectory>
