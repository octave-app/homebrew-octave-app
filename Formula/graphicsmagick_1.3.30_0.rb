class Graphicsmagick13300 < Formula
  desc "Image processing tools collection"
  homepage "http://www.graphicsmagick.org/"
  url "https://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.30/GraphicsMagick-1.3.30.tar.xz"
  sha256 "d965e5c6559f55eec76c20231c095d4ae682ea0cbdd8453249ae8771405659f1"
  head "http://hg.code.sf.net/p/graphicsmagick/code", :using => :hg

  

  option "with-perl", "Build PerlMagick; provides the Graphics::Magick module"

  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "freetype_2.9.1_0"
  depends_on "jasper_2.0.14_0"
  depends_on "jpeg_9c_0"
  depends_on "libpng_1.6.35_0"
  depends_on "libtiff_4.0.9_5"
  depends_on "libtool_2.4.6_1"
  depends_on "ghostscript_9.25_0" => :optional
  depends_on "libwmf_0.2.8.4_2" => :optional
  depends_on "little-cms2_2.9_0" => :optional
  depends_on "webp_1.0.0_0" => :optional
  depends_on :x11 => :optional

  skip_clean :la

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-shared
      --disable-static
      --with-modules
      --without-lzma
      --disable-openmp
      --with-quantum-depth=16
    ]

    args << "--without-gslib" if build.without? "ghostscript"
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" if build.without? "ghostscript"
    args << "--with-perl" if build.with? "perl"
    args << "--with-webp=no" if build.without? "webp"
    args << "--without-x" if build.without? "x11"
    args << "--without-lcms2" if build.without? "little-cms2"
    args << "--without-wmf" if build.without? "libwmf"

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
    if build.with? "perl"
      cd "PerlMagick" do
        # Install the module under the GraphicsMagick prefix
        system "perl", "Makefile.PL", "INSTALL_BASE=#{prefix}"
        system "make"
        system "make", "install"
      end
    end
  end

  def caveats
    if build.with? "perl"
      <<~EOS
        The Graphics::Magick perl module has been installed under:

          #{lib}

      EOS
    end
  end

  test do
    fixture = test_fixtures("test.png")
    assert_match "PNG 8x8+0+0", shell_output("#{bin}/gm identify #{fixture}")
  end
end
