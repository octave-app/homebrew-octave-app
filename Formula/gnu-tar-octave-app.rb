# Customized to install without "g" prefixes by default, so we can
# get "tar" as a GNU tar on the path by default; Octave isn't compatible
# with BSD tar (yet; see https://savannah.gnu.org/bugs/index.php?53695).
class GnuTarOctaveApp < Formula
  desc "GNU version of the tar archiving utility"
  homepage "https://www.gnu.org/software/tar/"
  url "https://ftp.gnu.org/gnu/tar/tar-1.31.tar.gz"
  mirror "https://ftpmirror.gnu.org/tar/tar-1.31.tar.gz"
  sha256 "b471be6cb68fd13c4878297d856aebd50551646f4e3074906b1a74549c40d5a2"

  head do
    url "https://git.savannah.gnu.org/git/tar.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
  end

  def install
    # Work around unremovable, nested dirs bug that affects lots of
    # GNU projects. See:
    # https://github.com/Homebrew/homebrew/issues/45273
    # https://github.com/Homebrew/homebrew/issues/44993
    # This is thought to be an el_capitan bug:
    # https://lists.gnu.org/archive/html/bug-tar/2015-10/msg00017.html
    ENV["gl_cv_func_getcwd_abort_bug"] = "no" if MacOS.version == :el_capitan

    args = %W[
      --prefix=#{prefix}
      --mandir=#{man}
    ]

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
