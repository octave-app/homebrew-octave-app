class Gtkx3322300 < Formula
  desc "Toolkit for creating graphical user interfaces"
  homepage "https://gtk.org/"
  url "https://download.gnome.org/sources/gtk+/3.22/gtk+-3.22.30.tar.xz"
  sha256 "a1a4a5c12703d4e1ccda28333b87ff462741dc365131fbc94c218ae81d9a6567"

  

  depends_on "gobject-introspection_1.58.0_0" => :build
  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "atk_2.30.0_0"
  depends_on "gdk-pixbuf_2.38.0_0"
  depends_on "glib_2.58.1_0"
  depends_on "hicolor-icon-theme_0.17_0"
  depends_on "libepoxy_1.5.3_0"
  depends_on "pango_1.42.4_0"
  depends_on "gsettings-desktop-schemas_3.28.1_0" => :recommended

  def install
    args = %W[
      --enable-debug=minimal
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-glibtest
      --enable-introspection=yes
      --disable-schemas-compile
      --enable-quartz-backend
      --disable-x11-backend
    ]

    system "./configure", *args
    # necessary to avoid gtk-update-icon-cache not being found during make install
    bin.mkpath
    ENV.prepend_path "PATH", bin
    system "make", "install"
    # Prevent a conflict between this and Gtk+2
    mv bin/"gtk-update-icon-cache", bin/"gtk3-update-icon-cache"
  end

  def post_install
    system "#{Formula["glib_2.58.1_0"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gtk/gtk.h>

      int main(int argc, char *argv[]) {
        gtk_disable_setlocale();
        return 0;
      }
    EOS
    atk = Formula["atk_2.30.0_0"]
    cairo = Formula["cairo"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gdk_pixbuf = Formula["gdk-pixbuf_2.38.0_0"]
    gettext = Formula["gettext"]
    glib = Formula["glib_2.58.1_0"]
    libepoxy = Formula["libepoxy_1.5.3_0"]
    libpng = Formula["libpng"]
    pango = Formula["pango_1.42.4_0"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{atk.opt_include}/atk-1.0
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gdk_pixbuf.opt_include}/gdk-pixbuf-2.0
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/gio-unix-2.0/
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}
      -I#{include}/gtk-3.0
      -I#{libepoxy.opt_include}
      -I#{libpng.opt_include}/libpng16
      -I#{pango.opt_include}/pango-1.0
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{atk.opt_lib}
      -L#{cairo.opt_lib}
      -L#{gdk_pixbuf.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -latk-1.0
      -lcairo
      -lcairo-gobject
      -lgdk-3
      -lgdk_pixbuf-2.0
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
      -lgtk-3
      -lintl
      -lpango-1.0
      -lpangocairo-1.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
