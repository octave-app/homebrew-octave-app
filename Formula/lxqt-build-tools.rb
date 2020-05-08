class LxqtBuildTools < Formula
  desc "Various packaging tools and scripts for LXQt applications"
  homepage "http://lxqt.org"
  url "https://github.com/lxqt/lxqt-build-tools/releases/download/0.7.0/lxqt-build-tools-0.7.0.tar.xz"
  sha256 "85fe1946a92731f22585c30eda8bea923f5221ffbea0e31dc834d722d86cfb90"
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
