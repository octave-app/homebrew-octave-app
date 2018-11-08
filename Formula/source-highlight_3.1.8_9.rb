class SourceHighlight3189 < Formula
  desc "Source-code syntax highlighter"
  homepage "https://www.gnu.org/software/src-highlite/"
  url "https://ftp.gnu.org/gnu/src-highlite/source-highlight-3.1.8.tar.gz"
  mirror "https://ftpmirror.gnu.org/src-highlite/source-highlight-3.1.8.tar.gz"
  mirror "https://fossies.org/linux/www/source-highlight-3.1.8.tar.gz"
  sha256 "01336a7ea1d1ccc374201f7b81ffa94d0aecb33afc7d6903ebf9fbf33a55ada3"
  revision 9

  

  depends_on "boost_1.67.0_1"

  needs :cxx11

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-boost=#{Formula["boost_1.67.0_1"].opt_prefix}"
    system "make", "install"

    bash_completion.install "completion/source-highlight"
  end

  test do
    assert_match /GNU Source-highlight #{version}/, shell_output("#{bin}/source-highlight -V")
  end
end
