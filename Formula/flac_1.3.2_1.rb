class Flac1321 < Formula
  desc "Free lossless audio codec"
  homepage "https://xiph.org/flac/"
  url "https://downloads.xiph.org/releases/flac/flac-1.3.2.tar.xz"
  mirror "https://downloads.sourceforge.net/project/flac/flac-src/flac-1.3.2.tar.xz"
  sha256 "91cfc3ed61dc40f47f050a109b08610667d73477af6ef36dcad31c31a4a8d53f"
  revision 1

  

  head do
    url "https://git.xiph.org/flac.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "libogg_1.3.3_0"

  fails_with :clang do
    build 500
    cause "Undefined symbols ___cpuid and ___cpuid_count"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-debug
      --prefix=#{prefix}
      --enable-static
    ]

    args << "--disable-asm-optimizations" if Hardware::CPU.is_32_bit?

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/flac", "--decode", "--force-raw", "--endian=little", "--sign=signed", "--output-name=out.raw", test_fixtures("test.flac")
    system "#{bin}/flac", "--endian=little", "--sign=signed", "--channels=1", "--bps=8", "--sample-rate=8000", "--output-name=out.flac", "out.raw"
  end
end
