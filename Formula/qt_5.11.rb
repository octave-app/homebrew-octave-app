# Qt 5.11 is kept as a versioned formula because our 4.4.1 release line was built
# against 5.11.
#
# Qt 5.11 is out of support. Per https://www.qt.io/blog/2018/05/22/qt-5-11-released, it was
# released on May 22, 2019, so its support ran out in May 2019.
# Our qt_5.11 formula is kept at version 5.11.2, even though there's a 5.11.3 out, because
# the Qt 5.11.3 build fails for us. As Qt 5.11 is EOL, there's no fix forthcoming, so we'll
# just sit on 5.11.2.
#
# This is named "qt_5.11" instead of "qt@5.11" because having an "@" in the
# formula name breaks the build, due to some ninja problem in Qt's build
# system.
# https://github.com/octave-app/octave-app/issues/143
# https://bugreports.qt.io/browse/QTBUG-79711

class Qt511 < Formula
  desc "Cross-platform application and UI framework, 5.11 version"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.11/5.11.2/single/qt-everywhere-src-5.11.2.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/5.11/5.11.2/single/qt-everywhere-src-5.11.2.tar.xz"
  mirror "https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-5.11.2.tar.xz"
  sha256 "c6104b840b6caee596fa9a35bc5f57f67ed5a99d6a36497b6fe66f990a53ca81"

  keg_only "versioned formula"

  option "with-examples", "Build examples"
  option "without-proprietary-codecs", "Don't build with proprietary codecs (e.g. mp3)"

  deprecated_option "with-mysql" => "with-mysql-client"

  depends_on "pkg-config" => :build
  depends_on :xcode => :build
  depends_on "mysql-client" => :optional
  depends_on "postgresql" => :optional

  # Restore `.pc` files for framework-based build of Qt 5 on macOS, partially
  # reverting <https://codereview.qt-project.org/#/c/140954/>
  # Core formulae known to fail without this patch (as of 2016-10-15):
  #   * gnuplot (with `--with-qt` option)
  #   * mkvtoolnix (with `--with-qt` option, silent build failure)
  #   * poppler (with `--with-qt` option)
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/e8fe6567/qt5/restore-pc-files.patch"
    sha256 "48ff18be2f4050de7288bddbae7f47e949512ac4bcd126c2f504be2ac701158b"
  end

  # Chromium build failures with Xcode 10, fixed upstream:
  # https://github.com/octave-app/octave-app/issues/136
  # https://bugs.chromium.org/p/chromium/issues/detail?id=840251
  # https://bugs.chromium.org/p/chromium/issues/detail?id=849689
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/962f0f/qt/xcode10.diff"
    sha256 "c064398411c69f2e1c516c0cd49fcd0755bc29bb19e65c5694c6d726c43389a6"
  end

  def install
    args = %W[
      -verbose
      -prefix #{prefix}
      -release
      -opensource -confirm-license
      -system-zlib
      -qt-libpng
      -qt-libjpeg
      -qt-freetype
      -qt-pcre
      -nomake tests
      -no-rpath
      -pkg-config
      -dbus-runtime
    ]

    args << "-nomake" << "examples" if build.without? "examples"

    if build.with? "mysql-client"
      args << "-plugin-sql-mysql"
      (buildpath/"brew_shim/mysql_config").write <<~EOS
        #!/bin/sh
        if [ x"$1" = x"--libs" ]; then
          mysql_config --libs | sed "s/-lssl -lcrypto//"
        else
          exec mysql_config "$@"
        fi
      EOS
      chmod 0755, "brew_shim/mysql_config"
      args << "-mysql_config" << buildpath/"brew_shim/mysql_config"
    end

    args << "-plugin-sql-psql" if build.with? "postgresql"
    args << "-proprietary-codecs" if build.with? "proprietary-codecs"

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # Move `*.app` bundles into `libexec` to expose them to `brew linkapps` and
    # because we don't like having them in `bin`.
    # (Note: This move breaks invocation of Assistant via the Help menu
    # of both Designer and Linguist as that relies on Assistant being in `bin`.)
    libexec.mkpath
    Pathname.glob("#{bin}/*.app") { |app| mv app, libexec }
  end

  def caveats; <<~EOS
    We agreed to the Qt open source license for you.
    If this is unacceptable you should uninstall.
  EOS
  end

  test do
    (testpath/"hello.pro").write <<~EOS
      QT       += core
      QT       -= gui
      TARGET = hello
      CONFIG   += console
      CONFIG   -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    EOS

    (testpath/"main.cpp").write <<~EOS
      #include <QCoreApplication>
      #include <QDebug>

      int main(int argc, char *argv[])
      {
        QCoreApplication a(argc, argv);
        qDebug() << "Hello World!";
        return 0;
      }
    EOS

    system bin/"qmake", testpath/"hello.pro"
    system "make"
    assert_predicate testpath/"hello", :exist?
    assert_predicate testpath/"main.o", :exist?
    system "./hello"
  end
end