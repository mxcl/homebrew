require 'formula'

class Mysql < Formula
  homepage 'http://dev.mysql.com/doc/refman/5.5/en/'
  url 'http://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.25a.tar.gz/from/http://cdn.mysql.com/'
  version '5.5.25a'
  sha1 '85dfea413a7d5d2733a40f9dd79cf2320302979f'

  bottle do
    sha1 '31e9955a3a0a6dbc2baec8f1dade79257da428a8' => :mountainlion
    sha1 'b3cf78f7ddb812d38e376076e05020c0b412ee9c' => :lion
    sha1 '9f36132081d2b603c8aff4a7ee561962936892ec' => :snowleopard
  end

  depends_on 'cmake' => :build
  depends_on 'pidof' unless MacOS.mountain_lion?

  option :universal
  option 'with-tests', 'Build with unit tests'
  option 'with-embedded', 'Build the embedded server'
  option 'with-libedit', 'Compile with editline wrapper instead of readline'
  option 'with-archive-storage-engine', 'Compile with the ARCHIVE storage engine enabled'
  option 'with-blackhole-storage-engine', 'Compile with the BLACKHOLE storage engine enabled'
  option 'enable-local-infile', 'Build with local infile loading support'

  conflicts_with 'mariadb',
    :because => "mysql and mariadb install the same binaries."
  conflicts_with 'percona-server',
    :because => "mysql and percona-server install the same binaries."

  fails_with :llvm do
    build 2326
    cause "https://github.com/mxcl/homebrew/issues/issue/144"
  end

  skip_clean :all # So "INSTALL PLUGIN" can work.

  # Fix compilation with Xcode and no CLT: http://bugs.mysql.com/bug.php?id=66001
  def patches; DATA; end

  def install
    # Build without compiler or CPU specific optimization flags to facilitate
    # compilation of gems and other software that queries `mysql-config`.
    ENV.minimal_optimization

    # Make sure the var/mysql directory exists
    (var+"mysql").mkpath

    args = [".",
            "-DCMAKE_INSTALL_PREFIX=#{prefix}",
            "-DMYSQL_DATADIR=#{var}/mysql",
            "-DINSTALL_MANDIR=#{man}",
            "-DINSTALL_DOCDIR=#{doc}",
            "-DINSTALL_INFODIR=#{info}",
            # CMake prepends prefix, so use share.basename
            "-DINSTALL_MYSQLSHAREDIR=#{share.basename}/#{name}",
            "-DWITH_SSL=yes",
            "-DDEFAULT_CHARSET=utf8",
            "-DDEFAULT_COLLATION=utf8_general_ci",
            "-DSYSCONFDIR=#{etc}"]

    # To enable unit testing at build, we need to download the unit testing suite
    if build.include? 'with-tests'
      args << "-DENABLE_DOWNLOADS=ON"
    else
      args << "-DWITH_UNIT_TESTS=OFF"
    end

    # Build the embedded server
    args << "-DWITH_EMBEDDED_SERVER=ON" if build.include? 'with-embedded'

    # Compile with readline unless libedit is explicitly chosen
    args << "-DWITH_READLINE=yes" unless build.include? 'with-libedit'

    # Compile with ARCHIVE engine enabled if chosen
    args << "-DWITH_ARCHIVE_STORAGE_ENGINE=1" if build.include? 'with-archive-storage-engine'

    # Compile with BLACKHOLE engine enabled if chosen
    args << "-DWITH_BLACKHOLE_STORAGE_ENGINE=1" if build.include? 'with-blackhole-storage-engine'

    # Make universal for binding to universal applications
    args << "-DCMAKE_OSX_ARCHITECTURES='i386;x86_64'" if build.universal?

    # Build with local infile loading support
    args << "-DENABLED_LOCAL_INFILE=1" if build.include? 'enable-local-infile'

    system "cmake", *args
    system "make"
    system "make install"

    plist_path.write startup_plist
    plist_path.chmod 0644

    # Don't create databases inside of the prefix!
    # See: https://github.com/mxcl/homebrew/issues/4975
    rm_rf prefix+'data'

    # Link the setup script into bin
    ln_s prefix+'scripts/mysql_install_db', bin+'mysql_install_db'
    # Fix up the control script and link into bin
    inreplace "#{prefix}/support-files/mysql.server" do |s|
      s.gsub!(/^(PATH=".*)(")/, "\\1:#{HOMEBREW_PREFIX}/bin\\2")
      # pidof can be replaced with pgrep from proctools on Mountain Lion
      s.gsub!(/pidof/, 'pgrep') if MacOS.mountain_lion?
    end
    ln_s "#{prefix}/support-files/mysql.server", bin
  end

  def caveats; <<-EOS.undent
    Set up databases to run AS YOUR USER ACCOUNT with:
        unset TMPDIR
        mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=#{var}/mysql --tmpdir=/tmp

    To set up base tables in another folder, or use a different user to run
    mysqld, view the help for mysqld_install_db:
        mysql_install_db --help

    and view the MySQL documentation:
      * http://dev.mysql.com/doc/refman/5.5/en/mysql-install-db.html
      * http://dev.mysql.com/doc/refman/5.5/en/default-privileges.html

    To run as, for instance, user "mysql", you may need to `sudo`:
        sudo mysql_install_db ...options...

    Start mysqld manually with:
        mysql.server start

        Note: if this fails, you probably forgot to run the first two steps up above

    A "/etc/my.cnf" from another install may interfere with a Homebrew-built
    server starting up correctly.

    To connect:
        mysql -uroot

    To launch on startup:
    * if this is your first install:
        mkdir -p ~/Library/LaunchAgents
        cp #{plist_path} ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/#{plist_path.basename}

    * if this is an upgrade and you already have the #{plist_path.basename} loaded:
        launchctl unload -w ~/Library/LaunchAgents/#{plist_path.basename}
        cp #{plist_path} ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/#{plist_path.basename}

    You may also need to edit the plist to use the correct "UserName".

    EOS
  end

  def startup_plist; <<-EOPLIST.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>Program</key>
      <string>#{HOMEBREW_PREFIX}/bin/mysqld_safe</string>
      <key>RunAtLoad</key>
      <true/>
      <key>UserName</key>
      <string>#{`whoami`.chomp}</string>
      <key>WorkingDirectory</key>
      <string>#{var}</string>
    </dict>
    </plist>
    EOPLIST
  end
end

__END__
diff --git a/cmake/libutils.cmake b/cmake/libutils.cmake
index 89a9de9..677c68d 100644
--- a/cmake/libutils.cmake
+++ b/cmake/libutils.cmake
@@ -183,7 +183,7 @@ MACRO(MERGE_STATIC_LIBS TARGET OUTPUT_NAME LIBS_TO_MERGE)
       # binaries properly)
       ADD_CUSTOM_COMMAND(TARGET ${TARGET} POST_BUILD
         COMMAND rm ${TARGET_LOCATION}
-        COMMAND /usr/bin/libtool -static -o ${TARGET_LOCATION} 
+        COMMAND libtool -static -o ${TARGET_LOCATION} 
         ${STATIC_LIBS}
       )  
     ELSE()
