# Qt 5.14, hacked for Octave.app
#
# This formula is named qt_5.14 instead of qt@5.14 because having an "@" in the formula
# name causes a ninja build error.
class QtOctapp514 < Formula
  desc "Cross-platform application and UI framework, 5.14 version, Octave.app-hacked version"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.14/5.14.2/single/qt-everywhere-src-5.14.2.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/5.14/5.14.2/single/qt-everywhere-src-5.14.2.tar.xz"
  mirror "https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-5.14.2.tar.xz"
  sha256 "c6fcd53c744df89e7d3223c02838a33309bd1c291fcb6f9341505fe99f7f19fa"

  head "https://code.qt.io/qt/qt5.git", :branch => "dev", :shallow => false

  keg_only "versioned formula"

  depends_on "pkg-config" => :build
  depends_on :xcode => :build
  depends_on :macos => :sierra

  uses_from_macos "gperf" => :build
  uses_from_macos "bison"
  uses_from_macos "flex"
  uses_from_macos "sqlite"

  fails_with gcc: "5"

  # Octave.app-specific patches

  # Disable FSEventStreamFlushSync to avoid warnings in the GUI
  # See https://github.com/octave-app/octave-app-bundler/issues/13
  patch do
    url "https://raw.githubusercontent.com/octave-app/formula-patches/0ffa4aa98468b2355b5cc4424ed41cf869a0ee58/qt/disable-FSEventStreamFlushSync.patch"
    sha256 "f21a965257a567244e200c48eb5e81ebdf5e94900254c59b71340492a38e06fb"
  end

  # Regular patches also used in main Homebrew formula

  # Find SDK for 11.x macOS
  # Upstreamed, remove when Qt updates Chromium
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/92d4cf/qt/5.15.2.diff"
    sha256 "fa99c7ffb8a510d140c02694a11e6c321930f43797dbf2fe8f2476680db4c2b2"
  end

  # Fix build for GCC 11
  patch do
    url "https://invent.kde.org/qt/qt/qtbase/commit/8252ef5fc6d043004ddf7085e1c1fe1bf2ca39f7.patch"
    sha256 "8ab742b991ed5c43e8da4b1ce1982fd38fe611aaac3d57ee37728b59932b518a"
    directory "qtbase"
  end

  # Fix build for GCC 11
  patch do
    url "https://invent.kde.org/qt/qt/qtbase/commit/cb2da673f53815a5cfe15f50df49b98032429f9e.patch"
    sha256 "33304570431c0dd3becc22f3f0911ccfc781a1ce6c7926c3acb08278cd2e60c3"
    directory "qtbase"
  end

  # Fix build for GCC 11
  patch do
    url "https://invent.kde.org/qt/qt/qtdeclarative/commit/4f08a2da5b0da675cf6a75683a43a106f5a1e7b8.patch"
    sha256 "193c2e159eccc0592b7092b1e9ff31ad9556b38462d70633e507822f75d4d24a"
    directory "qtdeclarative"
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
      -nomake examples
      -nomake tests
      -no-rpath
      -pkg-config
      -dbus-runtime
      -proprietary-codecs
    ]

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
