class Libmpc1100 < Formula
  desc "C library for the arithmetic of high precision complex numbers"
  homepage "http://www.multiprecision.org/mpc/"
  url "https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz"
  sha256 "6985c538143c1208dcb1ac42cedad6ff52e267b47e5f970183a3e75125b43c2e"

  

  depends_on "gmp_6.1.2_2"
  depends_on "mpfr_4.0.1_0"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-gmp=#{Formula["gmp_6.1.2_2"].opt_prefix}
      --with-mpfr=#{Formula["mpfr_4.0.1_0"].opt_prefix}
    ]

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <mpc.h>
      #include <assert.h>
      #include <math.h>

      int main() {
        mpc_t x;
        mpc_init2 (x, 256);
        mpc_set_d_d (x, 1., INFINITY, MPC_RNDNN);
        mpc_tanh (x, x, MPC_RNDNN);
        assert (mpfr_nan_p (mpc_realref (x)) && mpfr_nan_p (mpc_imagref (x)));
        mpc_clear (x);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-L#{Formula["mpfr_4.0.1_0"].opt_lib}",
                   "-L#{Formula["gmp_6.1.2_2"].opt_lib}", "-lmpc", "-lmpfr",
                   "-lgmp", "-o", "test"
    system "./test"
  end
end
