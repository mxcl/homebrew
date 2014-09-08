require "formula"

class Knot < Formula
  homepage "https://www.knot-dns.cz/"
  url "https://secure.nic.cz/files/knot-dns/knot-1.5.2.tar.gz"
  sha1 "4605540f944b6dcd8401278a5bd2f85b6c400086"

  bottle do
    revision 1
    sha1 "d686096025a554581258b7507ef44bc3e4d75736" => :mavericks
    sha1 "05fb7b3f500a9018935489b97aba3ead6123425a" => :mountain_lion
    sha1 "e6e344e00cf66c1b100ab4d7fd33e182d80a563f" => :lion
  end

  depends_on "userspace-rcu"
  depends_on "openssl"
  depends_on "libidn"

  # pthread_spinlock_t doesn't exist on Mac OS X
  # https://gitlab.labs.nic.cz/labs/knot/issues/293
  patch do
    url "https://gitlab.labs.nic.cz/labs/knot/commit/3d3f31.diff"
    sha1 "76770789fbe833af966f94fa44b6c55a9df52318"
  end

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--with-configdir=#{etc}",
                          "--with-storage=#{var}/knot",
                          "--with-rundir=#{var}/knot",
                          "--prefix=#{prefix}"

    inreplace 'samples/Makefile', 'install-data-local:', 'disable-install-data-local:'

    system "make"
    system "make", "install"

    (buildpath + 'knot.conf').write(knot_conf)
    etc.install 'knot.conf'

    (var + 'knot').mkpath
  end

  def knot_conf; <<-EOS.undent
    system {
      identity on;
      version on;
      rundir "#{var}/knot";
    }
    interfaces {
      all_ipv4 {
        address 0.0.0.0;
        port 53;
      }
      all_ipv6 {
        address [::];
        port 53;
      }
    }
    control {
      listen-on "knot.sock";
    }
    zones {
      storage "#{var}/knot";
    #  example.com {
    #    file "#{var}/knot/example.com.zone";
    #  }
    }
    log {
      syslog {
        any error;
        zone warning, notice;
        server info;
      }
      stderr {
        any error, warning;
      }
    }
    EOS
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>EnableTransactions</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>RunAtLoad</key>
      <true/>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/sbin/knotd</string>
        <string>-c</string>
        <string>#{etc}/knot.conf</string>
      </array>
      <key>ServiceIPC</key>
      <false/>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/kdig", "www.knot-dns.cz"
    system "#{bin}/khost", "brew.sh"
    system "#{sbin}/knotc", "-c", "#{etc}/knot.conf", "checkconf"
  end
end
