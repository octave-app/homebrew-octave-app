class GobjectIntrospection15800 < Formula
  desc "Generate introspection data for GObject libraries"
  homepage "https://wiki.gnome.org/Projects/GObjectIntrospection"
  url "https://download.gnome.org/sources/gobject-introspection/1.58/gobject-introspection-1.58.0.tar.xz"
  sha256 "27c1590a32749de0a5481ce897772547043e94bccba4bc0a7edb3d8513e401ec"

  

  depends_on "cairo_1.16.0_0"
  depends_on "glib_2.58.1_0"
  depends_on "libffi_3.2.1_0"
  depends_on "pkg-config_0.29.2_0"
  depends_on "python_2.7.15_1"

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
                          "--with-python=#{Formula["python_2.7.15_1"].opt_bin}/python2"
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
