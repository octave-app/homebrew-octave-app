# Qt 5.15.12, hacked for Octave.app
#
# This formula is named qt-octapp_5.15.12 instead of qt-octapp@5.15.12 because having an "@" in the formula
# name causes a ninja build error.
#
# We're retaining 5.15.12 as a separate formula because I'm having trouble getting
# 5.15.13 and later to build (and even 5.15.12 in its revised formula), so keeping
# this 5.15.12 formula around as a reference. This copy was grabbed from commit
# 246663953, before the later Octave 8.x changes in 2024 Q1 (on branch lets-go-8-4-oh),
# and I think was building okay at that point. So this is an older state of the formula
# than what'sin qt-octapp_5, even though that one is on 5.15.12 as well. Once that one
# gets all fixed up and is building reliably, its changes should probably be backported
# here.

class QtOctapp51512 < Formula
  desc "Cross-platform application and UI framework, 5.15.12 version, Octave.app-hacked"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.15/5.15.12/single/qt-everywhere-opensource-src-5.15.12.tar.xz"
  mirror "https://mirrors.dotsrc.org/qtproject/archive/qt/5.15/5.15.12/single/qt-everywhere-opensource-src-5.15.12.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/qt/archive/qt/5.15/5.15.12/single/qt-everywhere-opensource-src-5.15.12.tar.xz"
  sha256 "93f2c0889ee2e9cdf30c170d353c3f829de5f29ba21c119167dee5995e48ccce"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  livecheck do
    url "https://download.qt.io/official_releases/qt/5.15/"
    regex(%r{href=["']?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  keg_only :versioned_formula

  depends_on "node" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.11" => :build # NOTE: Python 3.12+ would need additional backports due to imp usage
  depends_on xcode: :build
  depends_on "freetype"
  depends_on "glib"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on macos: :sierra
  depends_on "pcre2"
  depends_on "webp"

  uses_from_macos "gperf" => :build
  uses_from_macos "bison"
  uses_from_macos "flex"
  uses_from_macos "krb5"
  uses_from_macos "libxslt"
  uses_from_macos "sqlite"

  fails_with gcc: "5"

  # Octave.app-specific hacks and patches

  # Disable FSEventStreamFlushSync to avoid warnings in the GUI
  # See https://github.com/octave-app/octave-app-bundler/issues/13
  patch do
    url "https://raw.githubusercontent.com/octave-app/formula-patches/0ffa4aa98468b2355b5cc4424ed41cf869a0ee58/qt/disable-FSEventStreamFlushSync.patch"
    sha256 "f21a965257a567244e200c48eb5e81ebdf5e94900254c59b71340492a38e06fb"
  end

  # End Octave.app-specific hacks and patches

  resource "qtwebengine" do
    url "https://code.qt.io/qt/qtwebengine.git",
        tag:      "v5.15.11-lts",
        revision: "3d23b379a7c0a87922f9f5d9600fde8c4e58f1fd"

    # Add Python 3 support to qt-webengine-chromium.
    # Submitted upstream here: https://codereview.qt-project.org/c/qt/qtwebengine-chromium/+/416534
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/7ae178a617d1e0eceb742557e63721af949bd28a/qt5/qt5-webengine-chromium-python3.patch?full_index=1"
      sha256 "a93aa8ef83f0cf54f820daf5668574cc24cf818fb9589af2100b363356eb6b49"
      directory "src/3rdparty"
    end

    # Add Python 3 support to qt-webengine.
    # Submitted upstream here: https://codereview.qt-project.org/c/qt/qtwebengine/+/416535
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/a6f16c6daea3b5a1f7bc9f175d1645922c131563/qt5/qt5-webengine-python3.patch?full_index=1"
      sha256 "398c996cb5b606695ac93645143df39e23fa67e768b09e0da6dbd37342a43f32"
    end

    # Fix build of qt-webengine-chromium with newer GCC.
    # Submitted upstream here: https://codereview.qt-project.org/c/qt/qtwebengine-chromium/+/416598
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/a6f16c6daea3b5a1f7bc9f175d1645922c131563/qt5/qt5-webengine-gcc12.patch?full_index=1"
      sha256 "cf9be3ffcc3b3cd9450b1ff13535ff7d76284f73173412d097a6ab487463a379"
      directory "src/3rdparty"
    end

    # Fix build for Xcode 14
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/405b6b7ca7b95860ee70368076382b171a1c66f4/qt5/qt5-webengine-xcode14.diff"
      sha256 "142c4fb11dca6c0bbc86ca8f74410447c23be1b1d314758515bfda20afa6f612"
      directory "src/3rdparty"
    end

    # Fix ffmpeg build with binutils
    # https://www.linuxquestions.org/questions/slackware-14/regression-on-current-with-ffmpeg-4175727691/
    patch :DATA
  end

  # Update catapult to a revision that supports Python 3.
  resource "catapult" do
    url "https://chromium.googlesource.com/catapult.git",
        revision: "5eedfe23148a234211ba477f76fc2ea2e8529189"
  end

  # Fix build with Xcode 14.3.
  # https://bugreports.qt.io/browse/QTBUG-112906
  patch do
    url "https://invent.kde.org/qt/qt/qtlocation-mapboxgl/-/commit/5a07e1967dcc925d9def47accadae991436b9686.diff"
    sha256 "4f433bb009087d3fe51e3eec3eee6e33a51fde5c37712935b9ab96a7d7571e7d"
    directory "qtlocation/src/3rdparty/mapbox-gl-native"
  end

  # Fix qmake with Xcode 15.
  # https://bugreports.qt.io/browse/QTBUG-117225
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/086e8cf/qt5/qt5-qmake-xcode15.patch"
    sha256 "802f29c2ccb846afa219f14876d9a1d67477ff90200befc2d0c5759c5081c613"
  end

  # Fix qtmultimedia build with Xcode 15
  # https://bugreports.qt.io/browse/QTBUG-113782
  # https://github.com/hmaarrfk/qt-main-feedstock/blob/0758b98854a3a3b9c99cded856176e96c9b8c0c5/recipe/patches/0014-remove-usage-of-unary-operator.patch
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/3f509180/qt5/qt5-qtmultimedia-xcode15.patch"
    sha256 "887d6cb4fd115ce82323d17e69fafa606c51cef98c820b82309ab38288f21e08"
  end

  def install
    (buildpath/"qtwebengine").rmtree
    (buildpath/"qtwebengine").install resource("qtwebengine")

    (buildpath/"qtwebengine/src/3rdparty/chromium/third_party/catapult").rmtree
    (buildpath/"qtwebengine/src/3rdparty/chromium/third_party/catapult").install resource("catapult")

    # FIXME: GN requires clang in clangBasePath/bin
    inreplace "qtwebengine/src/3rdparty/chromium/build/toolchain/mac/BUILD.gn",
              'rebase_path("$clang_base_path/bin/", root_build_dir)', '""'

    #TODO: (octapp) Switch qt-* to system-* for lib deps, like core formula does?
    args = %W[
      -verbose
      -prefix #{prefix}
      -release
      -opensource -confirm-license
      -nomake examples
      -nomake tests
      -pkg-config
      -dbus-runtime
      -proprietary-codecs
      -system-zlib
      -qt-libpng
      -qt-libjpeg
      -qt-freetype
      -qt-pcre
    ]

    if OS.mac?
      args << "-no-rpath"
      args << "-no-assimp" if Hardware::CPU.arm?

      # Modify Assistant path as we manually move `*.app` bundles from `bin` to `libexec`.
      # This fixes invocation of Assistant via the Help menu of apps like Designer and
      # Linguist as they originally relied on Assistant.app being in `bin`.
      assistant_files = %w[
        qttools/src/designer/src/designer/assistantclient.cpp
        qttools/src/linguist/linguist/mainwindow.cpp
      ]
      inreplace assistant_files, '"Assistant.app/Contents/MacOS/Assistant"', '"Assistant"'
    else
      args << "-R#{lib}"
      # https://bugreports.qt.io/browse/QTBUG-71564
      args << "-no-avx2"
      args << "-no-avx512"
      args << "-no-sql-mysql"

      # Use additional system libraries on Linux.
      # Currently we have to use vendored ffmpeg because the chromium copy adds a symbol not
      # provided by the brewed version.
      # See here for an explanation of why upstream ffmpeg does not want to add this:
      # https://www.mail-archive.com/ffmpeg-devel@ffmpeg.org/msg124998.html
      # On macOS chromium will always use bundled copies and the webengine_*
      # arguments are ignored.
      args += %w[
        -system-harfbuzz
        -webengine-alsa
        -webengine-icu
        -webengine-kerberos
        -webengine-opus
        -webengine-pulseaudio
        -webengine-webp
      ]

      # Homebrew-specific workaround to ignore spurious linker warnings on Linux.
      inreplace "qtwebengine/src/3rdparty/chromium/build/config/compiler/BUILD.gn",
                "fatal_linker_warnings = true",
                "fatal_linker_warnings = false"
    end

    # Work around Clang failure in bundled Boost and V8:
    # error: integer value -1 is outside the valid range of values [0, 3] for this enumeration type
    if DevelopmentTools.clang_build_version >= 1500
      args << "QMAKE_CXXFLAGS+=-Wno-enum-constexpr-conversion"
      inreplace "qtwebengine/src/3rdparty/chromium/build/config/compiler/BUILD.gn",
                /^\s*"-Wno-thread-safety-attributes",$/,
                "\\0 \"-Wno-enum-constexpr-conversion\","
    end

    ENV.prepend_path "PATH", Formula["python@3.10"].libexec/"bin"
    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # Remove reference to shims directory
    inreplace prefix/"mkspecs/qmodule.pri",
              /^PKG_CONFIG_EXECUTABLE = .*$/,
              "PKG_CONFIG_EXECUTABLE = #{Formula["pkg-config"].opt_bin}/pkg-config"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # Install a qtversion.xml to ease integration with QtCreator
    # As far as we can tell, there is no ability to make the Qt buildsystem
    # generate this and it's in the Qt source tarball at all.
    # Multiple people on StackOverflow have asked for this and it's a pain
    # to add Qt to QtCreator (the official IDE) without it.
    # Given Qt upstream seems extremely unlikely to accept this: let's ship our
    # own version.
    # If you read this and you can eliminate it or upstream it: please do!
    # More context in https://github.com/Homebrew/homebrew-core/pull/124923
    qtversion_xml = share/"qtcreator/QtProject/qtcreator/qtversion.xml"
    qtversion_xml.dirname.mkpath
    qtversion_xml.write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE QtCreatorQtVersions>
      <qtcreator>
      <data>
        <variable>QtVersion.0</variable>
        <valuemap type="QVariantMap">
        <value type="int" key="Id">1</value>
        <value type="QString" key="Name">Qt %{Qt:Version} (#{opt_prefix})</value>
        <value type="QString" key="QMakePath">#{opt_bin}/qmake</value>
        <value type="QString" key="QtVersion.Type">Qt4ProjectManager.QtVersion.Desktop</value>
        <value type="QString" key="autodetectionSource"></value>
        <value type="bool" key="isAutodetected">false</value>
        </valuemap>
      </data>
      <data>
        <variable>Version</variable>
        <value type="int">1</value>
      </data>
      </qtcreator>
    XML

    return unless OS.mac?

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    lib.glob("*.framework") do |f|
      # Some config scripts will only find Qt in a "Frameworks" folder
      frameworks.install_symlink f
      include.install_symlink f/"Headers" => f.stem
    end

    # Move `*.app` bundles into `libexec` to expose them to `brew linkapps` and
    # because we don't like having them in `bin`.
    bin.glob("*.app") do |app|
      libexec.install app
      bin.write_exec_script libexec/app.basename/"Contents/MacOS"/app.stem
    end

    # Fix find_package call using QtWebEngine version to find other Qt5 modules.
    inreplace Dir[lib/"cmake/Qt5WebEngine*/*Config.cmake"],
              " #{resource("qtwebengine").version} ", " #{version} "
  end

  def caveats
    <<~EOS
      We agreed to the Qt open source license for you.
      If this is unacceptable you should uninstall.

      You can add Homebrew's Qt to QtCreator's "Qt Versions" in:
        Preferences > Qt Versions > Link with Qt...
      pressing "Choose..." and selecting as the Qt installation path:
        #{opt_prefix}

      This Qt build contains special patches for Octave.app.
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

    # Work around "error: no member named 'signbit' in the global namespace"
    ENV.delete "CPATH"

    system bin/"qmake", testpath/"hello.pro"
    system "make"
    assert_predicate testpath/"hello", :exist?
    assert_predicate testpath/"main.o", :exist?
    system "./hello"
  end
end


__END__
From effadce6c756247ea8bae32dc13bb3e6f464f0eb Mon Sep 17 00:00:00 2001
From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Date: Sun, 16 Jul 2023 18:18:02 +0300
Subject: [PATCH] avcodec/x86/mathops: clip constants used with shift
 instructions within inline assembly

Fixes assembling with binutil as >= 2.41

Signed-off-by: James Almer <jamrial@gmail.com>
---
 src/3rdparty/chromium/third_party/ffmpeg/libavcodec/x86/mathops.h | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/src/3rdparty/chromium/third_party/ffmpeg/libavcodec/x86/mathops.h b/src/3rdparty/chromium/third_party/ffmpeg/libavcodec/x86/mathops.h
index 6298f5ed1983b84205479d1a714bd657435789f9..ca7e2dffc1076f82d2cabf55eae0681adbdcfb96 100644
--- a/src/3rdparty/chromium/third_party/ffmpeg/libavcodec/x86/mathops.h
+++ b/src/3rdparty/chromium/third_party/ffmpeg/libavcodec/x86/mathops.h
@@ -35,12 +35,20 @@
 static av_always_inline av_const int MULL(int a, int b, unsigned shift)
 {
     int rt, dummy;
+    if (__builtin_constant_p(shift))
     __asm__ (
         "imull %3               \n\t"
         "shrdl %4, %%edx, %%eax \n\t"
         :"=a"(rt), "=d"(dummy)
-        :"a"(a), "rm"(b), "ci"((uint8_t)shift)
+        :"a"(a), "rm"(b), "i"(shift & 0x1F)
     );
+    else
+        __asm__ (
+            "imull %3               \n\t"
+            "shrdl %4, %%edx, %%eax \n\t"
+            :"=a"(rt), "=d"(dummy)
+            :"a"(a), "rm"(b), "c"((uint8_t)shift)
+        );
     return rt;
 }

@@ -113,19 +121,31 @@ __asm__ volatile(\
 // avoid +32 for shift optimization (gcc should do that ...)
 #define NEG_SSR32 NEG_SSR32
 static inline  int32_t NEG_SSR32( int32_t a, int8_t s){
+    if (__builtin_constant_p(s))
     __asm__ ("sarl %1, %0\n\t"
          : "+r" (a)
-         : "ic" ((uint8_t)(-s))
+         : "i" (-s & 0x1F)
     );
+    else
+        __asm__ ("sarl %1, %0\n\t"
+               : "+r" (a)
+               : "c" ((uint8_t)(-s))
+        );
     return a;
 }

 #define NEG_USR32 NEG_USR32
 static inline uint32_t NEG_USR32(uint32_t a, int8_t s){
+    if (__builtin_constant_p(s))
     __asm__ ("shrl %1, %0\n\t"
          : "+r" (a)
-         : "ic" ((uint8_t)(-s))
+         : "i" (-s & 0x1F)
     );
+    else
+        __asm__ ("shrl %1, %0\n\t"
+               : "+r" (a)
+               : "c" ((uint8_t)(-s))
+        );
     return a;
 }
