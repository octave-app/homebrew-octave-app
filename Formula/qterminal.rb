class Qterminal < Formula
  desc "A lightweight Qt-based terminal emulator"
  homepage "http://lxqt.org"
  url "https://github.com/lxqt/qterminal/releases/download/0.14.1/qterminal-0.14.1.tar.xz"
  sha256 "e018ece0bd38124a2879a6fbb76dd6b9d70ae2b231845650ad363eeca756fe31"
  head "https://github.com/lxqt/qterminal.git"

  depends_on "cmake" => :build
  depends_on "lxqt-build-tools" => :build
  depends_on "qt"
  depends_on "qtermwidget"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end
end
