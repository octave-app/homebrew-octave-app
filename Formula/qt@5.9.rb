# Qt 5.9 LTS is kept as a versioned formula because it's an LTS release, under support
# until May 2020.
# See https://github.com/Homebrew/homebrew-core/issues/35883
#
# Patches for Qt must be at the very least submitted to Qt's Gerrit codereview
# rather than their bug-report Jira. The latter is rarely reviewed by Qt.
class QtAT59 < Formula
  desc "Cross-platform application and UI framework, 5.9 LTS version"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.9/5.9.7/single/qt-everywhere-opensource-src-5.9.7.tar.xz"
  mirror "https://www.mirrorservice.org/sites/download.qt-project.org/official_releases/qt/5.9/5.9.7/single/qt-everywhere-opensource-src-5.9.7.tar.xz"
  sha256 "1c3852aa48b5a1310108382fb8f6185560cefc3802e81ecc099f4e62ee38516c"

  keg_only :versioned_formula

  depends_on "pkg-config" => :build
  depends_on :xcode => :build

  # Fix for upstream issue "macdeployqt does not work with Homebrew"
  # See https://bugreports.qt.io/browse/QTBUG-56814 and https://codereview.qt-project.org/#/c/180825/
  # Upstream commit from 23 Dec 2016 https://github.com/qt/qttools/commit/8f9b747f030bb41556831a23ec2a8e7e76fb7dc0#diff-2b6e250f93810fd9bcf9bbecf5d2be88
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/a627e0a/qt5/QTBUG-56814.patch"
    sha256 "b18e4715fcef2992f051790d3784a54900508c93350c25b0f2228cb058567142"
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
      -nomake examples
      -no-rpath
      -pkg-config
      -dbus-runtime
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
    We agreed to the Qt opensource license for you.
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