# Qt, hacked for Octave.app
#
# Our hack just suppresses an "FSEvents assertion failure" warning message. Nothing
# else; a shame we have to pay for the whole Qt build for it.
#
# This formula will track the version of Qt we're using for Octave.app builds, which
# might be the LTS version, the latest version, or something else, depending on what
# works best for Octave.app.
class QtOctaveApp < Formula
  desc "Cross-platform application and UI framework, Octave.app-hacked version"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.12/5.12.7/single/qt-everywhere-src-5.12.7.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/5.12/5.12.7/single/qt-everywhere-src-5.12.7.tar.xz"
  mirror "https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-5.12.7.tar.xz"
  sha256 "873783a0302129d98a8f63de9afe4520fb5f8d5316be8ad7b760c59875cd8a8d"
  head "https://code.qt.io/qt/qt5.git", :branch => "5.12", :shallow => false

  keg_only "Qt 5 has CMake issues when linked"

  option "with-docs", "Build documentation"
  option "with-examples", "Build examples"
  option "without-proprietary-codecs", "Don't build with proprietary codecs (e.g. mp3)"

  deprecated_option "with-mysql" => "with-mysql-client"

  depends_on "pkg-config" => :build
  depends_on :xcode => :build
  depends_on "mysql-client" => :optional
  depends_on "postgresql" => :optional

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
      -nomake tests
      -no-rpath
      -pkg-config
      -dbus-runtime
      -proprietary-codecs
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

    if build.with? "docs"
      system "make", "docs"
      system "make", "install_docs"
    end

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
