class Libtiff409 < Formula
  desc "TIFF library and utilities"
  homepage "http://libtiff.maptools.org/"
  url "https://download.osgeo.org/libtiff/tiff-4.0.9.tar.gz"
  mirror "https://fossies.org/linux/misc/tiff-4.0.9.tar.gz"
  sha256 "6e7bdeec2c310734e734d19aae3a71ebe37a4d842e0e23dbb1b8921c0026cfcd"
  revision 4

  

  option "with-xz", "Include support for LZMA compression"

  depends_on "jpeg_9c"
  depends_on "xz_5.2.4" => :optional

  # All of these have been reported upstream & should
  # be fixed in the next release, but please check.
  patch do
    url "https://mirrors.ocf.berkeley.edu/debian/pool/main/t/tiff/tiff_4.0.9-6.debian.tar.xz"
    mirror "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/t/tiff/tiff_4.0.9-6.debian.tar.xz"
    sha256 "4e145dcde596e0c406a9f482680f9ddd09bed61a0dc6d3ac7e4c77c8ae2dd383"
    apply "patches/CVE-2017-9935.patch",
          "patches/CVE-2017-18013.patch",
          "patches/CVE-2018-5784.patch",
          "patches/CVE-2017-11613_part1.patch",
          "patches/CVE-2017-11613_part2.patch",
          "patches/CVE-2018-7456.patch",
          "patches/CVE-2017-17095.patch",
          "patches/CVE-2018-8905.patch",
          "patches/CVE-2018-10963.patch"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --without-x
      --with-jpeg-include-dir=#{Formula["jpeg_9c"].opt_include}
      --with-jpeg-lib-dir=#{Formula["jpeg_9c"].opt_lib}
    ]
    if build.with? "xz"
      args << "--with-lzma-include-dir=#{Formula["xz_5.2.4"].opt_include}"
      args << "--with-lzma-lib-dir=#{Formula["xz_5.2.4"].opt_lib}"
    else
      args << "--disable-lzma"
    end
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <tiffio.h>

      int main(int argc, char* argv[])
      {
        TIFF *out = TIFFOpen(argv[1], "w");
        TIFFSetField(out, TIFFTAG_IMAGEWIDTH, (uint32) 10);
        TIFFClose(out);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-ltiff", "-o", "test"
    system "./test", "test.tif"
    assert_match(/ImageWidth.*10/, shell_output("#{bin}/tiffdump test.tif"))
  end
end
