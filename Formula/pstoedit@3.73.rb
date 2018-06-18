class PstoeditAT373 < Formula
  desc "Convert PostScript and PDF files to editable vector graphics"
  homepage "http://www.pstoedit.net/"
  url "https://downloads.sourceforge.net/project/pstoedit/pstoedit/3.73/pstoedit-3.73.tar.gz"
  sha256 "ad31d13bf4dd1b9e2590dccdbe9e4abe74727aaa16376be85cd5d854f79bf290"

  

  depends_on "pkg-config@0.29.2" => :build
  depends_on "plotutils@2.6"
  depends_on "ghostscript@9.23"
  depends_on "imagemagick@7.0.8-1"
  depends_on "xz" if MacOS.version < :mavericks

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"pstoedit", "-f", "gs:pdfwrite", test_fixtures("test.ps"), "test.pdf"
    assert_predicate testpath/"test.pdf", :exist?
  end
end
