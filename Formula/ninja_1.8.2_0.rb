class Ninja1820 < Formula
  desc "Small build system for use with gyp or CMake"
  homepage "https://ninja-build.org/"
  url "https://github.com/ninja-build/ninja/archive/v1.8.2.tar.gz"
  sha256 "86b8700c3d0880c2b44c2ff67ce42774aaf8c28cbf57725cb881569288c1c6f4"
  head "https://github.com/ninja-build/ninja.git"

  

  def install
    system "python", "configure.py", "--bootstrap"

    # Quickly test the build
    system "./configure.py"
    system "./ninja", "ninja_test"
    system "./ninja_test", "--gtest_filter=-SubprocessTest.SetWithLots"

    bin.install "ninja"
    bash_completion.install "misc/bash-completion" => "ninja-completion.sh"
    zsh_completion.install "misc/zsh-completion" => "_ninja"
  end

  test do
    (testpath/"build.ninja").write <<~EOS
      cflags = -Wall

      rule cc
        command = gcc $cflags -c $in -o $out

      build foo.o: cc foo.c
    EOS
    system bin/"ninja", "-t", "targets"
  end
end
