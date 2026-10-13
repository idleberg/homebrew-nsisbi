class NsisbiAT3081 < Formula
  desc "System to create big Windows installers"
  homepage "https://sourceforge.net/projects/nsisbi/"
  url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.08.1/nsis-code-7336-1-NSIS-trunk.zip"
  version "3.08.1"
  sha256 "e8cbdf501998c340529462cb8e6bdfbb804d5cce67f59f8af5aa3c2816e1f69b"

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "mingw-w64" => :build
  depends_on "scons" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.08.1/nsis-binary-7336-1.zip"
    sha256 "745be62d9ee79090f54197f212c3a48772989e7484e3ce5bf59a5fdd0c74fa4a"
  end

  def install
    args = [
      "CC=#{ENV.cc}",
      "CXX=#{ENV.cxx}",
      "PREFIX=#{prefix}",
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
    build_dir = build.with?("debug") ? "udebug" : "urelease"
    bin.install "build/#{build_dir}/makensis/makensis"
    (share/"nsis").install resource("nsis")
  end

  test do
    system "#{bin}/makensis", "-VERSION"
    system "#{bin}/makensis", "#{share}/nsis/Examples/bigexample.nsi"
  end
end
