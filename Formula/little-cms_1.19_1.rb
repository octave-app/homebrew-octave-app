class LittleCms1191 < Formula
  desc "Version 1 of the Little CMS library"
  homepage "http://www.littlecms.com/"
  url "https://downloads.sourceforge.net/project/lcms/lcms/1.19/lcms-1.19.tar.gz"
  sha256 "80ae32cb9f568af4dc7ee4d3c05a4c31fc513fc3e31730fed0ce7378237273a9"
  revision 1

  

  depends_on "jpeg_9c_0"
  depends_on "libtiff_4.0.9_5"

  def install
    args = %W[--disable-dependency-tracking --disable-debug --prefix=#{prefix}]
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
