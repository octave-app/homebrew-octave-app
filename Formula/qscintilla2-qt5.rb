# QScintilla 2, built against Qt 6 instead of 5.
# The core Homebrew qscintilla2 formula is still building against Qt 5, because
# Octave 8.x was stuck on Qt 5. They'll switch it to Qt 6 once Octave uses Qt 6, which
# should happen with Octave 9.1. This qscintilla2-qt5 variant will keep building against
# Qt 5 so we can still use it with Octave <=8.x and Qt 5, but is otherwise the
# same as the core qscintilla2 formula. As of 2024-02-10, it is not actually needed
# yet because core qscintilla2 is still on Qt 5, but is supplied in advance, in anticipation
# of that changeover happening, so we can handle that proactively.
class Qscintilla2Qt5 < Formula
  desc "Port to Qt of the Scintilla editing component"
  homepage "https://www.riverbankcomputing.com/software/qscintilla/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/QScintilla/2.14.1/QScintilla_src-2.14.1.tar.gz"
  sha256 "dfe13c6acc9d85dfcba76ccc8061e71a223957a6c02f3c343b30a9d43a4cdd4d"
  license "GPL-3.0-only"
  revision 2

  # The downloads page also lists pre-release versions, which use the same file
  # name format as stable versions. The only difference is that files for
  # stable versions are kept in corresponding version subdirectories and
  # pre-release files are in the parent QScintilla directory. The regex below
  # omits pre-release versions by only matching tarballs in a version directory.
  livecheck do
    url "https://www.riverbankcomputing.com/software/qscintilla/download"
    regex(%r{href=.*?QScintilla/v?\d+(?:\.\d+)+/QScintilla(?:[._-](?:gpl|src))?[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  depends_on "pyqt-builder" => :build
  depends_on "sip"          => :build

  # Octapp -qt5 customization: unlike core Homebrew qscintilla2 formula, do
  # *not* upgrade these once the current version of Octave supports Qt 6.
  depends_on "pyqt@5"
  depends_on "python@3.12"
  depends_on "qt@5"

  fails_with gcc: "5"

  def python3
    "python3.12"
  end

  def install
    args = []

    if OS.mac?
      # TODO: when using qt 6, modify the spec
      spec = (ENV.compiler == :clang) ? "macx-clang" : "macx-g++"
      args = %W[-config release -spec #{spec}]
    end

    pyqt = Formula["pyqt@5"]
    qt = Formula["qt@5"]
    site_packages = Language::Python.site_packages(python3)

    cd "src" do
      inreplace "qscintilla.pro" do |s|
        s.gsub! "QMAKE_POST_LINK += install_name_tool -id @rpath/$(TARGET1) $(TARGET)",
          "QMAKE_POST_LINK += install_name_tool -id #{lib}/$(TARGET1) $(TARGET)"
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
        # TODO: use qt6 directory layout when octave can migrate to qt6
        s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", prefix/"trans"
        s.gsub! "$$[QT_INSTALL_DATA]", prefix/"data"
        s.gsub! "$$[QT_HOST_DATA]", prefix/"data"
        # s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", share/"qt/translations"
        # s.gsub! "$$[QT_INSTALL_DATA]", share/"qt"
        # s.gsub! "$$[QT_HOST_DATA]", share/"qt"
      end

      inreplace "features/qscintilla2.prf" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
      end

      system qt.opt_bin/"qmake", "qscintilla.pro", *args
      system "make"
      system "make", "install"
    end

    cd "Python" do
      mv "pyproject-qt#{qt.version.major}.toml", "pyproject.toml"
      (buildpath/"Python/pyproject.toml").append_lines <<~EOS
        [tool.sip.project]
        sip-include-dirs = ["#{pyqt.opt_prefix/site_packages}/PyQt#{pyqt.version.major}/bindings"]
      EOS

      args = %W[
        --target-dir #{prefix/site_packages}

        --qsci-features-dir #{prefix}/data/mkspecs/features
        --qsci-include-dir #{include}
        --qsci-library-dir #{lib}
        --api-dir #{prefix}/data/qsci/api/python
      ]
      system "sip-install", *args
    end
  end

  test do
    pyqt = Formula["pyqt@5"]
    (testpath/"test.py").write <<~EOS
      import PyQt#{pyqt.version.major}.Qsci
      assert("QsciLexer" in dir(PyQt#{pyqt.version.major}.Qsci))
    EOS

    system python3, "test.py"
  end
end
