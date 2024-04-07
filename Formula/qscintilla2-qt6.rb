# QScintilla 2, built against Qt 6 instead of 5.
#
# The core Homebrew qscintilla2 formula is still building against Qt 5, because
# Octave 8.x was stuck on Qt 5. This -qt6 version of qscintilla is for building Octave
# 9 against At 6. Once core Homebrew upgrades their Octave and switches qscintilla2
# to Qt 6, this formula can go away, and we'll have to supply a qscintilla2-qt5 variant
# to keep building against Qt 5 for Octave 8.x and earlier.

class Qscintilla2Qt6 < Formula
  desc "Port to Qt of the Scintilla editing component, built with Qt 6"
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

  depends_on "pyqt"
  depends_on "python@3.12"
  depends_on "qt"

  fails_with gcc: "5"

  def python3
    "python3.12"
  end

  def install
    args = []

    if OS.mac?
      # TODO: when using qt 6, modify the spec
      # TODO: figure out how the spec should be modified per above comment, now that we're using qt6
      spec = (ENV.compiler == :clang) ? "macx-clang" : "macx-g++"
      args = %W[-config release -spec #{spec}]
    end

    pyqt = Formula["pyqt"]
    qt = Formula["qt"]
    site_packages = Language::Python.site_packages(python3)

    cd "src" do
      inreplace "qscintilla.pro" do |s|
        s.gsub! "QMAKE_POST_LINK += install_name_tool -id @rpath/$(TARGET1) $(TARGET)",
          "QMAKE_POST_LINK += install_name_tool -id #{lib}/$(TARGET1) $(TARGET)"
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
        # TODO: use qt6 directory layout when octave can migrate to qt6 (in progress)
        s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", share/"qt/translations"
        s.gsub! "$$[QT_INSTALL_DATA]", share/"qt"
        s.gsub! "$$[QT_HOST_DATA]", share/"qt"
        # These are the old qt5 variants:
        # s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", prefix/"trans"
        # s.gsub! "$$[QT_INSTALL_DATA]", prefix/"data"
        # s.gsub! "$$[QT_HOST_DATA]", prefix/"data"
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

      # TODO: qt6 options (in progress)
      # --qsci-features-dir #{share}/qt/mkspecs/features
      # --api-dir #{share}/qt/qsci/api/python
      # Old qt5 options:
      # --qsci-features-dir #{prefix}/data/mkspecs/features
      # --api-dir #{prefix}/data/qsci/api/python

      args = %W[
        --target-dir #{prefix/site_packages}

        --qsci-features-dir #{share}/qt/mkspecs/features
        --qsci-include-dir #{include}
        --qsci-library-dir #{lib}
        --api-dir #{share}/qt/qsci/api/python
      ]
      system "sip-install", *args
    end
  end

  test do
    pyqt = Formula["pyqt"]
    (testpath/"test.py").write <<~EOS
      import PyQt#{pyqt.version.major}.Qsci
      assert("QsciLexer" in dir(PyQt#{pyqt.version.major}.Qsci))
    EOS

    system python3, "test.py"
  end
end
