class Lmfit < Formula
  homepage "http://apps.jcns.fz-juelich.de/doku/sc/lmfit"
  url "http://apps.jcns.fz-juelich.de/src/lmfit/old/lmfit-5.1.tgz"
  sha256 "4e35bdec551a4985cf6d96f26a808b56c171433edf4a413c2ed50ab3d85a3965"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
