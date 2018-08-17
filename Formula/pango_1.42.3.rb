class Pango1423 < Formula
  desc "Framework for layout and rendering of i18n text"
  homepage "https://www.pango.org/"
  url "https://download.gnome.org/sources/pango/1.42/pango-1.42.3.tar.xz"
  sha256 "fb3d875305d5143f02cde5c72fec3903e60dc35844759dc14b2df4955b5dde3a"

  

  head do
    url "https://gitlab.gnome.org/GNOME/pango.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
    depends_on "gtk-doc" => :build
  end

  depends_on "gobject-introspection_1.56.1" => :build
  depends_on "pkg-config_0.29.2" => :build
  depends_on "cairo_1.14.12"
  depends_on "fribidi_1.0.5"
  depends_on "fontconfig_2.13.0"
  depends_on "glib_2.56.1"
  depends_on "harfbuzz_1.8.8"

  # This fixes a font-size problem in gtk
  # For discussion, see https://bugzilla.gnome.org/show_bug.cgi?id=787867
  patch do
    url "https://gitlab.gnome.org/tschoonj/pango/commit/60df2b006e5d4553abc7bb5fe9a99539c91b0022.patch"
    sha256 "d5ece753cf393ef507dd2b0415721b4381159da5e2f40793c6d85741b1b163bc"
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-html-dir=#{share}/doc",
                          "--enable-introspection=yes",
                          "--enable-static",
                          "--without-xft"

    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/pango-view", "--version"
    (testpath/"test.c").write <<~EOS
      #include <pango/pangocairo.h>

      int main(int argc, char *argv[]) {
        PangoFontMap *fontmap;
        int n_families;
        PangoFontFamily **families;
        fontmap = pango_cairo_font_map_get_default();
        pango_font_map_list_families (fontmap, &families, &n_families);
        g_free(families);
        return 0;
      }
    EOS
    cairo = Formula["cairo_1.14.12"]
    fontconfig = Formula["fontconfig_2.13.0"]
    freetype = Formula["freetype"]
    gettext = Formula["gettext"]
    glib = Formula["glib_2.56.1"]
    libpng = Formula["libpng"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/pango-1.0
      -I#{libpng.opt_include}/libpng16
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{cairo.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -lcairo
      -lglib-2.0
      -lgobject-2.0
      -lintl
      -lpango-1.0
      -lpangocairo-1.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
