class Cairo11600 < Formula
  desc "Vector graphics library with cross-device output support"
  homepage "https://cairographics.org/"
  url "https://cairographics.org/releases/cairo-1.16.0.tar.xz"
  sha256 "5e7b29b3f113ef870d1e3ecf8adf21f923396401604bda16d44be45e66052331"

  

  head do
    url "https://anongit.freedesktop.org/git/cairo", :using => :git
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "fontconfig_2.13.1_0"
  depends_on "freetype_2.9.1_0"
  depends_on "glib_2.58.1_0"
  depends_on "libpng_1.6.35_0"
  depends_on "pixman_0.34.0_1"

  def install
    if build.head?
      ENV["NOCONFIGURE"] = "1"
      system "./autogen.sh"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-gobject=yes",
                          "--enable-svg=yes",
                          "--enable-tee=yes",
                          "--enable-quartz-image",
                          "--enable-xcb=no",
                          "--enable-xlib=no",
                          "--enable-xlib-xrender=no"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <cairo.h>

      int main(int argc, char *argv[]) {

        cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 600, 400);
        cairo_t *context = cairo_create(surface);

        return 0;
      }
    EOS
    fontconfig = Formula["fontconfig_2.13.1_0"]
    freetype = Formula["freetype_2.9.1_0"]
    gettext = Formula["gettext"]
    glib = Formula["glib_2.58.1_0"]
    libpng = Formula["libpng_1.6.35_0"]
    pixman = Formula["pixman_0.34.0_1"]
    flags = %W[
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/cairo
      -I#{libpng.opt_include}/libpng16
      -I#{pixman.opt_include}/pixman-1
      -L#{lib}
      -lcairo
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
