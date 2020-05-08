# Note: the current release is not working on macOS; you will
# probably need to install this (and its qtermwidget dependency)
# with --HEAD to get it to work.
class Qterminal < Formula
  desc "A lightweight Qt-based terminal emulator"
  homepage "http://lxqt.org"
  url "https://github.com/lxqt/qterminal/releases/download/0.15.0/qterminal-0.15.0.tar.xz"
  sha256 "557f74a946d009bb6e598c5d0c6de9356cda325f674876a457874c7525affd64"
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
