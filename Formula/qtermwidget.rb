class Qtermwidget < Formula
  desc "The terminal widget for QTerminal"
  homepage "http://lxqt.org"
  url "https://github.com/lxqt/qtermwidget/releases/download/0.14.1/qtermwidget-0.14.1.tar.xz"
  sha256 "84739f91e6ac5900a39ed7cbb254397a9428b172ee3fe0d1b6c827b751dc3b6c"
  head "https://github.com/lxqt/qtermwidget.git"
  
  depends_on "cmake" => :build
  depends_on "lxqt-build-tools" => :build
  depends_on "qt"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end
end
