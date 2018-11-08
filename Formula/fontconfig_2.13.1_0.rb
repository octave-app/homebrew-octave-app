class Fontconfig21310 < Formula
  desc "XML-based font configuration API for X Windows"
  homepage "https://wiki.freedesktop.org/www/Software/fontconfig/"
  url "https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.1.tar.bz2"
  sha256 "f655dd2a986d7aa97e052261b36aa67b0a64989496361eca8d604e6414006741"

  # The bottle tooling is too lenient and thinks fontconfig
  # is relocatable, but it has hardcoded paths in the executables.
  

  pour_bottle? do
    reason "The bottle needs to be installed into /usr/local."
    # c.f. the identical hack in lua
    # https://github.com/Homebrew/homebrew/issues/47173
    satisfy { HOMEBREW_PREFIX.to_s == "/usr/local" }
  end

  head do
    url "https://anongit.freedesktop.org/git/fontconfig", :using => :git

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "freetype_2.9.1_0"

  def install
    font_dirs = %w[
      /System/Library/Fonts
      /Library/Fonts
      ~/Library/Fonts
    ]

    if MacOS.version >= :sierra
      font_dirs << Dir["/System/Library/Assets/com_apple_MobileAsset_Font*"].max
    end

    system "autoreconf", "-iv" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--enable-static",
                          "--with-add-fonts=#{font_dirs.join(",")}",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}"
    system "make", "install", "RUN_FC_CACHE_TEST=false"
  end

  def post_install
    ohai "Regenerating font cache, this may take a while"
    system "#{bin}/fc-cache", "-frv"
  end

  test do
    system "#{bin}/fc-list"
  end
end
