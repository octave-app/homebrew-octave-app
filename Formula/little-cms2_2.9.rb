class LittleCms229 < Formula
  desc "Color management engine supporting ICC profiles"
  homepage "http://www.littlecms.com/"
  # Ensure release is announced on http://www.littlecms.com/download.html
  url "https://downloads.sourceforge.net/project/lcms/lcms/2.9/lcms2-2.9.tar.gz"
  sha256 "48c6fdf98396fa245ed86e622028caf49b96fa22f3e5734f853f806fbc8e7d20"
  version_scheme 1

  

  depends_on "jpeg_9c" => :recommended
  depends_on "libtiff_4.0.10_0" => :recommended

  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    args << "--without-tiff" if build.without? "libtiff"
    args << "--without-jpeg" if build.without? "jpeg"

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/jpgicc", test_fixtures("test.jpg"), "out.jpg"
    assert_predicate testpath/"out.jpg", :exist?
  end
end
