require 'formula'

class Geoserver < Formula
  homepage 'http://geoserver.org/'
  url 'https://downloads.sourceforge.net/project/geoserver/GeoServer/2.5.2/geoserver-2.5.2-bin.zip'
  sha1 '4f0a4c9945ba4adb03395393140212298db683b8'

  def install
    libexec.install Dir['*']
    (bin/'geoserver').write <<-EOS.undent
      #!/bin/sh
      if [ -z "$1" ]; then
        echo "Usage: $ geoserver path/to/data/dir"
      else
        cd "#{libexec}" && java -DGEOSERVER_DATA_DIR=$1 -jar start.jar
      fi
    EOS
  end

  def caveats; <<-EOS.undent
    To start geoserver:
      geoserver path/to/data/dir

    See the Geoserver homepage for more setup information:
      brew home geoserver
    EOS
  end
end
