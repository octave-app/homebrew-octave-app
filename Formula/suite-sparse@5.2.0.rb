class SuiteSparseAT520 < Formula
  desc "Suite of Sparse Matrix Software"
  homepage "http://faculty.cse.tamu.edu/davis/suitesparse.html"
  url "http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-5.2.0.tar.gz"
  sha256 "3c46c035ea8217649958a0f73360e825b0c9dcca4e32a9349d2c7678c0d48813"

  

  depends_on "cmake@3.11.4" => :build
  depends_on "metis@5.1.0"

  def install
    mkdir "GraphBLAS/build" do
      system "cmake", "..", *std_cmake_args
    end

    args = [
      "INSTALL=#{prefix}",
      "BLAS=-framework Accelerate",
      "LAPACK=$(BLAS)",
      "MY_METIS_LIB=-L#{Formula["metis@5.1.0"].opt_lib} -lmetis",
      "MY_METIS_INC=#{Formula["metis@5.1.0"].opt_include}",
    ]
    system "make", "library", *args
    system "make", "install", *args
    lib.install Dir["**/*.a"]
    pkgshare.install "KLU/Demo/klu_simple.c"
  end

  test do
    system ENV.cc, "-o", "test", pkgshare/"klu_simple.c",
                   "-L#{lib}", "-lsuitesparseconfig", "-lklu"
    system "./test"
  end
end
