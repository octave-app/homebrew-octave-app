class Librsb < Formula
  desc "Recursive Sparse Blocks shared memory parallel sparce matrix library"
  homepage "http://librsb.sourceforge.net/"
  url "https://sourceforge.net/projects/librsb/files/librsb-1.3.0.2.tar.gz"
  sha256 "18c6fc443fa1cfd2a8110f7d4b88d5bbcb493b9e85b3a62014b8bb57a848e04f"

  depends_on "gcc" # for Fortran compiler
  depends_on "libomp"

  def install
    # Needs C++14
    # Use gnu++14 instead of c++14 as octave uses GNU extensions.
    ENV.append "CXX", "-std=gnu++14"

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
