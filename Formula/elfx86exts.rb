class Elfx86exts < Formula
  desc "Show instruction set extensions used by x86 binaries"
  homepage "https://github.com/pkgw/elfx86exts"
  url "https://github.com/pkgw/elfx86exts/archive/v0.3.0.tar.gz"
  sha256 "a1d9e7adda242dd52d2e3e6f72cf129254e9a2adc5534f7aa221a41f9e1571c0"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    system bin/"elfx86exts", bin/"elfx86exts"
  end
end
