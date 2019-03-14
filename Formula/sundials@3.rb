class SundialsAT3 < Formula
  desc "Nonlinear and differential/algebraic equations solver"
  homepage "https://computation.llnl.gov/casc/sundials/main.html"
  # The official download site is always really slow, so use a mirror instead
  url "https://github.com/octave-app/homebrew-octave-app/releases/download/v0.1/sundials-3.2.1.tar.gz"
  # This is actually the official download
  mirror "https://computation.llnl.gov/projects/sundials/download/sundials-3.2.1.tar.gz"
  sha256 "47d94d977ab2382cdcdd02f72a25ebd4ba8ca2634bbb2f191fe1636e71c86808"

  keg_only :versioned_formula

  option "with-openmp", "Enable OpenMP multithreading"
  option "without-mpi", "Do not build with MPI"

  depends_on "cmake" => :build
  depends_on "python" => :build
  depends_on "gcc" # for gfortran
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "suite-sparse"
  depends_on "veclibfort"

  def install
    blas = "-L#{Formula["veclibfort"].opt_lib} -lvecLibFort"
    args = std_cmake_args + %W[
      -DCMAKE_C_COMPILER=#{ENV["CC"]}
      -DBUILD_SHARED_LIBS=ON
      -DKLU_ENABLE=ON
      -DKLU_LIBRARY_DIR=#{Formula["suite-sparse"].opt_lib}
      -DKLU_INCLUDE_DIR=#{Formula["suite-sparse"].opt_include}
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
                   "test_nvector_serial.c", "-L#{lib}", "-lsundials_nvecserial", "-lm"
    assert_match "SUCCESS: NVector module passed all tests",
                 shell_output("./a.out 42 0")
  end
end
