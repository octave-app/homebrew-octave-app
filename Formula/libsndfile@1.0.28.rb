class LibsndfileAT1028 < Formula
  desc "C library for files containing sampled sound"
  homepage "http://www.mega-nerd.com/libsndfile/"
  url "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28.tar.gz"
  sha256 "1ff33929f042fa333aed1e8923aa628c3ee9e1eb85512686c55092d1e5a9dfa9"

  

  depends_on "pkg-config@0.29.2" => :build
  depends_on "autoconf@2.69" => :build
  depends_on "automake@1.16.1" => :build
  depends_on "libtool@2.4.6" => :build
  depends_on "flac@1.3.2"
  depends_on "libogg@1.3.3"
  depends_on "libvorbis@1.3.6"

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
