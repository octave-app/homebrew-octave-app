class Atk23000 < Formula
  desc "GNOME accessibility toolkit"
  homepage "https://library.gnome.org/devel/atk/"
  url "https://download.gnome.org/sources/atk/2.30/atk-2.30.0.tar.xz"
  sha256 "dd4d90d4217f2a0c1fee708a555596c2c19d26fef0952e1ead1938ab632c027b"

  

  depends_on "gobject-introspection_1.58.0_0" => :build
  depends_on "meson-internal_0.46.1_0" => :build
  depends_on "ninja_1.8.2_0" => :build
  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "glib_2.58.1_0"

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
    glib = Formula["glib_2.58.1_0"]
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
index 59abf5e..7af4f12 100644
--- a/meson.build
+++ b/meson.build
@@ -73,11 +73,6 @@ if host_machine.system() == 'linux'
   common_ldflags += cc.get_supported_link_arguments(test_ldflags)
 endif

-# Maintain compatibility with autotools on macOS
-if host_machine.system() == 'darwin'
-  common_ldflags += [ '-compatibility_version 1', '-current_version 1.0', ]
-endif
-
 # Functions
 checked_funcs = [
   'bind_textdomain_codeset',
