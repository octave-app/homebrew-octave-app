class PyqtOctaveApp < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://dl.bintray.com/homebrew/mirror/pyqt-5.10.1.tar.gz"
  mirror "https://downloads.sourceforge.net/project/pyqt/PyQt5/PyQt-5.10.1/PyQt5_gpl-5.10.1.tar.gz"
  sha256 "9932e971e825ece4ea08f84ad95017837fa8f3f29c6b0496985fa1093661e9ef"

  option "with-debug", "Build with debug symbols"
  option "with-docs", "Install HTML documentation and python examples"

  deprecated_option "enable-debug" => "with-debug"

  depends_on "qt-octave-app"
  depends_on "sip-octave-app"
  depends_on "python" => :optional
  depends_on "python2" => :recommended

  # Patch from openSUSE for compatibility with Qt 5.11.0
  # https://build.opensuse.org/package/show/home:cgiboudeaux:branches:KDE:Qt5/python-qt5
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/4f563668/pyqt/qt-5.11.diff"
    sha256 "34bba97f87615ea072312bfc03c4d3fb0a1cf7a4cd9d6907857c1dca6cc89200"
  end

  def install
    Language::Python.each_python(build) do |python, version|
      args = ["--confirm-license",
              "--bindir=#{bin}",
              "--destdir=#{lib}/python#{version}/site-packages",
              "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
              "--sipdir=#{share}/sip/Qt5",
              # sip.h could not be found automatically
              "--sip-incdir=#{Formula["sip-octave-app"].opt_include}",
              "--qmake=#{Formula["qt-octave-app"].bin}/qmake",
              # Force deployment target to avoid libc++ issues
              "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
              "--qml-plugindir=#{pkgshare}/plugins",
              "--verbose"]
      args << "--debug" if build.with? "debug"

      system python, "configure.py", *args
      system "make"
      system "make", "install"
      system "make", "clean"
    end
    doc.install "doc/html", "examples" if build.with? "docs"
  end

  test do
    system "#{bin}/pyuic5", "--version"
    system "#{bin}/pylupdate5", "-version"
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import PyQt5"
      %w[
        Gui
        Location
        Multimedia
        Network
        Quick
        Svg
        WebEngineWidgets
        Widgets
        Xml
      ].each { |mod| system python, "-c", "import PyQt5.Qt#{mod}" }
    end
  end
end
