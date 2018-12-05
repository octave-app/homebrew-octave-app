class Jpeg9c0 < Formula
  desc "Image manipulation library"
  homepage "https://www.ijg.org/"
  url "https://www.ijg.org/files/jpegsrc.v9c.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/jpeg-9c.tar.gz"
  mirror "https://fossies.org/linux/misc/jpegsrc.v9c.tar.gz"
  sha256 "650250979303a649e21f87b5ccd02672af1ea6954b911342ea491f351ceb7122"

  

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/djpeg", test_fixtures("test.jpg")
  end
end
