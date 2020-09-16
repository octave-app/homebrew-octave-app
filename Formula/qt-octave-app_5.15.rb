# Qt 5.15 LTS, hacked for Octave.app
#
# This formula is named qt-octave-app_5.15 instead of qt-octave-app@5.15 because having an "@" in the formula
# name causes a ninja build error.
class QtOctaveApp515 < Formula
  desc "Cross-platform application and UI framework, 5.15 version, Octave.app-hacked version"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.15/5.15.1/single/qt-everywhere-src-5.15.1.tar.xz"
  mirror "https://mirrors.dotsrc.org/qtproject/archive/qt/5.15/5.15.1/single/qt-everywhere-src-5.15.1.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/qt/archive/qt/5.15/5.15.1/single/qt-everywhere-src-5.15.1.tar.xz"
  sha256 "44da876057e21e1be42de31facd99be7d5f9f07893e1ea762359bcee0ef64ee9"

  head "https://code.qt.io/qt/qt5.git", :branch => "dev", :shallow => false

  keg_only "versioned formula"

  depends_on "pkg-config" => :build
  depends_on :xcode => :build
  depends_on :macos => :sierra

  # Disable FSEventStreamFlushSync to avoid warnings in the GUI
  # See https://github.com/octave-app/octave-app-bundler/issues/13
  patch do
    url "https://raw.githubusercontent.com/octave-app/formula-patches/0ffa4aa98468b2355b5cc4424ed41cf869a0ee58/qt/disable-FSEventStreamFlushSync.patch"
    sha256 "f21a965257a567244e200c48eb5e81ebdf5e94900254c59b71340492a38e06fb"
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

    # Remove reference to shims directory
    inreplace "qtbase/mkspecs/qmodule.pri",
              /^PKG_CONFIG_EXECUTABLE = .*$/,
              "PKG_CONFIG_EXECUTABLE = #{Formula["pkg-config"].opt_bin/"pkg-config"}"

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
