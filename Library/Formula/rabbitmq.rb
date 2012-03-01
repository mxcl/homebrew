require 'formula'

class Rabbitmq < Formula
  homepage 'http://www.rabbitmq.com'
  url 'http://www.rabbitmq.com/releases/rabbitmq-server/v2.7.1/rabbitmq-server-2.7.1.tar.gz'
  md5 '44eb09d2dff8ce641a1fe7f255a4c546'

  depends_on 'erlang'
  depends_on 'simplejson' => :python if MacOS.leopard?

  def patches
      # Fixes build on 10.5, already fixed upstream but was not in 2.7.1 release
      DATA
  end

  def install
    # Building the manual requires additional software, so skip it.
    inreplace "Makefile", "install: install_bin install_docs", "install: install_bin"

    target_dir = "#{lib}/rabbitmq/erlang/lib/rabbitmq-#{version}"
    system "make"
    ENV['TARGET_DIR'] = target_dir
    ENV['MAN_DIR'] = man
    ENV['SBIN_DIR'] = sbin
    system "make install"

    (etc+'rabbitmq').mkpath
    (var+'lib/rabbitmq').mkpath
    (var+'log/rabbitmq').mkpath

    %w{rabbitmq-server rabbitmqctl rabbitmq-env rabbitmq-plugins}.each do |script|
      inreplace sbin+script do |s|
        s.gsub! '/etc/rabbitmq', "#{etc}/rabbitmq"
        s.gsub! '/var/lib/rabbitmq', "#{var}/lib/rabbitmq"
        s.gsub! '/var/log/rabbitmq', "#{var}/log/rabbitmq"
      end
    end

    # RabbitMQ Erlang binaries are installed in lib/rabbitmq/erlang/lib/rabbitmq-x.y.z/ebin
    # therefore need to add this path for erl -pa
    inreplace sbin+'rabbitmq-env', '${SCRIPT_DIR}/..', target_dir

    plist_path.write startup_plist
    plist_path.chmod 0644
  end

  def caveats
    <<-EOS.undent
    If this is your first install, automatically load on login with:
        mkdir -p ~/Library/LaunchAgents
        cp #{plist_path} ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/#{plist_path.basename}

    If this is an upgrade and you already have the #{plist_path.basename} loaded:
        launchctl unload -w ~/Library/LaunchAgents/#{plist_path.basename}
        cp #{plist_path} ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/#{plist_path.basename}

      To start rabbitmq-server manually:
        rabbitmq-server
    EOS
  end

  def startup_plist
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>#{plist_name}</string>
    <key>Program</key>
    <string>#{HOMEBREW_PREFIX}/sbin/rabbitmq-server</string>
    <key>RunAtLoad</key>
    <true/>
    <key>UserName</key>
    <string>#{`whoami`.chomp}</string>
    <!-- need erl in the path -->
    <key>EnvironmentVariables</key>
    <dict>
      <key>PATH</key>
      <string>/usr/local/sbin:/usr/bin:/bin:/usr/local/bin</string>
    </dict>
  </dict>
</plist>
    EOPLIST
  end
end

__END__
diff --git a/plugins-src/do-package.mk b/plugins-src/do-package.mk
index d7f8752..023042a 100644
--- a/plugins-src/do-package.mk
+++ b/plugins-src/do-package.mk
@@ -286,7 +286,7 @@ $(eval $(foreach D,$(TEST_SOURCE_DIRS),$(call package_source_dir_targets,$(D),$(
 define run_broker
 	rm -rf $(TEST_TMPDIR)
 	mkdir -p $(foreach D,log plugins $(NODENAME),$(TEST_TMPDIR)/$(D))
-	cp -a $(PACKAGE_DIR)/dist/*.ez $(TEST_TMPDIR)/plugins
+	cp -p $(PACKAGE_DIR)/dist/*.ez $(TEST_TMPDIR)/plugins
 	$(call copy,$(3),$(TEST_TMPDIR)/plugins)
 	rm -f $(TEST_TMPDIR)/plugins/rabbit_common*.ez
 	for plugin in \
@@ -375,7 +375,7 @@ $(APP_DONE): $(EBIN_BEAMS) $(INCLUDE_HRLS) $(APP_FILE) $(CONSTRUCT_APP_PREREQS)
 	mkdir -p $(APP_DIR)/ebin $(APP_DIR)/include
 	@echo [elided] copy beams to ebin
 	@$(call copy,$(EBIN_BEAMS),$(APP_DIR)/ebin)
-	cp -a $(APP_FILE) $(APP_DIR)/ebin/$(APP_NAME).app
+	cp -p $(APP_FILE) $(APP_DIR)/ebin/$(APP_NAME).app
 	$(call copy,$(INCLUDE_HRLS),$(APP_DIR)/include)
 	$(construct_app_commands)
 	touch $$@
