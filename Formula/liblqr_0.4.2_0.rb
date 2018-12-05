class Liblqr0420 < Formula
  desc "C/C++ seam carving library"
  homepage "https://liblqr.wikidot.com/"
  url "https://liblqr.wdfiles.com/local--files/en:download-page/liblqr-1-0.4.2.tar.bz2"
  version "0.4.2"
  sha256 "173a822efd207d72cda7d7f4e951c5000f31b10209366ff7f0f5972f7f9ff137"
  head "https://repo.or.cz/liblqr.git"

  

  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "glib_2.58.1_0"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
