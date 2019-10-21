class Dolfin < Formula
  desc "The C++/Python interface of FEniCS"
  homepage "https://pypi.org/project/DOLFIN/"
  url "https://bitbucket.org/fenics-project/dolfin/downloads/dolfin-2016.1.0.tar.gz"
  sha256 "6228b4d641829a4cd32141bfcd217a1596a27d5969aa00ee64ebba2b1c0fb148"
  head "https://bitbucket.org/fenics-project/dolfin.git"

  depends_on "cmake" => :build
  depends_on "cppunit" => :build
  depends_on "pkgconfig" => :build
  depends_on "swig" => :build
  depends_on "boost"
  depends_on "eigen"
  depends_on "ffc"
  depends_on "fiat"
  depends_on "instant"
  depends_on "numpy"
  depends_on "open-mpi"
  depends_on "petsc"
  depends_on "python"
  depends_on "suite-sparse"
  # We don't have Trilinos working yet
  #depends_on "trilinos"
  depends_on "ufl"
  depends_on "vtk"
  # Note from upstream: MPI, PETSc and SLEPc must be installed before installing mpi4py, petsc4py and slepc4py
  # TODO: Add: mpi4py, petsc4py, ply, slepc4py (all Python things)
  # TODO: Add: parmetis, pastix, slepc, scotch
  #   parmetis, scotch are in tap dpo/openblas. This may be
  #   an issue since Octave.app is building against Accelerate instead of OpenBLAS
  # TODO: Add: trilinos

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  def install
    mkdir "build"
    cd "build"
    system "cmake", "..", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"poisson.py").write <<-EOS.undent
      from dolfin import *
      mesh = UnitSquareMesh(32, 32)
      V = FunctionSpace(mesh, "Lagrange", 1)

      def boundary(x):
        return x[0] < DOLFIN_EPS or x[0] > 1.0 - DOLFIN_EPS

      u0 = Constant(0.0)
      bc = DirichletBC(V, u0, boundary)
      u = TrialFunction(V)
      v = TestFunction(V)
      f = Expression("10*exp(-(pow(x[0] - 0.5, 2) + pow(x[1] - 0.5, 2)) / 0.02)")
      g = Expression("sin(5*x[0])")
      a = inner(grad(u), grad(v))*dx
      L = f*v*dx + g*v*ds

      u = Function(V)
      solve(a == L, u, bc)
    EOS
    system "python3", "poisson.py"
  end
end
