class Qtermwidget < Formula
  desc "The terminal widget for QTerminal"
  homepage "http://lxqt.org"
  url "https://github.com/lxqt/qtermwidget/releases/download/0.15.0/qtermwidget-0.15.0.tar.xz"
  sha256 "6ecaf7c91be282c5e34937a853fe649729966c38d7e8f4cf54c0df94d85ac3ee"
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
