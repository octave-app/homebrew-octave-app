class Gts0760 < Formula
  desc "GNU triangulated surface library"
  homepage "https://gts.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/gts/gts/0.7.6/gts-0.7.6.tar.gz"
  sha256 "059c3e13e3e3b796d775ec9f96abdce8f2b3b5144df8514eda0cc12e13e8b81e"

  

  depends_on "pkg-config_0.29.2_0" => :build
  depends_on "gettext_0.19.8.1_0"
  depends_on "glib_2.58.1_0"
  depends_on "netpbm_10.73.22_0"

  # Fix for newer netpbm.
  # This software hasn't been updated in seven years
  patch :DATA

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"

    system "make", "install"
  end
end

__END__
diff --git a/examples/happrox.c b/examples/happrox.c
index 88770a8..11f140d 100644
--- a/examples/happrox.c
+++ b/examples/happrox.c
@@ -21,7 +21,7 @@
 #include <stdlib.h>
 #include <locale.h>
 #include <string.h>
-#include <pgm.h>
+#include <netpbm/pgm.h>
 #include "config.h"
 #ifdef HAVE_GETOPT_H
 #  include <getopt.h>
