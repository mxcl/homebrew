class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/2.1/tmux-2.1.tar.gz"
  sha256 "31564e7bf4bcef2defb3cb34b9e596bd43a3937cad9e5438701a81a5a9af6176"

  bottle do
    cellar :any
    sha256 "165ad1037a3993fd12c745cdf77bdd31133c0e13188ede37096532dddb5591c6" => :el_capitan
    sha256 "44f62e8bed576ac82d5e2f768a6f3c6efb86fe7e45b37873d137294c8ef887b6" => :yosemite
    sha256 "9c0e2229d5acdb81fcaea40776b0841301167b10fcdb3af961e07dc2d2709317" => :mavericks
  end

  head do
    url "https://github.com/tmux/tmux.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libevent"

  # This fixes the Tmux 2.1 update that broke the ability to use select-pane [-LDUR]
  # to switch panes when in a maximized pane https://github.com/tmux/tmux/issues/150#issuecomment-149466158
  patch :DATA

  def install
    system "sh", "autogen.sh" if build.head?

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"

    system "make", "install"

    bash_completion.install "examples/bash_completion_tmux.sh" => "tmux"
    pkgshare.install "examples"
  end

  def caveats; <<-EOS.undent
    Example configurations have been installed to:
      #{pkgshare}/examples
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end

__END__
diff --git a/cmd-select-pane.c b/cmd-select-pane.c
index e76587c..7986e98 100644
--- a/cmd-select-pane.c
+++ b/cmd-select-pane.c
@@ -120,14 +120,19 @@ cmd_select_pane_exec(struct cmd *self, struct cmd_q *cmdq)
 		return (CMD_RETURN_NORMAL);
 	}

-	if (args_has(self->args, 'L'))
+	if (args_has(self->args, 'L')) {
+		server_unzoom_window(wp->window);
 		wp = window_pane_find_left(wp);
-	else if (args_has(self->args, 'R'))
+	} else if (args_has(self->args, 'R')) {
+		server_unzoom_window(wp->window);
 		wp = window_pane_find_right(wp);
-	else if (args_has(self->args, 'U'))
+	} else if (args_has(self->args, 'U')) {
+		server_unzoom_window(wp->window);
 		wp = window_pane_find_up(wp);
-	else if (args_has(self->args, 'D'))
+	} else if (args_has(self->args, 'D')) {
+		server_unzoom_window(wp->window);
 		wp = window_pane_find_down(wp);
+	}
 	if (wp == NULL)
 		return (CMD_RETURN_NORMAL);

