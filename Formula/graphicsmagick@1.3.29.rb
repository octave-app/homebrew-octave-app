class GraphicsmagickAT1329 < Formula
  desc "Image processing tools collection"
  homepage "http://www.graphicsmagick.org/"
  url "https://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.29/GraphicsMagick-1.3.29.tar.xz"
  sha256 "e18df46a6934c8c12bfe274d09f28b822f291877f9c81bd9a506f879a7610cd4"
  head "http://hg.code.sf.net/p/graphicsmagick/code", :using => :hg

  bottle do
    sha256 "1e5285484c31f3f5a0edfdb5457dddf114d5ef28d45e1e92c78494c07de5d621" => :high_sierra
    sha256 "c619357a47ac6dd35e16c13f053bc79399942d98a88ffbf278d5d7903972eeea" => :sierra
    sha256 "e95c6f9bc95dbb529a1bca6d88a9b2d0c0fc595632b6629e878e9d39d7cd644e" => :el_capitan
  end

  option "without-magick-plus-plus", "disable build/install of Magick++"
  option "without-svg", "Compile without svg support"
  option "with-perl", "Build PerlMagick; provides the Graphics::Magick module"

  depends_on "pkg-config@0.29.2" => :build
  depends_on "libtool@2.4.6"
  depends_on "jpeg@9c" => :recommended
  depends_on "libpng@1.6.34" => :recommended
  depends_on "libtiff@4.0.9" => :recommended
  depends_on "freetype@2.9.1" => :recommended
  depends_on "jasper@2.0.14" => :recommended
  depends_on "little-cms2@2.9" => :optional
  depends_on "libwmf@0.2.8.4" => :optional
  depends_on "ghostscript@9.23" => :optional
  depends_on "webp@1.0.0" => :optional
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
    args << "--without-magick-plus-plus" if build.without? "magick-plus-plus"
    args << "--with-perl" if build.with? "perl"
    args << "--with-webp=no" if build.without? "webp"
    args << "--without-x" if build.without? "x11"
    args << "--without-ttf" if build.without? "freetype"
    args << "--without-xml" if build.without? "svg"
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
