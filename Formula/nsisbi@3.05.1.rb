class NsisbiAT3051 < Formula
  desc "System to create big Windows installers"
  homepage "https://sourceforge.net/projects/nsisbi/"
  url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.05.1/nsis-code-7140-1-NSIS-trunk.zip"
  version "3.05.1"
  sha256 "5c8c81a24eacc524526fd1c386334714f47c1dbb233f514aeda41f4c2d4d9cc9"

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
    url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.05.1/nsis-binary-7140-1.zip"
    sha256 "70a0145256c4ee19808cb833a55595cca7ff486447c05a24ebdf3175aae6244c"
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
