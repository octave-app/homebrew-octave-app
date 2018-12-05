class Ilmbase2210 < Formula
  desc "OpenEXR ILM Base libraries (high dynamic-range image file format)"
  homepage "https://www.openexr.com/"
  url "https://download.savannah.nongnu.org/releases/openexr/ilmbase-2.2.1.tar.gz"
  sha256 "cac206e63be68136ef556c2b555df659f45098c159ce24804e9d5e9e0286609e"

  

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
    pkgshare.install %w[Half HalfTest Iex IexMath IexTest IlmThread Imath ImathTest]
  end

  test do
    cd pkgshare/"IexTest" do
      system ENV.cxx, "-I#{include}/OpenEXR", "-I./", "-c",
             "testBaseExc.cpp", "-o", testpath/"test"
    end
  end
end
