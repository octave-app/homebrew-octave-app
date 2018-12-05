class Texinfo650 < Formula
  desc "Official documentation format of the GNU project"
  homepage "https://www.gnu.org/software/texinfo/"
  url "https://ftp.gnu.org/gnu/texinfo/texinfo-6.5.tar.xz"
  mirror "https://ftpmirror.gnu.org/texinfo/texinfo-6.5.tar.xz"
  sha256 "77774b3f4a06c20705cc2ef1c804864422e3cf95235e965b1f00a46df7da5f62"

  

  keg_only :provided_by_macos, <<~EOS
    software that uses TeX, such as lilypond and octave, require a newer
    version of these files
  EOS

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-install-warnings",
                          "--prefix=#{prefix}"
    system "make", "install"
    doc.install Dir["doc/refcard/txirefcard*"]
  end

  test do
    (testpath/"test.texinfo").write <<~EOS
      @ifnottex
      @node Top
      @top Hello World!
      @end ifnottex
      @bye
    EOS
    system "#{bin}/makeinfo", "test.texinfo"
    assert_match "Hello World!", File.read("test.info")
  end
end
