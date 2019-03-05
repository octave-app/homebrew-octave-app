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

class OctaveOctaveApp < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "ftp://ftp.gnu.org/gnu/octave/octave-4.4.1.tar.lz"
  sha256 "1e6e3a72b4fd4b4db73ccb9f3046e4f727201c2e934b77afb04a804d7f7c4d4b"

  devel do
    url "ftp://alpha.gnu.org/gnu/octave/octave-5.0.91.tar.lz"
    sha256 "640bd367858f4b33e0731938541ea15189721c567cb5560ff325da3876b86e6c"
  end

  keg_only "so it can be installed alongside regular octave"

  option "without-qt", "Compile without qt-based graphical user interface"
  option "without-docs", "Skip documentation (requires MacTeX)"
  option "with-test", "Do compile-time make checks"

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "gnu-sed" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on "pkg-config" => :build
  depends_on "arpack"
  depends_on "epstool"
  depends_on "fftw"
  depends_on "fig2dev"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "ghostscript"
  depends_on "gl2ps"
  depends_on "glpk"
  depends_on "gnuplot"
  depends_on "gnu-tar"
  depends_on "graphicsmagick"
  depends_on "hdf5"
  depends_on "libsndfile"
  depends_on "libtool"
  depends_on "pcre"
  depends_on "portaudio"
  depends_on "pstoedit"
  depends_on "qhull"
  depends_on "qrupdate"
  depends_on "readline"
  depends_on "suite-sparse"
  depends_on "sundials@2"
  depends_on "texinfo" # http://lists.gnu.org/archive/html/octave-maintainers/2018-01/msg00016.html
  depends_on "veclibfort"
  depends_on :java => ["1.8", :recommended]
  depends_on MacTeXRequirement if build.with?("docs")

  # Dependencies for the graphical user interface
  if build.with?("qt")
    depends_on "qt"
    depends_on "qscintilla2"

    if build.stable?
      # Fix bug #49053: retina scaling of figures
      # see https://savannah.gnu.org/bugs/?49053
      patch do
        url "https://savannah.gnu.org/support/download.php?file_id=44041"
        sha256 "bf7aaa6ddc7bd7c63da24b48daa76f5bdf8ab3a2f902334da91a8d8140e39ff0"
      end
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
    # Hack: munge HG-ID to reflect that we're adding patches
    hg_id = `cat HG-ID`.chomp;
    File.delete("HG-ID");
    Pathname.new("HG-ID").write "#{hg_id} + patches\n"

    # do not execute a test that may trigger a dialog to install java
    inreplace "libinterp/octave-value/ov-java.cc", "usejava (\"awt\")", "false ()"

    # Default configuration passes all linker flags to mkoctfile, to be
    # inserted into every oct/mex build. This is unnecessary and can cause
    # cause linking problems.
    inreplace "src/mkoctfile.in.cc", /%OCTAVE_CONF_OCT(AVE)?_LINK_(DEPS|OPTS)%/, '""'

    # Pick up keg-only libraries
    ENV.append "CXXFLAGS", "-I#{Formula["sundials@2"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula["qscintilla2"].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula["qscintilla2"].opt_lib}"

    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--enable-link-all-dependencies",
      "--enable-shared",
      "--disable-static",
      "--without-fltk",
      "--with-hdf5-includedir=#{Formula["hdf5"].opt_include}",
      "--with-hdf5-libdir=#{Formula["hdf5"].opt_lib}",
      "--with-x=no",
      "--with-blas=-L#{Formula["veclibfort"].opt_lib} -lvecLibFort",
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
      # Qt 5.12 merged qcollectiongenerator into qhelpgenerator, and Octave's
      # source hasn't been updated to auto-detect this yet.
      ENV['QCOLLECTIONGENERATOR']='qhelpgenerator'
      # These "shouldn't" be necessary, but the build breaks if I don't include them.
      ENV['QT_CPPFLAGS']="-I#{Formula["qt"].opt_include}"
      ENV.append 'CPPFLAGS', "-I#{Formula["qt"].opt_include}"
      ENV['QT_LDFLAGS']="-F#{Formula["qt"].opt_lib}"
      ENV.append 'LDFLAGS', "-F#{Formula["qt"].opt_lib}"
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
    rcfile.append_lines "makeinfo_program(\"#{Formula["texinfo"].opt_bin}/makeinfo\");"

    system "make", "install"

    # create empty qt help to avoid error dialog of GUI
    # if no documentation is found
    if build.without?("docs") && build.with?("qt") && !build.stable?
      File.open("doc/octave_interpreter.qhcp", "w") do |f|
        f.write("<?xml version=\"1.0\" encoding=\"utf-8\" ?>")
        f.write("<QHelpCollectionProject version=\"1.0\" />")
      end
      system "#{Formula["qt"].opt_bin}/qhelpgenerator", "doc/octave_interpreter.qhcp", "-o", "doc/octave_interpreter.qhc"
      (pkgshare/"#{version}/doc").install "doc/octave_interpreter.qhc"
    end
  end

  def post_install
    system "ln", "-sf", "#{bin}/octave", "#{HOMEBREW_PREFIX}/bin/octave-octave-app"
  end

  test do
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with veclibfort
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
    # Test java bindings: check if javaclasspath is working, return error if not
    system bin/"octave", "--eval", "try; javaclasspath; catch; quit(1); end;" if build.with? "java"
  end
end


