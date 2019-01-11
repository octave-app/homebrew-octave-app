class Octave4414 < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "https://ftp.gnu.org/gnu/octave/octave-4.4.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/octave/octave-4.4.1.tar.xz"
  sha256 "7e4e9ac67ed809bd56768fb69807abae0d229f4e169db63a37c11c9f08215f90"
  revision 4

  

  head do
    url "https://hg.savannah.gnu.org/hgweb/octave", :branch => "default", :using => :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "icoutils" => :build
    depends_on "librsvg" => :build
  end

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "gnu-sed_4.7_0" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on :java => ["1.6+", :build, :test]
  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "arpack_3.6.3_0"
  depends_on "epstool_3.08_0"
  depends_on "fftw_3.3.8_0"
  depends_on "fig2dev_3.2.7a_0"
  depends_on "fltk_1.3.4-2_1"
  depends_on "fontconfig_2.13.1_0"
  depends_on "freetype_2.9.1_0"
  depends_on "gcc_8.2.0_0" # for gfortran
  depends_on "ghostscript_9.26_0"
  depends_on "gl2ps_1.4.0_0"
  depends_on "glpk_4.65_0"
  depends_on "gnuplot_5.2.6_0"
  depends_on "graphicsmagick_1.3.31_0"
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
  depends_on "sundials_4.0.0_0"
  depends_on "texinfo_6.5_0"
  depends_on "veclibfort_0.4.2_6"

  depends_on "qt_5.12.0_0" => :optional

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  def install
    # Default configuration passes all linker flags to mkoctfile, to be
    # inserted into every oct/mex build. This is unnecessary and can cause
    # cause linking problems.
    inreplace "src/mkoctfile.in.cc", /%OCTAVE_CONF_OCT(AVE)?_LINK_(DEPS|OPTS)%/, '""'

    args = []
    args << "--without-qt" if build.without? "qt"

    system "./bootstrap" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--enable-link-all-dependencies",
                          "--enable-shared",
                          "--disable-static",
                          "--without-osmesa",
                          "--with-hdf5-includedir=#{Formula["hdf5_1.10.4_0"].opt_include}",
                          "--with-hdf5-libdir=#{Formula["hdf5_1.10.4_0"].opt_lib}",
                          "--with-x=no",
                          "--with-blas=-L#{Formula["veclibfort_0.4.2_6"].opt_lib} -lvecLibFort",
                          "--with-portaudio",
                          "--with-sndfile",
                          *args
    system "make", "all"

    # Avoid revision bumps whenever fftw's or gcc's Cellar paths change
    inreplace "src/mkoctfile.cc" do |s|
      s.gsub! Formula["fftw_3.3.8_0"].prefix.realpath, Formula["fftw_3.3.8_0"].opt_prefix
      s.gsub! Formula["gcc_8.2.0_0"].prefix.realpath, Formula["gcc_8.2.0_0"].opt_prefix
    end

    # Make sure that Octave uses the modern texinfo at run time
    rcfile = buildpath/"scripts/startup/site-rcfile"
    rcfile.append_lines "makeinfo_program(\"#{Formula["texinfo_6.5_0"].opt_bin}/makeinfo\");"

    system "make", "install"
  end

  test do
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with veclibfort
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
    # Test java bindings: check if javaclasspath is working, return error if not
    system bin/"octave", "--eval", "try; javaclasspath; catch; quit(1); end;"
  end
end
