class Itstool2050 < Formula
  desc "Make XML documents translatable through PO files"
  homepage "http://itstool.org/"
  url "https://github.com/itstool/itstool/archive/2.0.5.tar.gz"
  sha256 "97f98e1a5f8f49239e4256570ecfe12caf88b7cfdb4fcb40f4b761ce7ea2a8c3"
  head "https://github.com/itstool/itstool.git"

  

  depends_on "autoconf_2.69_0" => :build
  depends_on "automake_1.16.1_1" => :build
  depends_on "libxml2_2.9.8_1"
  depends_on "python_3.7.2_0"

  def install
    xy = Language::Python.major_minor_version "python3"
    ENV.append_path "PYTHONPATH", "#{Formula["libxml2_2.9.8_1"].opt_lib}/python#{xy}/site-packages"

    system "./autogen.sh", "--prefix=#{libexec}",
                           "PYTHON=#{Formula["python_3.7.2_0"].opt_bin}/python3"
    system "make", "install"

    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
    pkgshare.install_symlink libexec/"share/itstool/its"
    man1.install_symlink libexec/"share/man/man1/itstool.1"
  end

  test do
    (testpath/"test.xml").write <<~EOS
      <tag>Homebrew</tag>
    EOS
    system bin/"itstool", "-o", "test.pot", "test.xml"
    assert_match "msgid \"Homebrew\"", File.read("test.pot")
  end
end
