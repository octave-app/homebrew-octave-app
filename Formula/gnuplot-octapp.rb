# Custom gnuplot that builds against our hacked qt-octapp instead of regular qt
#
# We use Qt 5. That means this formula is stuck on gnuplot 5.4.8 as of 2023-10-25, because
# I can't get 5.4.9 or 5.4.10 to build against qt@5 or our hacked qt formulae.
#
# As of 2023 and Octave 8.x, the core Homebrw octave formula has dropped its gnuplot
# dependency, with a note that upstream says gnuplot is unmaintained and problematic, and
# recommends just using Qt instead. See:
#  * https://github.com/Homebrew/homebrew-core/pull/138117
#
# TODO: Re-enable aquaterm support? Don't think we can really do that, since AquaTerm
# installs as a cask and not a regular formula.
class GnuplotOctapp < Formula
  desc "Command-driven, interactive function plotting, Octave.app-hacked variant"
  homepage "http://www.gnuplot.info/"
  url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.4.8/gnuplot-5.4.8.tar.gz"
  sha256 "931279c7caad1aff7d46cb4766f1ff41c26d9be9daf0bcf0c79deeee3d91f5cf"
  license "gnuplot"

  head do
    url "https://git.code.sf.net/p/gnuplot/gnuplot-main.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only "conflicts with regular gnuplot"

  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "gd"
  depends_on "libcerf"
  depends_on "lua"
  depends_on "pango"
  depends_on "qt-octapp_5"
  depends_on "readline"

  fails_with gcc: "5"

  def install
    args = %W[
      --disable-silent-rules
      --disable-wxwidgets
      --with-qt
      --with-readline=#{Formula["readline"].opt_prefix}
      --without-aquaterm
      --without-x
      --without-latex
      LRELEASE=#{Formula["qt-octapp_5"].bin}/lrelease
    ]

    # pkg-config files are not shipped on macOS, making our job harder
    # https://bugreports.qt.io/browse/QTBUG-86080
    # Hopefully in the future gnuplot can autodetect this information
    # https://sourceforge.net/p/gnuplot/feature-requests/560/
    qtcflags = []
    qtlibs = %W[-F#{Formula["qt-octapp_5"].opt_prefix}/Frameworks]
    # This list copied from the core formula is for Qt 6. Core5Compat is a Qt 5
    # back-compatibility thing, and not needed or present with Qt 5.
    # %w[Core Gui Network Svg PrintSupport Widgets Core5Compat].each do |m|
    %w[Core Gui Network Svg PrintSupport Widgets].each do |m|
      qtcflags << "-I#{Formula["qt-octapp_5"].opt_include}/Qt#{m}"
      qtlibs << "-framework Qt#{m}"
    end
    args += %W[
      QT_CFLAGS=#{qtcflags.join(" ")}
      QT_LIBS=#{qtlibs.join(" ")}
    ]

    # Qt5 requires c++11 (and the other backends do not care)
    ENV.cxx11

    system "./prepare" if build.head?
    system "./configure", *std_configure_args.reject { |s| s["--disable-debug"] },
                          *args
    ENV.deparallelize # or else emacs tries to edit the same file with two threads
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/gnuplot", "-e", <<~EOS
      set terminal dumb;
      set output "#{testpath}/graph.txt";
      plot sin(x);
    EOS
    assert_predicate testpath/"graph.txt", :exist?
  end
end
