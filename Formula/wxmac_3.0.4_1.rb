class Wxmac3041 < Formula
  desc "Cross-platform C++ GUI toolkit (wxWidgets for macOS)"
  homepage "https://www.wxwidgets.org"
  url "https://github.com/wxWidgets/wxWidgets/releases/download/v3.0.4/wxWidgets-3.0.4.tar.bz2"
  sha256 "96157f988d261b7368e5340afa1a0cad943768f35929c22841f62c25b17bf7f0"
  revision 1
  head "https://github.com/wxWidgets/wxWidgets.git"

  

  option "with-stl", "use standard C++ classes for everything"
  option "with-static", "build static libraries"

  depends_on "jpeg_9c_0"
  depends_on "libpng_1.6.35_0"
  depends_on "libtiff_4.0.9_4"

  def install
    args = [
      "--prefix=#{prefix}",
      "--enable-clipboard",
      "--enable-controls",
      "--enable-dataviewctrl",
      "--enable-display",
      "--enable-dnd",
      "--enable-graphics_ctx",
      "--enable-std_string",
      "--enable-svg",
      "--enable-unicode",
      "--enable-webkit",
      "--with-expat",
      "--with-libjpeg",
      "--with-libpng",
      "--with-libtiff",
      "--with-opengl",
      "--with-osx_cocoa",
      "--with-zlib",
      "--disable-precomp-headers",
      # This is the default option, but be explicit
      "--disable-monolithic",
      # Set with-macosx-version-min to avoid configure defaulting to 10.5
      "--with-macosx-version-min=#{MacOS.version}",
    ]

    args << "--enable-stl" if build.with? "stl"
    args << (build.with?("static") ? "--disable-shared" : "--enable-shared")

    system "./configure", *args
    system "make", "install"

    # wx-config should reference the public prefix, not wxmac's keg
    # this ensures that Python software trying to locate wxpython headers
    # using wx-config can find both wxmac and wxpython headers,
    # which are linked to the same place
    inreplace "#{bin}/wx-config", prefix, HOMEBREW_PREFIX
  end

  test do
    system bin/"wx-config", "--libs"
  end
end
