require 'formula'

class SpringRoo < Formula
  url 'http://s3.amazonaws.com/dist.springframework.org/release/ROO/spring-roo-1.1.4.RELEASE.zip'
  version '1.1.4'
  homepage 'http://www.springsource.org/roo'
  md5 'c4f572fa6ab2c1162b4761054df9f67a'

  def install
    rm_f Dir["bin/*.bat"]
    prefix.install %w[annotations bin bundle conf docs legal samples]
  end
end
