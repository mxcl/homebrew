require 'formula'

class Pango < Formula
  homepage 'http://www.pango.org/'
  url 'http://ftp.gnome.org/pub/GNOME/sources/pango/1.28/pango-1.28.4.tar.bz2'
  sha256 '7eb035bcc10dd01569a214d5e2bc3437de95d9ac1cfa9f50035a687c45f05a9f'

  depends_on 'pkg-config' => :build
  depends_on 'glib'

  fails_with_llvm "Undefined symbols when linking", :build => "2326"

  if MacOS.leopard?
    depends_on 'fontconfig' # Leopard's fontconfig is too old.
    depends_on 'cairo' # Leopard doesn't come with Cairo.
  elsif MacOS.lion?
    depends_on 'cairo' # links against system Cairo without this
  end

  def options
    [
      ["--universal", "Builds a universal binary"],
      ["--quartz", "Builds with Quartz instead of X."]
    ]
  end

  def install
    if ARGV.build_universal?
      ENV.universal_binary
      ENV.append 'LDFLAGS', '-no-undefined -bind_at_load'
    end
    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]
    
    if ARGV.include? '--quartz'
      args << "--without-x" << "--enable-static" << "--disable-introspection"
    else
      args << "--with-x"
    end
    
    system "./configure", *args
    system "make install"
  end
  
  def caveats
    "Pango may need to be intalled with --quartz if you want any of its dependencies to have quartz."
  end
end
