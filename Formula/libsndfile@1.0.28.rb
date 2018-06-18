class LibsndfileAT1028 < Formula
  desc "C library for files containing sampled sound"
  homepage "http://www.mega-nerd.com/libsndfile/"
  url "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28.tar.gz"
  sha256 "1ff33929f042fa333aed1e8923aa628c3ee9e1eb85512686c55092d1e5a9dfa9"

  bottle do
    cellar :any
    sha256 "d06bf0bf936cde67857ac3d3599944d2050ea8dc6237bad8b4c27ef86ac2eb3c" => :high_sierra
    sha256 "4e4bde6464cfbefcf7f2a9001af0ea34c6273b466ffa71ac953b2bb41eb619ec" => :sierra
    sha256 "49d17fa55815680936b529b7bbb8e5cf180c98722c7f8b45d763bfe2d1f0a5de" => :el_capitan
    sha256 "9df59790751d64c7f61682233a733030de9e6406682f3a15e30e708103930038" => :yosemite
  end

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
