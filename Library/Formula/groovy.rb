require 'formula'

class Groovy < Formula
  homepage 'http://groovy.codehaus.org/'
  url 'http://dist.groovy.codehaus.org/distributions/groovy-binary-1.8.3.zip'
  md5 '82dd3be3ab02ab0b4e763dfeba834879'

  def install
    rm_f Dir["bin/*.bat"]

    prefix.install %w{ LICENSE.txt NOTICE.txt }
    libexec.install %w[bin conf lib]

    bin.mkpath
    Dir["#{libexec}/bin/*"].each do |f|
      next unless File.extname(f).empty?
      ln_s f, bin+File.basename(f)
    end
  end

  def caveats
    <<-EOS.undent
      You should set the environment variable GROOVY_HOME to
        #{libexec}
    EOS
  end
end
