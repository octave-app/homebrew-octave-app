class Fribidi1050 < Formula
  desc "Implementation of the Unicode BiDi algorithm"
  homepage "https://github.com/fribidi/fribidi"
  url "https://github.com/fribidi/fribidi/releases/download/v1.0.5/fribidi-1.0.5.tar.bz2"
  sha256 "6a64f2a687f5c4f203a46fa659f43dd43d1f8b845df8d723107e8a7e6158e4ce"

  

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-static"
    system "make", "install"
  end

  test do
    (testpath/"test.input").write <<~EOS
      a _lsimple _RteST_o th_oat
    EOS

    assert_match /a simple TSet that/, shell_output("#{bin}/fribidi --charset=CapRTL --test test.input")
  end
end
