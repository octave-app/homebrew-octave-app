class LxqtBuildTools < Formula
  desc "Various packaging tools and scripts for LXQt applications"
  homepage "http://lxqt.org"
  url "https://github.com/lxqt/lxqt-build-tools/releases/download/0.6.0/lxqt-build-tools-0.6.0.tar.xz"
  sha256 "2488f1105ba8008996b4f6a0df5c556c657c733a47a422ea3f2e59115c051758"
  head "https://github.com/lxqt/lxqt-build-tools.git"
  
  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "qt"
  depends_on "glib"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end
end
