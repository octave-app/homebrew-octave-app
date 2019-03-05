class Qterminal < Formula
  desc "A lightweight Qt-based terminal emulator"
  homepage "http://lxqt.org"
  url "https://github.com/lxqt/qterminal/releases/download/0.9.0/qterminal-0.9.0.tar.xz"
  sha256 "4157980356af4e05cfe5fa3badecba6e25715a35e2b7f9a830da87bcca519fee"
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
