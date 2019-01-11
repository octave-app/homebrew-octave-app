class Sundials4000 < Formula
  desc "Nonlinear and differential/algebraic equations solver"
  homepage "https://computation.llnl.gov/casc/sundials/main.html"
  url "https://computation.llnl.gov/projects/sundials/download/sundials-4.0.0.tar.gz"
  sha256 "953dd7c30d25d5e28f6aa4d803c5b6160294a5c0c9572ac4e9c7e2d461bd9a19"

  

  depends_on "cmake_3.13.2_0" => :build
  depends_on "gcc_8.2.0_0" # for gfortran
  depends_on "open-mpi_4.0.0_0"
  depends_on "suite-sparse_5.3.0_0"
  depends_on "veclibfort_0.4.2_6"

  def install
    blas = "-L#{Formula["veclibfort_0.4.2_6"].opt_lib} -lvecLibFort"
    args = std_cmake_args + %W[
      -DCMAKE_C_COMPILER=#{ENV["CC"]}
      -DBUILD_SHARED_LIBS=ON
      -DKLU_ENABLE=ON
      -DKLU_LIBRARY_DIR=#{Formula["suite-sparse_5.3.0_0"].opt_lib}
      -DKLU_INCLUDE_DIR=#{Formula["suite-sparse_5.3.0_0"].opt_include}
      -DLAPACK_ENABLE=ON
      -DLAPACK_LIBRARIES=#{blas};#{blas}
      -DMPI_ENABLE=ON
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    cp Dir[prefix/"examples/nvector/serial/*"], testpath
    system ENV.cc, "-I#{include}", "test_nvector.c", "sundials_nvector.c",
                   "test_nvector_serial.c", "-L#{lib}", "-lsundials_nvecserial"
    assert_match "SUCCESS: NVector module passed all tests",
                 shell_output("./a.out 42 0")
  end
end
