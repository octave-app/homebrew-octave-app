class Libsndfile10280 < Formula
  desc "C library for files containing sampled sound"
  homepage "http://www.mega-nerd.com/libsndfile/"
  url "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28.tar.gz"
  sha256 "1ff33929f042fa333aed1e8923aa628c3ee9e1eb85512686c55092d1e5a9dfa9"

  

  depends_on "autoconf_2.69_0" => :build
  depends_on "automake_1.16.1_1" => :build
  depends_on "libtool_2.4.6_1" => :build
  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "flac_1.3.2_1"
  depends_on "libogg_1.3.3_0"
  depends_on "libvorbis_1.3.6_0"

  def install
    system "autoreconf", "-fvi"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/sndfile-info #{test_fixtures("test.wav")}")
    assert_match "Duration    : 00:00:00.064", output
  end
end
