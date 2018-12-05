class Libheif1321 < Formula
  desc "ISO/IEC 23008-12:2017 HEIF file format decoder and encoder"
  homepage "https://www.libde265.org/"
  url "https://github.com/strukturag/libheif/releases/download/v1.3.2/libheif-1.3.2.tar.gz"
  sha256 "a9e12a693fc172baa16669f427063edd7bf07964a1cb623ee57cd056c06ee3fc"
  revision 1

  

  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "jpeg_9c_0"
  depends_on "libde265_1.0.3_0"
  depends_on "libpng_1.6.35_0"
  depends_on "x265_2.9_0"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
    pkgshare.install "examples/example.heic"
  end

  test do
    output = "File contains 2 images"
    example = pkgshare/"example.heic"
    exout = testpath/"example.jpg"

    assert_match output, shell_output("#{bin}/heif-convert #{example} #{exout}")
    assert_predicate testpath/"example-1.jpg", :exist?
    assert_predicate testpath/"example-2.jpg", :exist?
  end
end
