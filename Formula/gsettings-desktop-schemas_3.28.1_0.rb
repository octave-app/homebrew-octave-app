class GsettingsDesktopSchemas32810 < Formula
  desc "GSettings schemas for desktop components"
  homepage "https://download.gnome.org/sources/gsettings-desktop-schemas/"
  url "https://download.gnome.org/sources/gsettings-desktop-schemas/3.28/gsettings-desktop-schemas-3.28.1.tar.xz"
  sha256 "f88ea6849ffe897c51cfeca5e45c3890010c82c58be2aee18b01349648e5502f"

  

  depends_on "gobject-introspection_1.58.0_0" => :build
  depends_on "intltool_0.51.0_0" => :build
  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "gettext_0.19.8.1_0"
  depends_on "glib_2.58.1_0"
  depends_on "libffi_3.2.1_0"

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
    system "#{Formula["glib_2.58.1_0"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
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
