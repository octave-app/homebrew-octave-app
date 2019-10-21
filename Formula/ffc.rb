class Ffc < Formula
  desc "FEniCS Form Compiler, a compiler for finite element variational forms"
  homepage "https://bitbucket.org/fenics-project/ffc/src/master/"
  url "https://bitbucket.org/fenics-project/ffc/downloads/ffc-2019.1.0.tar.gz"
  sha256 "4ff821a234869d8b9aaf8c5d7f617d42f9c134a2529e76c9519b681dff35affd"

  def install
    system "pip3", "install", "."
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test ffc`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
