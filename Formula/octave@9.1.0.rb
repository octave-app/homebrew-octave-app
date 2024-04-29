# GNU Octave 9.1.0 (with Qt 6)
#
# This main formula builds against Qt 6, and is currently broken because of that. (A sip
# install error in the qscintilla2-qt6 build.) See octave-qt5@9.0 for an alternative that
# builds against the old Qt 5, and is working.

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

class OctaveAT910 < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "https://ftp.gnu.org/gnu/octave/octave-9.1.0.tar.lz"
  mirror "https://ftpmirror.gnu.org/gnu/octave/octave-9.1.0.tar.lz"
  sha256 "f1769f61bd10c8ade6aee352b1bbb016e5fd8fc8394896a64dc26ef675ba3cea"
  license "GPL-3.0-or-later"

  keg_only "so it can be installed alongside regular octave"

  option "without-qt", "Compile without qt-based graphical user interface"
  option "without-docs", "Skip documentation (documentation requires MacTeX)"
  option "with-test", "Do compile-time make checks"

  # These must be kept in sync with the duplicates in `def install`!
  @qt_formula = "qt"
  @qscintilla2_formula = "qscintilla2"

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gnu-sed" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on "librsvg" => :build
  depends_on "pkg-config" => :build
  depends_on "arpack"
  depends_on "epstool"
  depends_on "fftw"
  depends_on "fig2dev"
  depends_on "fltk"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gcc" # for gfortran
  depends_on "ghostscript"
  depends_on "gl2ps"
  depends_on "glpk"
  depends_on "gnu-tar"
  depends_on "graphicsmagick"
  depends_on "hdf5"
  depends_on "libsndfile"
  depends_on "libtool"
  depends_on "openblas"
  depends_on "openjdk"
  depends_on "pcre"
  depends_on "portaudio"
  depends_on "pstoedit"
  depends_on "qhull"
  depends_on "qrupdate"
  depends_on @qscintilla2_formula if build.with?("qt")
  depends_on @qt_formula if build.with?("qt")
  depends_on "rapidjson"
  depends_on "readline"
  depends_on "suite-sparse"
  depends_on "sundials"
  depends_on "texinfo" # http://lists.gnu.org/archive/html/octave-maintainers/2018-01/msg00016.html
  depends_on MacTeXRequirement if build.with?("docs")

  # Suppress spurious messages about GCC caused by dependencies using Fortran
  cxxstdlib_check :skip

  fails_with gcc: "5"

  def install
    # These must be kept in sync with the duplicates at the top of the formula!
    @qt_formula = "qt"
    @qscintilla2_formula = "qscintilla2"

    # Hack: munge HG-ID to reflect that we're adding patches
    hg_id = `cat HG-ID`.chomp;
    File.delete("HG-ID");
    Pathname.new("HG-ID").write "#{hg_id} + patches\n"

    # Do not execute a test that may trigger a dialog to install java
    inreplace "libinterp/octave-value/ov-java.cc", "usejava (\"awt\")", "false ()"

    # Default configuration passes all linker flags to mkoctfile, to be
    # inserted into every oct/mex build. This is unnecessary and can cause
    # cause linking problems.
    inreplace "src/mkoctfile.in.cc", /%OCTAVE_CONF_OCT(AVE)?_LINK_(DEPS|OPTS)%/, '""'

    # Pick up keg-only libraries
    ENV.append "CXXFLAGS", "-I#{Formula["sundials"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula[@qscintilla2_formula].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula[@qscintilla2_formula].opt_lib}"

    # SUNDIALS 6.4.0 and later needs C++14 for C++ based features.
    # Use gnu++14 instead of c++14 as octave uses GNU extensions.
    ENV.append "CXX", "-std=gnu++14"

    args = ["--prefix=#{prefix}",
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--enable-link-all-dependencies",
            "--enable-shared",
            "--disable-static",
            "--with-hdf5-includedir=#{Formula["hdf5"].opt_include}",
            "--with-hdf5-libdir=#{Formula["hdf5"].opt_lib}",
            "--with-java-homedir=#{Formula["openjdk"].opt_prefix}",
            "--with-x=no",
            "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas",
            "--with-portaudio",
            "--with-sndfile"]

    if build.without? "qt"
      args << "--without-qt"
    else
      args << "--with-qt"
      # WIP: working on switching to Qt 6 as of 2024-02-10
      # Qt 5.12 compatibility
      # Qt 5.12 merged qcollectiongenerator into qhelpgenerator, and Octave's
      # source hasn't been updated to auto-detect this yet.
      # ENV['QCOLLECTIONGENERATOR']='qhelpgenerator'
      # These "shouldn't" be necessary, but if I don't include them, the build would against
      # Qt 5 would break. Don't know if they're still needed against Qt 6; either way, the build
      # seems to succeed but it fails to detect Qt 6 during the configure stage.
      # https://savannah.gnu.org/bugs/?55883
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
    # TODO: Maybe this would work instead? It's what the core octave formula uses.
    # Need to regenerate aclocal.m4 so that it will work with brewed automake
    # system "aclocal"

    system "./configure", *args
    system "make", "all"

    # Avoid revision bumps whenever fftw's, gcc's or OpenBLAS' Cellar paths change
    inreplace "src/mkoctfile.cc" do |s|
      s.gsub! Formula["fftw"].prefix.realpath, Formula["fftw"].opt_prefix
      s.gsub! Formula["gcc"].prefix.realpath, Formula["gcc"].opt_prefix
    end

    # Make sure that Octave uses the modern texinfo
    rcfile = buildpath/"scripts/startup/site-rcfile"
    rcfile.append_lines "makeinfo_program(\"#{Formula["texinfo"].opt_bin}/makeinfo\");"

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
    # Link this keg-only formula into the main Homebrew bin with a prefixed name
    system "ln", "-sf", "#{bin}/octave", "#{HOMEBREW_PREFIX}/bin/octave-9.1.0"
  end

  test do
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with BLAS
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
    # Test java bindings: check if javaclasspath is working, return error if not
    system bin/"octave", "--eval", "try; javaclasspath; catch; quit(1); end;" if build.with? "java"
    # Test basic oct-file compilation
    (testpath/"oct_demo.cc").write <<~EOS
      #include <octave/oct.h>
      DEFUN_DLD (oct_demo, args, /*nargout*/, "doc str")
      { return ovl (42); }
    EOS
    system bin/"octave", "--eval", <<~EOS
      mkoctfile ('-v', '-std=c++11', '-L#{lib}/octave/#{version}', 'oct_demo.cc');
      assert(oct_demo, 42)
    EOS
    # Test FLIBS environment variable
    system bin/"octave", "--eval", <<~EOS
      args = strsplit (mkoctfile ('-p', 'FLIBS'));
      args = args(~cellfun('isempty', args));
      mkoctfile ('-v', '-std=c++11', '-L#{lib}/octave/#{version}', args{:}, 'oct_demo.cc');
      assert(oct_demo, 42)
    EOS
  end
end