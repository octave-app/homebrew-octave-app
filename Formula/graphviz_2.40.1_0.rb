class Graphviz24010 < Formula
  desc "Graph visualization software from AT&T and Bell Labs"
  homepage "https://www.graphviz.org/"
  # versioned URLs are missing upstream as of 16 Dec 2017
  url "https://www.mirrorservice.org/sites/distfiles.macports.org/graphviz/graphviz-2.40.1.tar.gz"
  mirror "https://fossies.org/linux/misc/graphviz-2.40.1.tar.gz"
  sha256 "ca5218fade0204d59947126c38439f432853543b0818d9d728c589dfe7f3a421"
  version_scheme 1

  

  head do
    url "https://gitlab.com/graphviz/graphviz.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool_2.4.6_1" => :build
  end

  option "with-app", "Build GraphViz.app (requires full XCode install)"
  option "with-gts", "Build with GNU GTS support (required by prism)"
  option "with-pango", "Build with Pango/Cairo for alternate PDF output"

  deprecated_option "with-pangocairo" => "with-pango"

  depends_on "pkg-config_0.29.2_0" => :build
  depends_on :xcode => :build if build.with? "app"
  depends_on "gd_2.2.5_0"
  depends_on "libpng_1.6.35_0"
  depends_on "libtool_2.4.6_1"
  depends_on "gts_0.7.6_0" => :optional
  depends_on "librsvg_2.44.8_0" => :optional
  depends_on "pango_1.42.4_0" => :optional

  def install
    # Only needed when using superenv, which causes qfrexp and qldexp to be
    # falsely detected as available. The problem is triggered by
    #   args << "-#{ENV["HOMEBREW_OPTIMIZATION_LEVEL"]}"
    # during argument refurbishment of cflags.
    # https://github.com/Homebrew/brew/blob/ab060c9/Library/Homebrew/shims/super/cc#L241
    # https://github.com/Homebrew/legacy-homebrew/issues/14566
    # Alternative fixes include using stdenv or using "xcrun make"
    inreplace "lib/sfio/features/sfio", "lib qfrexp\nlib qldexp\n", "" unless build.head?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-php
      --disable-swig
      --with-quartz
      --without-freetype2
      --without-qt
      --without-x
    ]
    args << "--with-gts" if build.with? "gts"
    args << "--without-pangocairo" if build.without? "pango"
    args << "--without-rsvg" if build.without? "librsvg"

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"

    if build.with? "app"
      cd "macosx" do
        xcodebuild "SDKROOT=#{MacOS.sdk_path}", "-configuration", "Release", "SYMROOT=build", "PREFIX=#{prefix}",
                   "ONLY_ACTIVE_ARCH=YES", "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
      end
      prefix.install "macosx/build/Release/Graphviz.app"
    end

    (bin/"gvmap.sh").unlink
  end

  test do
    (testpath/"sample.dot").write <<~EOS
      digraph G {
        a -> b
      }
    EOS

    system "#{bin}/dot", "-Tpdf", "-o", "sample.pdf", "sample.dot"
  end
end
