class NsisbiAT30612 < Formula
  desc "System to create big Windows installers"
  homepage "https://sourceforge.net/projects/nsisbi/"
  url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.06.1.2/nsis-code-7208-2-NSIS-trunk.zip"
  version "3.06.1.2"
  sha256 "6212a49748fb45ee08eb8291d4d3691abcea00c71806628848c3039d805a2337"

  bottle do
    cellar :any_skip_relocation
    sha256 "e7cb0cf276e20c96b426188fa69b9a70aff58419747633682be8a957a4c6c166" => :mojave
    sha256 "c4cd3ba5be94d0c9788997dd9d686b7868519ba2c631e215bdc1eac1ecf63ed0" => :high_sierra
    sha256 "8f035781e4e926b8dcd367fbdc3a3a2bdd9b5fd96d268da62e9ac88ada495137" => :sierra
  end

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "mingw-w64" => :build
  depends_on "scons" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.06.1.2/nsis-binary-7208-2.zip"
    sha256 "29cb3908e32015c6e99cc8c1754ca05faa6b0d719ff015899c4fea59562ebcbd"
  end

  # Patch util.h to define 64-bit aliases
  patch :DATA

  def install
    args = [
      "CC=#{ENV.cc}",
      "CXX=#{ENV.cxx}",
      "PREFIX_DOC=#{share}/nsis/Docs",

      # Don't strip, see https://github.com/Homebrew/homebrew/issues/28718
      "STRIP=0",

      # Skip building Win32 UI tools
      "SKIPUTILS=Makensisw,NSIS Menu,zip2exe",

      "VERSION=#{version}",
    ]

    args << "NSIS_CONFIG_LOG=yes" if build.with? "advanced-logging"
    args << "NSIS_MAX_STRLEN=8192" if build.with? "large-strings"
    args << "DEBUG=1" if build.with? "debug"

    system "scons", "makensis", *args
    bin.install "build/urelease/makensis/makensis"
    (share/"nsis").install resource("nsis")
  end

  test do
    system "#{bin}/makensis", "-VERSION"
    system "#{bin}/makensis", "#{share}/nsis/Examples/bigexample.nsi"
  end
end
