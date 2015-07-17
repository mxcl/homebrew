require 'formula'

class JbossForge < Formula
  desc "Tools to help set up and configure a project"
  homepage 'http://forge.jboss.org/'
  url 'https://repository.jboss.org/nexus/service/local/artifact/maven/redirect?r=releases&g=org.jboss.forge&a=forge-distribution&v=2.17.0.Final&e=zip&c=offline'
  version '2.17.0.Final'
  sha1 '38687342e29d0d39b36856dc5aac74b033f72ce3'

  def install
    rm_f Dir["bin/*.bat"]
    libexec.install %w{ addons bin img lib logging.properties }
    bin.install_symlink libexec/'bin/forge'
  end
end
