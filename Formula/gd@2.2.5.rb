class GdAT225 < Formula
  desc "Graphics library to dynamically manipulate images"
  homepage "https://libgd.github.io/"
  url "https://github.com/libgd/libgd/releases/download/gd-2.2.5/libgd-2.2.5.tar.xz"
  sha256 "8c302ccbf467faec732f0741a859eef4ecae22fea2d2ab87467be940842bde51"

  

  head do
    url "https://github.com/libgd/libgd.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "fontconfig@2.13.0"
  depends_on "freetype@2.9.1"
  depends_on "jpeg@9c"
  depends_on "libpng@1.6.34"
  depends_on "libtiff@4.0.9"
  depends_on "webp@1.0.0"

  def install
    system "./bootstrap.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-freetype=#{Formula["freetype@2.9.1"].opt_prefix}",
                          "--with-png=#{Formula["libpng@1.6.34"].opt_prefix}",
                          "--without-x",
                          "--without-xpm"
    system "make", "install"
  end

  test do
    system "#{bin}/pngtogd", test_fixtures("test.png"), "gd_test.gd"
    system "#{bin}/gdtopng", "gd_test.gd", "gd_test.png"
  end
end
