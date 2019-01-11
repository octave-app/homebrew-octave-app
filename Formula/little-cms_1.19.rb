class LittleCms119 < Formula
  desc "Version 1 of the Little CMS library"
  homepage "http://www.littlecms.com/"
  url "https://downloads.sourceforge.net/project/lcms/lcms/1.19/lcms-1.19.tar.gz"
  sha256 "80ae32cb9f568af4dc7ee4d3c05a4c31fc513fc3e31730fed0ce7378237273a9"
  revision 1

  

  deprecated_option "with-python" => "with-python@2"

  depends_on "python_2.7.15" => :optional
  depends_on "jpeg_9c" => :recommended
  depends_on "libtiff_4.0.10_0" => :recommended

  def install
    args = %W[--disable-dependency-tracking --disable-debug --prefix=#{prefix}]
    args << "--without-tiff" if build.without? "libtiff_4.0.10_0"
    args << "--without-jpeg" if build.without? "jpeg_9c"
    if build.with? "python@2"
      args << "--with-python"
      inreplace "python/Makefile.in" do |s|
        s.change_make_var! "pkgdir", lib/"python2.7/site-packages"
      end
    end

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"
  end

  test do
    system "#{bin}/jpegicc", test_fixtures("test.jpg"), "out.jpg"
    assert_predicate testpath/"out.jpg", :exist?
  end
end
