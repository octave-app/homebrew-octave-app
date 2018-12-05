class Libcroco06120 < Formula
  desc "CSS parsing and manipulation toolkit for GNOME"
  homepage "http://www.linuxfromscratch.org/blfs/view/svn/general/libcroco.html"
  url "https://download.gnome.org/sources/libcroco/0.6/libcroco-0.6.12.tar.xz"
  sha256 "ddc4b5546c9fb4280a5017e2707fbd4839034ed1aba5b7d4372212f34f84f860"

  

  depends_on "intltool_0.51.0_0" => :build
  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "glib_2.58.1_0"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-Bsymbolic"
    system "make", "install"
  end

  test do
    (testpath/"test.css").write ".brew-pr { color: green }"
    assert_equal ".brew-pr {\n  color : green\n}",
      shell_output("#{bin}/csslint-0.6 test.css").chomp
  end
end
