class GobjectIntrospection15830 < Formula
  desc "Generate introspection data for GObject libraries"
  homepage "https://wiki.gnome.org/Projects/GObjectIntrospection"
  url "https://download.gnome.org/sources/gobject-introspection/1.58/gobject-introspection-1.58.3.tar.xz"
  sha256 "025b632bbd944dcf11fc50d19a0ca086b83baf92b3e34936d008180d28cdc3c8"

  

  depends_on "cairo_1.16.0_0"
  depends_on "glib_2.58.2_0"
  depends_on "libffi_3.2.1_0"
  depends_on "pkg-config_0.29.2_0"
  depends_on "python_3.7.2_0"

  resource "tutorial" do
    url "https://gist.github.com/7a0023656ccfe309337a.git",
        :revision => "499ac89f8a9ad17d250e907f74912159ea216416"
  end

  def install
    ENV["GI_SCANNER_DISABLE_CACHE"] = "true"
    inreplace "giscanner/transformer.py", "/usr/share", "#{HOMEBREW_PREFIX}/share"
    inreplace "configure" do |s|
      s.change_make_var! "GOBJECT_INTROSPECTION_LIBDIR", "#{HOMEBREW_PREFIX}/lib"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-python=#{Formula["python_3.7.2_0"].opt_bin}/python3"
    system "make"
    system "make", "install"
  end

  test do
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libffi_3.2.1_0"].opt_lib/"pkgconfig"
    resource("tutorial").stage testpath
    system "make"
    assert_predicate testpath/"Tut-0.1.typelib", :exist?
  end
end
