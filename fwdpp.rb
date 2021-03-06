class Fwdpp < Formula
  homepage "https://molpopgen.github.io/fwdpp/"
  # doi "10.1534/genetics.114.165019"

  url "https://github.com/molpopgen/fwdpp/archive/0.2.9.tar.gz"
  sha256 "64cf5efbc7ac9d0454a1624489b6f7de55c20958b9e7f4f3c34bc36068fa67c2"
  head "https://github.com/molpopgen/fwdpp.git"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-science"
    sha256 "ad5bfff1206af81242ea2792a608b814e433453d487e87905a98aa0dd24ac29c" => :yosemite
    sha256 "98d7c69904ebf8b877086b692b2fd7fea1b8530ed9d7a9dcae8b3008fb713978" => :mavericks
  end

  option "without-check", "Disable build-time checking (not recommended)"

  depends_on "gsl"
  depends_on "boost" => :recommended
  depends_on "libsequence"

  # build fails on mountain lion at configure stage when looking for libsequence
  # so restrict to mavericks and newer
  depends_on :macos => :mavericks

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "check" if build.with? "check"
    system "make", "install"
    share.install "examples" # install examples
    share.install "unit"     # install unit tests
  end

  test do
    # run unit tests compiled with 'make check'
    if build.with? "check"
      Dir["#{share}/unit/*"].each { |f| system f if File.file?(f) && File.executable?(f) }
    end
  end
end
