# GNU tar, Octave.app-hacked version.
# Customized to install without "g" prefixes by default, so we can
# get "tar" as a GNU tar on the path by default; Octave isn't compatible
# with BSD tar (yet; see https://savannah.gnu.org/bugs/index.php?53695).
# As Octave 7.x, or maybe even 6.3, this is probably no longer needed.
class GnuTarOctapp < Formula
  desc "GNU version of the tar archiving utility (octave-app variant)"
  homepage "https://www.gnu.org/software/tar/"
  url "https://ftp.gnu.org/gnu/tar/tar-1.35.tar.gz"
  mirror "https://ftpmirror.gnu.org/tar/tar-1.35.tar.gz"
  sha256 "14d55e32063ea9526e057fbf35fcabd53378e769787eff7919c3755b02d2b57e"
  license "GPL-3.0-or-later"

  head do
    url "https://git.savannah.gnu.org/git/tar.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --mandir=#{man}
      --disable-nls
    ]

    # iconv is detected during configure process but -liconv is missing
    # from LDFLAGS as of gnu-tar 1.35. Remove once iconv linking works
    # without this. See https://savannah.gnu.org/bugs/?64441.
    # fix commit, http://git.savannah.gnu.org/cgit/tar.git/commit/?id=8632df39, remove in next release
    ENV.append "LDFLAGS", "-liconv" if OS.mac?

    system "./bootstrap" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test").write("test")
    system bin/"tar", "-czvf", "test.tar.gz", "test"
    assert_match /test/, shell_output("#{bin}/tar -xOzf test.tar.gz")
  end
end
