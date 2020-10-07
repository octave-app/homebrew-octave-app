class Librsb < Formula
  desc "Recursive Sparse Blocks shared memory parallel sparce matrix library"
  homepage "http://librsb.sourceforge.net/"
  url "https://sourceforge.net/projects/librsb/files/librsb-1.2.0.8.tar.gz"
  sha256 "8bebd19a1866d80ade13eabfdd0f07ae7e8a485c0b975b5d15f531ac204d80cb"

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
