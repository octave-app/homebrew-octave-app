# Variant of gnuplot that builds against Qt 5 (qt@5) instead of Qt 6 (qt).
# Otherwise, does not have Octave.app-specific hacks. Uses the vanilla qt@5 from
# core Homebrew instead of the Octave.app-hacked Qt.
# Keeps up with the latest gnuplot version that will build against Qt 5, which as of
# 2023-10-25 is 5.4.8.
#
# Gnuplot 5.4.9 added Qt 6 support. I can't get it or 5.4.10 to build against Qt 5, so
# I'm sticking with 5.4.8 for now.
#
# This breakage with Gnuplot 5.4.9 and 5.4.10 seems because it tries to call uic-qt6:
#
# clang  -g -O2  -L/usr/local/Cellar/libcerf/2.4/lib -lcerf -L/usr/local/opt/readline/lib  -o bf_test bf_test.o -lm
# uic-qt6 -o ui_QtGnuplotSettings.h qtterminal/QtGnuplotSettings.ui
# make[4]: uic-qt6: No such file or directory
# make[4]: *** [ui_QtGnuplotSettings.h] Error 1
# make[3]: *** [all-recursive] Error 1

class GnuplotQt5 < Formula
  desc "Command-driven, interactive function plotting, Qt 5 variant"
  homepage "http://www.gnuplot.info/"
  # url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.4.10/gnuplot-5.4.10.tar.gz"
  # sha256 "975d8c1cc2c41c7cedc4e323aff035d977feb9a97f0296dd2a8a66d197a5b27c"
  # url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.4.9/gnuplot-5.4.9.tar.gz"
  # sha256 "a328a021f53dc05459be6066020e9a71e8eab6255d3381e22696120d465c6a97"
  url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.4.8/gnuplot-5.4.8.tar.gz"
  sha256 "931279c7caad1aff7d46cb4766f1ff41c26d9be9daf0bcf0c79deeee3d91f5cf"
  license "gnuplot"

  livecheck do
    url :stable
    regex(%r{url=.*?/gnuplot[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

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
  depends_on "qt@5"
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
      LRELEASE=#{Formula["qt@5"].bin}/lrelease
    ]

    if OS.mac?
      # pkg-config files are not shipped on macOS, making our job harder
      # https://bugreports.qt.io/browse/QTBUG-86080
      # Hopefully in the future gnuplot can autodetect this information
      # https://sourceforge.net/p/gnuplot/feature-requests/560/
      qtcflags = []
      qtlibs = %W[-F#{Formula["qt@5"].opt_prefix}/Frameworks]
      # This list copied from the core formula is for Qt 6. Core5Compat is a Qt 5
      # back-compatibility thing, and not needed or present with Qt 5.
      # %w[Core Gui Network Svg PrintSupport Widgets Core5Compat].each do |m|
      %w[Core Gui Network Svg PrintSupport Widgets].each do |m|
        qtcflags << "-I#{Formula["qt@5"].opt_include}/Qt#{m}"
        qtlibs << "-framework Qt#{m}"
      end
      args += %W[
        QT_CFLAGS=#{qtcflags.join(" ")}
        QT_LIBS=#{qtlibs.join(" ")}
      ]
    end

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
