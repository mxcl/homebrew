require 'formula'

class Iodine < Formula
  url 'http://code.kryo.se/iodine/iodine-0.6.0-rc1.tar.gz'
  homepage 'http://code.kryo.se/iodine/'
  sha1 '4fa9a248b8a84df8a727a5d749e669e58136edca'

  def patches
    # Mountain Lion fix by @zschoche
    # https://github.com/yarrick/iodine/pull/1
    "https://github.com/zschoche/iodine/commit/e1e438497a83dbe6800212a0e5cb632907d1b3d9.patch"
  end

  def install
    system "make", "install", "prefix=#{prefix}"
  end
end
