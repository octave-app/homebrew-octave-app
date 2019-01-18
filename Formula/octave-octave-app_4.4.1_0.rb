# GNU Octave, Qt-enabled, with build customized for Octave.app
#
# This version of Octave is kept at the current version. It is only
# used for grabbing the dependencies of Octave; it is not used for
# building Octave.app itself. The versioned octave formulae are used
# for that. This formula does not have versioned dependencies.
# This is kept separate from Homebrew's main "octave" formula so we
# can fiddle around with its version independently.

class MacTeXRequirement < Requirement
  fatal true

  satisfy(:build_env => false) {
    Pathname.new("/Library/TeX/texbin/latex").executable?
  }

  def message; <<~EOS
    MacTeX must be installed in order to build --with-docs.
  EOS
  end
end

class OctaveOctaveApp4410 < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "ftp://ftp.gnu.org/gnu/octave/octave-4.4.1.tar.lz"
  sha256 "1e6e3a72b4fd4b4db73ccb9f3046e4f727201c2e934b77afb04a804d7f7c4d4b"

  option "without-qt", "Compile without qt-based graphical user interface"
  option "without-docs", "Skip documentation (requires MacTeX)"
  option "with-test", "Do compile-time make checks"

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "automake_1.16.1_1" => :build
  depends_on "autoconf_2.69_0" => :build
  depends_on "gnu-sed_4.5_0" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "arpack_3.6.3_0"
  depends_on "epstool_3.08_0"
  depends_on "fftw_3.3.8_0"
  depends_on "fig2dev_3.2.7a_0"
  depends_on "fontconfig_2.13.1_0"
  depends_on "freetype_2.9.1_0"
  depends_on "ghostscript_9.25_0"
  depends_on "gl2ps_1.4.0_0"
  depends_on "glpk_4.65_0"
  depends_on "gnuplot_5.2.6_0"
  depends_on "gnu-tar-octave-app_1.30_0"
  depends_on "graphicsmagick_1.3.30_0"
  depends_on "hdf5_1.10.4_0"
  depends_on "libsndfile_1.0.28_0"
  depends_on "libtool_2.4.6_1"
  depends_on "pcre_8.42_0"
  depends_on "portaudio_19.6.0_0"
  depends_on "pstoedit_3.73_0"
  depends_on "qhull_2015.2_0"
  depends_on "qrupdate_1.1.2_8"
  depends_on "readline_7.0.5_0"
  depends_on "suite-sparse_5.3.0_0"
  depends_on "sundials27-octave-app_2.7.0_0"
  depends_on "texinfo_6.5_0" # http://lists.gnu.org/archive/html/octave-maintainers/2018-01/msg00016.html
  depends_on "veclibfort_0.4.2_6"
  depends_on :java => ["1.8", :recommended]
  depends_on MacTeXRequirement if build.with?("docs")

  # Dependencies for the graphical user interface
  if build.with?("qt")
    depends_on "qt_5.11.2_0"
    depends_on "qscintilla2_2.10.4_0_1"

    # Fix bug #49053: retina scaling of figures
    # see https://savannah.gnu.org/bugs/?49053
    patch do
      url "https://savannah.gnu.org/support/download.php?file_id=44041"
      sha256 "bf7aaa6ddc7bd7c63da24b48daa76f5bdf8ab3a2f902334da91a8d8140e39ff0"
    end

    # Fix bug #50025: Octave window freezes
    # see https://savannah.gnu.org/bugs/?50025
    patch do
      url "https://savannah.gnu.org/support/download.php?file_id=45382"
      sha256 "e179c3a0e53f6f0f4a48b5adafd18c0f9c33de276748b8049c7d1007282f7f6e"
    end
  end

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  def install
    # do not execute a test that may trigger a dialog to install java
    inreplace "libinterp/octave-value/ov-java.cc", "usejava (\"awt\")", "false ()"

    # Default configuration passes all linker flags to mkoctfile, to be
    # inserted into every oct/mex build. This is unnecessary and can cause
    # cause linking problems.
    inreplace "src/mkoctfile.in.cc", /%OCTAVE_CONF_OCT(AVE)?_LINK_(DEPS|OPTS)%/, '""'

    # Pick up non-linked libraries
    ENV.append "CXXFLAGS", "-I#{Formula["sundials27-octave-app_2.7.0_0"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula["qscintilla2_2.10.4_0_1"].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula["qscintilla2_2.10.4_0_1"].opt_lib}"

    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--enable-link-all-dependencies",
      "--enable-shared",
      "--disable-static",
      "--without-fltk",
      "--without-osmesa",
      "--with-hdf5-includedir=#{Formula["hdf5_1.10.4_0"].opt_include}",
      "--with-hdf5-libdir=#{Formula["hdf5_1.10.4_0"].opt_lib}",
      "--with-x=no",
      "--with-blas=-L#{Formula["veclibfort_0.4.2_6"].opt_lib} -lvecLibFort",
      "--with-portaudio",
      "--with-sndfile"
    ]

    if build.without? "java"
      args << "--disable-java"
    end

    if build.without? "qt"
      args << "--without-qt"
    else
      args << "--with-qt=5"
    end

    if build.without? "docs"
      args << "--disable-docs"
    else
      ENV.prepend_path "PATH", "/Library/TeX/texbin/"
    end

    # fix aclocal version issue
    system "autoreconf", "-f", "-i"
    system "./configure", *args
    system "make", "all"

    if build.with? "test"
      system "make check 2>&1 | tee \"test/make-check.log\""
      # check if all tests have passed (FAIL 0)
      results = File.readlines "test/make-check.log"
      matches = results.join("\n").match(/^\s*(FAIL)\s*0/i)
      if matches.nil?
        opoo "Some tests failed. Details are given in #{opt_prefix}/make-check.log."
      end
      # install test results
      prefix.install "test/make-check.log"
    end

    # make sure that Octave uses the modern texinfo
    rcfile = buildpath/"scripts/startup/site-rcfile"
    rcfile.append_lines "makeinfo_program(\"#{Formula["texinfo_6.5_0"].opt_bin}/makeinfo\");"

    system "make", "install"

    # create empty qt help to avoid error dialog of GUI
    # if no documentation is found
    if build.without?("docs") && build.with?("qt") && !build.stable?
      File.open("doc/octave_interpreter.qhcp", "w") do |f|
        f.write("<?xml version=\"1.0\" encoding=\"utf-8\" ?>")
        f.write("<QHelpCollectionProject version=\"1.0\" />")
      end
      system "#{Formula["qt_5.11.2_0"].opt_bin}/qcollectiongenerator", "doc/octave_interpreter.qhcp", "-o", "doc/octave_interpreter.qhc"
      (pkgshare/"#{version}/doc").install "doc/octave_interpreter.qhc"
    end
  end

  test do
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with veclibfort
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
    # Test java bindings: check if javaclasspath is working, return error if not
    system bin/"octave", "--eval", "try; javaclasspath; catch; quit(1); end;" if build.with? "java"
  end
end

