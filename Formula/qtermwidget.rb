class Qtermwidget < Formula
  desc "The terminal widget for QTerminal"
  homepage "http://lxqt.org"
  url "https://github.com/lxqt/qtermwidget/releases/download/0.9.0/qtermwidget-0.9.0.tar.xz"
  sha256 "e39ce62fec18112634630654f41f08f4be4638bcf0bebbc89d71c9aefdfa38b0"
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
