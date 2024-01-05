class Librsb < Formula
  desc "Recursive Sparse Blocks shared memory parallel sparce matrix library"
  homepage "http://librsb.sourceforge.net/"
  url "https://sourceforge.net/projects/librsb/files/librsb-1.3.0.2.tar.gz"
  sha256 "f188236c4bcc8421169917a1141a4913430a4149b1cf01cbb65fb33805437070"

  depends_on "libomp"

  def install
  	# Explicit -lomp is required on macOS
  	ENV.append "LIBS", "-lomp"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

end
