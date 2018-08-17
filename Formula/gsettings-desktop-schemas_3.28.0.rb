class GsettingsDesktopSchemas3280 < Formula
  desc "GSettings schemas for desktop components"
  homepage "https://download.gnome.org/sources/gsettings-desktop-schemas/"
  url "https://download.gnome.org/sources/gsettings-desktop-schemas/3.28/gsettings-desktop-schemas-3.28.0.tar.xz"
  sha256 "4cb4cd7790b77e5542ec75275237613ad22f3a1f2f41903a298cf6cc996a9167"

  

  depends_on "pkg-config_0.29.2" => :build
  depends_on "intltool_0.51.0" => :build
  depends_on "gobject-introspection_1.56.1" => :build
  depends_on "glib_2.56.1"
  depends_on "gettext_0.19.8.1"
  depends_on "libffi_3.2.1"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-schemas-compile",
                          "--enable-introspection=yes"
    system "make", "install"
  end

  def post_install
    # manual schema compile step
    system "#{Formula["glib_2.56.1"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gdesktop-enums.h>

      int main(int argc, char *argv[]) {
        return 0;
      }
    EOS
    system ENV.cc, "-I#{HOMEBREW_PREFIX}/include/gsettings-desktop-schemas", "test.c", "-o", "test"
    system "./test"
  end
end
