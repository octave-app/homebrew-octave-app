class Glpk4650 < Formula
  desc "Library for Linear and Mixed-Integer Programming"
  homepage "https://www.gnu.org/software/glpk/"
  url "https://ftp.gnu.org/gnu/glpk/glpk-4.65.tar.gz"
  mirror "https://ftpmirror.gnu.org/glpk/glpk-4.65.tar.gz"
  sha256 "4281e29b628864dfe48d393a7bedd781e5b475387c20d8b0158f329994721a10"

  

  depends_on "gmp_6.1.2_2"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--with-gmp"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include "glpk.h"

      int main(int argc, const char *argv[])
      {
        printf("%s", glp_version());
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}", "-lglpk", "-o", "test"
    assert_match version.to_s, shell_output("./test")
  end
end
