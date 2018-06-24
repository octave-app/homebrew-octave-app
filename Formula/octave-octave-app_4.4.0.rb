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

class OctaveOctaveApp440 < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "ftp://ftp.gnu.org/gnu/octave/octave-4.4.0.tar.lz"
  sha256 "777542ca425f3e7eddb3b31810563eaf8d690450a4f88c79c273bd338e31a75a"

  option "without-qt", "Compile without qt-based graphical user interface"
  option "without-docs", "Skip documentation (requires MacTeX)"
  option "without-test", "Skip compile-time make checks (not recommended)"

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "automake_1.16.1" => :build
  depends_on "autoconf_2.69" => :build
  depends_on "gnu-sed_4.5" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on "pkg-config_0.29.2" => :build
  depends_on "arpack_3.6.0"
  depends_on "epstool_3.08"
  depends_on "fftw_3.3.7"
  depends_on "fig2dev_3.2.7a"
  depends_on "fontconfig_2.13.0"
  depends_on "freetype_2.9.1"
  depends_on "ghostscript_9.23"
  depends_on "gl2ps_1.4.0"
  depends_on "glpk_4.65"
  depends_on "gnuplot-octave-app_5.2.4"
  depends_on "gnu-tar_1.30"
  depends_on "graphicsmagick_1.3.29"
  depends_on "hdf5_1.10.2"
  depends_on "libsndfile_1.0.28"
  depends_on "libtool_2.4.6"
  depends_on "pcre_8.42"
  depends_on "portaudio_19.6.0"
  depends_on "pstoedit_3.73"
  depends_on "qhull_2015.2"
  depends_on "qrupdate_1.1.2"
  depends_on "readline_7.0.3"
  depends_on "suite-sparse_5.2.0"
  depends_on "sundials27-octave-app_2.7.0"
  depends_on "texinfo_6.5" # http://lists.gnu.org/archive/html/octave-maintainers/2018-01/msg00016.html
  depends_on "veclibfort_0.4.2"
  depends_on :java => ["1.8", :recommended]
  depends_on MacTeXRequirement if build.with?("docs")

  # Dependencies for the graphical user interface
  if build.with?("qt")
    depends_on "qt-octave-app_5.11.1"
    depends_on "qscintilla2-octave-app_2.10.4"

    # Fix bug #49053: retina scaling of figures
    # see https://savannah.gnu.org/bugs/?49053
    patch do
      url "https://savannah.gnu.org/support/download.php?file_id=44041"
      sha256 "bf7aaa6ddc7bd7c63da24b48daa76f5bdf8ab3a2f902334da91a8d8140e39ff0"
    end

    # add Qt include needed to build against Qt 5.11 (bug #53978)
    # should be fixed in >4.4.0 
    if build.stable?
      patch do
        url "https://hg.savannah.gnu.org/hgweb/octave/raw-rev/cdaa884568b1"
        sha256 "223f12fafc755d0084ff237a215766bc646db89c97a9f6e3a3644196b467a1c4"
      end
    end

    # Fix bug #50025: Octave window freezes
    # see https://savannah.gnu.org/bugs/?50025
    patch :DATA

    # Fix bug https://github.com/octave-app/octave-app-bundler/issues/10
    # tar.m and unpack.m use plain "tar" but expect a GNU tar
    patch do
      url "https://raw.githubusercontent.com/octave-app/formula-patches/80d1a98d982e4207e66d424c7cc685536607c66c/octave/4.4.0-gtar-instead-of-tar.patch"
      sha256 "25a14fabf39841a4089667ebc5c326a2d40640b99432ae97ae49ce0a9a496878"
    end

    # Work around bug https://github.com/octave-app/octave-app-bundler/issues/30
    # sparse/eigs.m is failing, due to upstream issue
    patch do
      url "https://raw.githubusercontent.com/octave-app/formula-patches/f69aaf4c007fd7dbfe7f2ccd7243dce4f420acca/octave/4.4.0-sparse-eigs-xfail.patch"
      sha256 "c34c66660f9459b17cfe1011526e3af9df24e02a3386dd5d29c0284812f72d05"
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

    ENV.append "CFLAGS", "-I#{Formula["sundials27-octave-app_2.7.0"].opt_include}"

    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--enable-link-all-dependencies",
      "--enable-shared",
      "--disable-static",
      "--without-fltk",
      "--without-osmesa",
      "--with-hdf5-includedir=#{Formula["hdf5_1.10.2"].opt_include}",
      "--with-hdf5-libdir=#{Formula["hdf5_1.10.2"].opt_lib}",
      "--with-x=no",
      "--with-blas=-L#{Formula["veclibfort_0.4.2"].opt_lib} -lvecLibFort",
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
    rcfile.append_lines "makeinfo_program(\"#{Formula["texinfo_6.5"].opt_bin}/makeinfo\");"

    system "make", "install"

    # create empty qt help to avoid error dialog of GUI
    # if no documentation is found
    if build.without?("docs") && build.with?("qt") && !build.stable?
      File.open("doc/octave_interpreter.qhcp", "w") do |f|
        f.write("<?xml version=\"1.0\" encoding=\"utf-8\" ?>")
        f.write("<QHelpCollectionProject version=\"1.0\" />")
      end
      system "#{Formula["qt"].opt_bin}/qcollectiongenerator", "doc/octave_interpreter.qhcp", "-o", "doc/octave_interpreter.qhc"
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

__END__
diff --git a/libgui/src/main-window.cc b/libgui/src/main-window.cc
--- a/libgui/src/main-window.cc
+++ b/libgui/src/main-window.cc
@@ -221,9 +221,6 @@
              this, SLOT (handle_octave_ready (void)));
 
     connect (m_interpreter, SIGNAL (octave_finished_signal (int)),
              this, SLOT (handle_octave_finished (int)));
-
-    connect (m_interpreter, SIGNAL (octave_finished_signal (int)),
-             m_main_thread, SLOT (quit (void)));
 
     connect (m_main_thread, SIGNAL (finished (void)),
@@ -1536,6 +1533,9 @@
 
   void main_window::handle_octave_finished (int exit_status)
   {
+    /* fprintf to stderr is needed by macOS */
+    fprintf(stderr, "\n");
+    m_main_thread->quit();
     qApp->exit (exit_status);
   }
 
