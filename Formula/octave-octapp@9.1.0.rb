# GNU Octave 9.1.0 (with Qt 6), with build customized for Octave.app
#
# This uses Qt 6, instead of the Qt 5 which has been used on all Octave.app releases up
# until now. It is not working yet, but I expect, or at least hope, that Qt 6 will
# start working soon and we can switch to it, so I'm making the default variant for 9.x
# use Qt 6, and putting the Qt 5 builds in a separate "-qt" suffixed formula.
#
# As such, so far, this is NOT the formula to use for building Octave.app 9.1 releases,
# and is just for testing Qt 6.

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

class OctaveOctappAT910 < Formula
  desc "GNU Octave, customized for Octave.app, v. 9.1.0"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "https://ftp.gnu.org/gnu/octave/octave-9.1.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/octave/octave-9.1.0.tar.xz"
  sha256 "ed654b024aea56c44b26f131d31febc58b7cf6a82fad9f0b0bf6e3e9aa1a134b"
  license "GPL-3.0-or-later"

  keg_only "so it can be installed alongside regular octave"

  option "without-docs", "Skip documentation (documentation requires MacTeX)"

  # Octapp: These must be kept in sync with the duplicates in `def install`!
  # This uses Qt 6, which the core Homebrew qt is on as of 2024-03ish.
  @qt_formula = "qt"
  @qscintilla2_formula = "qscintilla2-octapp"

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
  depends_on "pcre2"
  depends_on "portaudio"
  depends_on "pstoedit"
  depends_on "qhull"
  depends_on "qrupdate"
  depends_on @qscintilla2_formula
  depends_on @qt_formula
  depends_on "rapidjson"
  depends_on "readline"
  depends_on "suite-sparse"
  depends_on "sundials"
  depends_on "texinfo"
  depends_on MacTeXRequirement if build.with?("docs")

  # Octapp: Dependencies for Octave Forge packages (not Octave itself)
  # We exclude proj bc it's too big; 750 MB for the brewed proj 9.x
  # depends_on "proj"     # for octproj OF package
  depends_on "cfitsio"  # for fits OF package
  depends_on "gsl"      # for gsl OF package
  # WIP: DEBUG: Temporarily disabled bc its download and build are broken
  # depends_on "librsb" # for sparsersb OF package
  depends_on "mpfr"     # for interval package
  depends_on "netcdf"   # for ??? OF packages
  depends_on "zeromq"   # for zeromq OF package

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  fails_with gcc: "5"

  def install
    # Octapp: These must be kept in sync with the duplicates at the top of the formula!
    @qt_formula = "qt"
    @qscintilla2_formula = "qscintilla2-octapp"

    # Octapp hack: munge HG-ID to reflect that we're adding patches
    hg_id = `cat HG-ID`.chomp;
    File.delete("HG-ID");
    Pathname.new("HG-ID").write "#{hg_id} + patches\n"

    # Default configuration passes all linker flags to mkoctfile, to be
    # inserted into every oct/mex build. This is unnecessary and can cause
    # cause linking problems.
    inreplace "src/mkoctfile.in.cc",
              /%OCTAVE_CONF_OCT(AVE)?_LINK_(DEPS|OPTS)%/,
              '""'

    ENV.prepend_path "PKG_CONFIG_PATH", Formula[@qt_formula].opt_libexec/"lib/pkgconfig" if OS.mac?

    # SUNDIALS 6.4.0 and later needs C++14 for C++ based features.
    # Use gnu++14 instead of c++14 as octave uses GNU extensions.
    ENV.append "CXX", "-std=gnu++14"

    args = [
      "--disable-silent-rules",
      "--enable-shared",
      "--disable-static",
      "--with-hdf5-includedir=#{Formula["hdf5"].opt_include}",
      "--with-hdf5-libdir=#{Formula["hdf5"].opt_lib}",
      "--with-java-homedir=#{Formula["openjdk"].opt_prefix}",
      "--with-x=no",
      "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas",
      "--with-portaudio",
      "--with-sndfile",
      "--with-qt",
    ]

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

    system "./configure", *args, *std_configure_args
    system "make", "all"

    # Avoid revision bumps whenever fftw's, gcc's or OpenBLAS' Cellar paths change
    inreplace "src/mkoctfile.cc" do |s|
      s.gsub! Formula["fftw"].prefix.realpath, Formula["fftw"].opt_prefix
      s.gsub! Formula["gcc"].prefix.realpath, Formula["gcc"].opt_prefix
    end

    # Make sure that Octave uses the modern texinfo at run time
    rcfile = buildpath/"scripts/startup/site-rcfile"
    rcfile.append_lines "makeinfo_program(\"#{Formula["texinfo"].opt_bin}/makeinfo\");"

    system "make", "install"
  end

  def post_install
    # Link this keg-only formula into the main Homebrew bin with a suffixed name
    # Use "@" instead of "-" bc core Homebrew octave uses "-" in its symlink names
    system "ln", "-sf", "#{bin}/octave", "#{HOMEBREW_PREFIX}/bin/octave-octapp-9.1.0"
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with BLAS
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
    # Test java bindings: check if javaclasspath is working, return error if not
    system bin/"octave", "--eval", "try; javaclasspath; catch; quit(1); end;" if build.with? "java"
    # Test basic compilation
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
