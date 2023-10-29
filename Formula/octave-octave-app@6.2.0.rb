# GNU Octave 6.2.0, Qt-enabled, with build customized for Octave.app

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

class OctaveOctaveAppAT620 < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "https://ftp.gnu.org/gnu/octave/octave-6.2.0.tar.lz"
  mirror "https://ftpmirror.gnu.org/gnu/octave/octave-6.2.0.tar.lz"
  sha256 "27326ef4af61f5524325bdabf27be47da6b5988698a95fd81b2a30b598f4b2b2"
  license "GPL-3.0-or-later"
  revision 1

  keg_only "so it can be installed alongside regular octave"

  option "without-qt", "Compile without qt-based graphical user interface"
  option "without-docs", "Skip documentation (documentation requires MacTeX)"
  option "with-test", "Do compile-time make checks"

  @qt_formula = "qt-octave-app"
  @qscintilla2_formula = "qscintilla2-octave-app"
  @gnuplot_formula = "gnuplot-octave-app"

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "gnu-sed" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on "librsvg" => :build
  depends_on "pkg-config" => :build
  depends_on "arpack"
  depends_on "epstool"
  depends_on "fftw"
  depends_on "fig2dev-octave-app"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "ghostscript"
  depends_on "gl2ps"
  depends_on "glpk"
  depends_on @gnuplot_formula
  depends_on "gnu-tar"
  depends_on "graphicsmagick"
  depends_on "hdf5"
  depends_on "librsb" # for sparsersb Forge package
  depends_on "libsndfile"
  depends_on "libtool"
  depends_on "netcdf"
  depends_on "openblas"
  depends_on "openjdk"
  depends_on "pcre"
  depends_on "portaudio"
  depends_on "pstoedit"
  depends_on "qhull"
  depends_on "qrupdate"
  depends_on @qscintilla2_formula if build.with?("qt")
  depends_on @qt_formula if build.with?("qt")
  depends_on "readline"
  depends_on "suite-sparse"
  depends_on "sundials"
  depends_on "texinfo" # http://lists.gnu.org/archive/html/octave-maintainers/2018-01/msg00016.html
  depends_on MacTeXRequirement if build.with?("docs")

  # Dependencies for Octave Forge packages
  depends_on "cfitsio"  # fits package
  depends_on "gsl"      # gsl package
  depends_on "mpfr"     # interval package
  depends_on "proj@5"   # octproj package
  depends_on "zeromq"   # zeromq package

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  def install
    @qt_formula = "qt-octave-app"
    @qscintilla2_formula = "qscintilla2-octave-app"
    @gnuplot_formula = "gnuplot-octave-app"
  
    # Hack: munge HG-ID to reflect that we're adding patches
    hg_id = `cat HG-ID`.chomp;
    File.delete("HG-ID");
    Pathname.new("HG-ID").write "#{hg_id} + patches\n"

    # Do not execute a test that may trigger a dialog to install Java
    inreplace "libinterp/octave-value/ov-java.cc", "usejava (\"awt\")", "false ()"

    # Default configuration passes all linker flags to mkoctfile, to be
    # inserted into every oct/mex build. This is unnecessary and can cause
    # cause linking problems.
    inreplace "src/mkoctfile.in.cc", /%OCTAVE_CONF_OCT(AVE)?_LINK_(DEPS|OPTS)%/, '""'

    # Pick up keg-only libraries
    ENV.append "CXXFLAGS", "-I#{Formula["sundials"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula[@qscintilla2_formula].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula[@qscintilla2_formula].opt_lib}"

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
      "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas",
      "--with-portaudio",
      "--with-sndfile"
    ]

    if build.without? "qt"
      args << "--without-qt"
    else
      args << "--with-qt=5"
      # Qt 5.12 merged qcollectiongenerator into qhelpgenerator, and Octave's
      # source hasn't been updated to auto-detect this yet.
      #ENV['QCOLLECTIONGENERATOR']='qhelpgenerator'
      # These "shouldn't" be necessary, but the build breaks if I don't include them.
      ENV['QT_CPPFLAGS']="-I#{Formula[@qt_formula].opt_include}"
      ENV.append 'CPPFLAGS', "-I#{Formula[@qt_formula].opt_include}"
      ENV['QT_LDFLAGS']="-F#{Formula[@qt_formula].opt_lib}"
      ENV.append 'LDFLAGS', "-F#{Formula[@qt_formula].opt_lib}"
    end

    if build.without? "docs"
      args << "--disable-docs"
    else
      ENV.prepend_path "PATH", "/Library/TeX/texbin/"
    end

    # Force use of our bundled JDK
    ENV['JAVA_HOME']="#{Formula["openjdk"].opt_prefix}"

    # Fix aclocal version issue
    system "autoreconf", "-f", "-i"

    system "./configure", *args
    system "make", "all"

    if build.with? "test"
      system "make check 2>&1 | tee \"test/make-check.log\""
      # Check if all tests have passed (FAIL 0)
      results = File.readlines "test/make-check.log"
      matches = results.join("\n").match(/^\s*(FAIL)\s*0/i)
      if matches.nil?
        opoo "Some tests failed. Details are given in #{opt_prefix}/make-check.log."
      end
      # Install test results
      prefix.install "test/make-check.log"
    end

    # Make sure that Octave uses the modern texinfo
    rcfile = buildpath/"scripts/startup/site-rcfile"
    rcfile.append_lines "makeinfo_program(\"#{Formula["texinfo"].opt_bin}/makeinfo\");"

    system "make", "install"

    # Create empty Qt help to avoid error dialog in GUI if no documentation is found
    if build.without?("docs") && build.with?("qt") && !build.stable?
      File.open("doc/octave_interpreter.qhcp", "w") do |f|
        f.write("<?xml version=\"1.0\" encoding=\"utf-8\" ?>")
        f.write("<QHelpCollectionProject version=\"1.0\" />")
      end
      system "#{Formula[@qt_formula].opt_bin}/qhelpgenerator", "doc/octave_interpreter.qhcp", "-o", "doc/octave_interpreter.qhc"
      (pkgshare/"#{version}/doc").install "doc/octave_interpreter.qhc"
    end
  end

  def post_install
    system "ln", "-sf", "#{bin}/octave", "#{HOMEBREW_PREFIX}/bin/octave-octave-app@6.2.0"
  end

  test do
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with BLAS
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
    # Test java bindings: check if javaclasspath is working, return error if not
    system bin/"octave", "--eval", "try; javaclasspath; catch; quit(1); end;" if build.with? "java"
  end
end

