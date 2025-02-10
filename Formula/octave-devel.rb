# GNU Octave, devel (head-only) version
#
# This is a separate formula provided to make it easy to do side-by-side installations of
# the development Octave along with regular stable Octave.
#
# This formula includes only patches that seriously affect the stability and usability of
# Octave, and make this usable as a side-by-side install with the regular octave formula.
# It's intended for developers testing Octave, not end users.

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

class OctaveDevel < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://octave.org/index.html"
  license "GPL-3.0-or-later"

  keg_only "so it can be installed alongside regular octave"

  option "without-docs", "Skip documentation (documentation requires MacTeX)"
  option "without-deparallel", "Do not deparallelize on As (for debugging the OOM fix)"

  # New tarballs appear on https://ftp.gnu.org/gnu/octave/ before a release is
  # announced, so we check the octave.org download page instead.
  livecheck do
    url "https://octave.org/download"
    regex(%r{Octave\s+v?(\d+(?:\.\d+)+)(?:\s*</[^>]+?>)?\s+is\s+the\s+latest\s+stable\s+release}im)
  end

  head do
    url "https://hg.savannah.gnu.org/hgweb/octave", branch: "default", using: :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "icoutils" => :build
    depends_on "librsvg" => :build
  end

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "gnu-sed" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on "mercurial" => :build # Octapp hack: just for the HG-ID generation
  depends_on "openjdk" => :build
  depends_on "pkgconf" => :build
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
  depends_on "qscintilla2"
  depends_on "qt"
  depends_on "rapidjson"
  depends_on "readline"
  depends_on "suite-sparse"
  depends_on "sundials"
  depends_on "texinfo"
  depends_on MacTeXRequirement if build.with?("docs")

  uses_from_macos "bzip2"
  uses_from_macos "curl"
  uses_from_macos "zlib"

  on_macos do
    depends_on "little-cms2"
  end

  on_linux do
    depends_on "mesa"
    depends_on "mesa-glu"
  end

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  def install
    if ! build.head?
      raise "This devel formula is a head-only formula. Please pass --HEAD to install it."
    end

    # Octapp hack: synthesize an HG-ID
    hg_id = cached_download.cd { `hg identify --id` }.chomp
    Pathname.new("HG-ID").write "#{hg_id} + Octave.app patches\n"

    # Default configuration passes all linker flags to mkoctfile, to be
    # inserted into every oct/mex build. This is unnecessary and can cause
    # cause linking problems.
    inreplace "src/mkoctfile.in.cc",
              /%OCTAVE_CONF_OCT(AVE)?_LINK_(DEPS|OPTS)%/,
              '""'

    ENV.prepend_path "PKG_CONFIG_PATH", Formula["qt"].opt_libexec/"lib/pkgconfig" if OS.mac?

    system "./bootstrap" if build.head?
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

    # Octapp: Force use of our bundled JDK
    ENV['JAVA_HOME']="#{Formula["openjdk"].opt_prefix}"

    system "./configure", *args, *std_configure_args
    # https://github.com/Homebrew/homebrew-core/pull/170959#issuecomment-2351023470
    # https://github.com/octave-app/octave-app/issues/295
    # Octapp hack: only deparallel on As, bc doesn't seem to break on Intel (on macOS)
    if build.with?("deparallel")
      ENV.deparallelize if Hardware::CPU.arm?
    end
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
    system "ln", "-sf", "#{bin}/octave", "#{HOMEBREW_PREFIX}/bin/octave-devel"
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with BLAS
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
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
