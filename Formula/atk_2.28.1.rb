class Atk2281 < Formula
  desc "GNOME accessibility toolkit"
  homepage "https://library.gnome.org/devel/atk/"
  url "https://download.gnome.org/sources/atk/2.28/atk-2.28.1.tar.xz"
  sha256 "cd3a1ea6ecc268a2497f0cd018e970860de24a6d42086919d6bf6c8e8d53f4fc"
  revision 2

  

  depends_on "gobject-introspection_1.56.1" => :build
  depends_on "meson-internal_0.45.1" => :build
  depends_on "ninja_1.8.2" => :build
  depends_on "pkg-config_0.29.2" => :build
  depends_on "glib_2.56.1"

  patch :DATA

  def install
    ENV.refurbish_args

    mkdir "build" do
      system "meson", "--prefix=#{prefix}", ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <atk/atk.h>

      int main(int argc, char *argv[]) {
        const gchar *version = atk_get_version();
        return 0;
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib_2.56.1"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/atk-1.0
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -latk-1.0
      -lglib-2.0
      -lgobject-2.0
      -lintl
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end

__END__
diff --git a/meson.build b/meson.build
index 7d5a31b..b5c695a 100644
--- a/meson.build
+++ b/meson.build
@@ -80,11 +80,6 @@ if host_machine.system() == 'linux'
   endforeach
 endif

-# Maintain compatibility with autotools on macOS
-if host_machine.system() == 'darwin'
-  common_ldflags += [ '-compatibility_version=1', '-current_version=1.0', ]
-endif
-
 # Functions
 checked_funcs = [
   'bind_textdomain_codeset',
