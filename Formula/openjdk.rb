class Openjdk < Formula
  desc "AdoptOpenJDK JDK, as a formula instead of a Cask"
  homepage "https://adoptopenjdk.net/"
  url "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.2%2B9/OpenJDK11U-jdk_x64_mac_hotspot_11.0.2_9.tar.gz"
  sha256 "fffd4ed283e5cd443760a8ec8af215c8ca4d33ec5050c24c1277ba64b5b5e81a"
  version "11.0.2,9"

  def install
    prefix.install "Contents"
  end
end
