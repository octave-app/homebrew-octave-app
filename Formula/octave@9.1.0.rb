# GNU Octave 9.1.0 (with Qt 6)
#
# This main formula builds against Qt 6, and is currently broken because of that. (Fails
# at launch if you have a Qt 6 installed in a system Homebrew, or something like that.
# See: https://github.com/octave-app/octave-app/issues/274)
# See octave-qt5@9.1.0 for an alternative that builds against the old Qt 5, and is
# (apparently) working.

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
  url "https://ftp.gnu.org/gnu/octave/octave-9.1.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/octave/octave-9.1.0.tar.xz"
  sha256 "ed654b024aea56c44b26f131d31febc58b7cf6a82fad9f0b0bf6e3e9aa1a134b"
  license "GPL-3.0-or-later"

  # New tarballs appear on https://ftp.gnu.org/gnu/octave/ before a release is
  # announced, so we check the octave.org download page instead.
  livecheck do
    url "https://octave.org/download"
    regex(%r{Octave\s+v?(\d+(?:\.\d+)+)(?:\s*</[^>]+?>)?\s+is\s+the\s+latest\s+stable\s+release}im)
  end

  keg_only "so it can be installed alongside regular octave"

  option "without-docs", "Skip documentation (documentation requires MacTeX)"

  # Octapp: These must be kept in sync with the duplicates in `def install`!
  @qt_formula = "qt"
  @qscintilla2_formula = "qscintilla2"

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gnu-sed" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on "libtool" => :build # for the patches
  depends_on "openjdk" => :build
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
  depends_on "gnu-tar" # octapp addition
  depends_on "graphicsmagick"
  depends_on "hdf5"
  depends_on "libsndfile"
  depends_on "libtool"
  depends_on "openblas"
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

  uses_from_macos "curl"

  on_linux do
    depends_on "autoconf"
    depends_on "automake"
    depends_on "mesa"
    depends_on "mesa-glu"
  end

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  fails_with gcc: "5"

  # Fix build for Qt 6.7.0
  # https://hg.savannah.gnu.org/hgweb/octave/rev/f428a432ed4f
  patch do
    url "https://hg.savannah.gnu.org/hgweb/octave/raw-rev/f428a432ed4f"
    sha256 "a9dd08ffecff5b310039b14847e8012e150de9b71337adc0955b0e668eea1d37"
  end

  # Fix opengl-partial-update bug causing crashes on figure() and plot() with Qt 6.7.0
  # https://hg.savannah.gnu.org/hgweb/octave/rev/317fa0e5c8de
  patch do
    url "https://hg.savannah.gnu.org/hgweb/octave/raw-rev/317fa0e5c8de"
    sha256 "909dc65614d0ef2520c35c5f8d4f78c451b189b2673e837f4f21c18a776273f0"
  end

  def install
    # Octapp: These must be kept in sync with the duplicates at the top of the formula!
    @qt_formula = "qt"
    @qscintilla2_formula = "qscintilla2"

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

    # Octapp variant: pull in MacTeX. May not need with 9.2, or any not-very-patched
    # build from a release tarball? See #293.
    if build.without? "docs"
      args << "--disable-docs"
    else
      ENV.prepend_path "PATH", "/Library/TeX/texbin/"
    end

    if OS.linux?
      # Explicitly specify aclocal and automake without versions
      args << "ACLOCAL=aclocal"
      args << "AUTOMAKE=automake"

      # Mesa OpenGL location must be supplied by LDFLAGS on Linux
      args << "LDFLAGS=-L#{Formula["mesa"].opt_lib} -L#{Formula["mesa-glu"].opt_lib}"

      # Docs building is broken on Linux
      args << "--disable-docs"

      # Need to regenerate aclocal.m4 so that it will work with brewed automake
      system "aclocal"
    end

    # Force use of our bundled JDK
    ENV['JAVA_HOME']="#{Formula["openjdk"].opt_prefix}"

    # Fix aclocal version issue
    system "autoreconf", "-f", "-i"
    # TODO: Maybe this would work instead? It's what the core octave formula uses (on the
    # Linux side only).
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
    system "ln", "-sf", "#{bin}/octave", "#{HOMEBREW_PREFIX}/bin/octave@9.1.0"
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with BLAS
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
    # Test java bindings: check if javaclasspath is working, return error if not
    system bin/"octave", "--eval", "try; javaclasspath; catch; quit(1); end;"
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
    ENV["QT_QPA_PLATFORM"] = "minimal"
    system bin/"octave", "--gui"
  end
end
