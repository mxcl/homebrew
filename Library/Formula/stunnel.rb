class Stunnel < Formula
  homepage "https://www.stunnel.org/"
  url "https://www.stunnel.org/downloads/stunnel-5.17.tar.gz"
  mirror "https://www.usenix.org.uk/mirrors/stunnel/stunnel-5.17.tar.gz"
  sha256 "c3e79e582621a0827125e35e1c00450190104fc02dc3c5274cb02b05859fd472"

  bottle do
    sha256 "57166ae93bbec234f6de8998e5c3a7cdad61b2488101b4766a153885cdccd240" => :yosemite
    sha256 "3cb7bf5be69ab9cb39874022d380cc41fcfa33a921f3fde969d4f75430d9fd21" => :mavericks
    sha256 "56c367cba5a28375f086711335b9682af3d27f1242581ddd822602d89d28b546" => :mountain_lion
  end

  # Please revision me whenever OpenSSL is updated
  # "Update OpenSSL shared libraries or rebuild stunnel"
  depends_on "openssl"

  def install
    # This causes a bogus .pem to be created in lieu of interactive cert generation.
    stunnel_cnf = Pathname.new("tools/stunnel.cnf")
    stunnel_cnf.unlink
    stunnel_cnf.write <<-EOS.undent
      # OpenSSL configuration file to create a server certificate
      # by Michal Trojnara 1998-2015

      [ req ]
      # the default key length is secure and quite fast - do not change it
      default_bits                    = 2048
      # comment out the next line to protect the private key with a passphrase
      encrypt_key                     = no
      distinguished_name              = req_dn
      x509_extensions                 = cert_type
      prompt                          = no

      [ req_dn ]
      countryName                     = PL
      stateOrProvinceName             = Mazovia Province
      localityName                    = Warsaw
      organizationName                = Stunnel Developers
      organizationalUnitName          = Provisional CA
      0.commonName                    = localhost

      # To create a certificate for more than one name uncomment:
      # 1.commonName                  = DNS alias of your server
      # 2.commonName                  = DNS alias of your server
      # ...
      # See https://web.archive.org/web/20020207210031/http://home.netscape.com/eng/security/ssl_2.0_certificate.html
      # to see how Netscape understands commonName.

      [ cert_type ]
      nsCertType                      = server
    EOS

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}",
                          "--mandir=#{man}",
                          "--disable-libwrap",
                          "--disable-systemd",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install", "cert"
  end

  def caveats
    <<-EOS.undent
      A bogus SSL server certificate has been installed to:
        #{etc}/stunnel/stunnel.pem

      This certificate will be used by default unless a config file says otherwise!
      Stunnel will refuse to load the sample configuration file if left unedited.

      In your stunnel configuration, specify a SSL certificate with
      the "cert =" option for each service.
    EOS
  end

  test do
    (testpath/"tstunnel.conf").write <<-EOS.undent
      cert = #{etc}/stunnel/stunnel.pem

      setuid = nobody
      setgid = nobody

      [pop3s]
      accept  = 995
      connect = 110

      [imaps]
      accept  = 993
      connect = 143
    EOS

    assert_match /successful/, pipe_output("#{bin}/stunnel #{testpath}/tstunnel.conf 2>&1")
  end
end
