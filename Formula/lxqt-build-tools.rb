class LxqtBuildTools < Formula
  desc "Various packaging tools and scripts for LXQt applications"
  homepage "http://lxqt.org"
  url "https://github.com/lxqt/lxqt-build-tools/releases/download/0.13.0/lxqt-build-tools-0.13.0.tar.xz"
  sha256 "fd3c199d0d7c61f23040a45ead57cc9a4f888af5995371f6b0ce1fa902eb59ce"
  head "https://github.com/lxqt/lxqt-build-tools.git"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "qt@5"
  depends_on "glib"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end
end
