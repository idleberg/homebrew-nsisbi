class NsisbiAT30211 < Formula
  desc "System to create big Windows installers"
  homepage "https://sourceforge.net/projects/nsisbi/"
  url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.02.1.1/nsis-code-6896-1-NSIS-trunk.zip"
  version "3.02.1.1"
  sha256 "8e555fa9d45ff81805b0b698d63d116730de2a832a899e433fb9df882bdce932"

  bottle do
    cellar :any_skip_relocation
    sha256 "bd5b875da911a5ff1fbdbe1b80ad21e7c2dc5841cd89ba7b9e1d3e412a029bfd" => :mojave
    sha256 "b656fcbbb32f982ff66c897f8af08b989425f3c375aa96572dde0e00f05cc396" => :high_sierra
    sha256 "bf01aff6fbcda07ab721b743ca044207face08b9e5f200b764efce8d9adb1c37" => :sierra
    sha256 "f4516cec938568eb2bea2b162247a10cbd68dedd85c439f5d77170dbc7c5b81b" => :el_capitan
  end

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "mingw-w64" => :build
  depends_on "scons" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.02.1.1/nsis-binary-6896-1.zip"
    sha256 "90bfba3bb8751ba7d4f70b33abc3365491cea772d78c64d9b1789e4190b32e9f"
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

    scons "makensis", *args
    bin.install "build/urelease/makensis/makensis"
    (share/"nsis").install resource("nsis")
  end

  test do
    system "#{bin}/makensis", "-VERSION"
    system "#{bin}/makensis", "#{share}/nsis/Examples/bigexample.nsi"
  end
end

__END__
diff --git a/Source/util.h b/Source/util.h
index 8eacc30..3ad0672 100755
--- a/Source/util.h
+++ b/Source/util.h
@@ -32,6 +32,14 @@

 #include <stdarg.h>

+#ifndef fseeko64
+#define fseeko64 fseeko
+#endif
+
+#ifndef ftello64
+#define ftello64 ftello
+#endif
+
 extern double my_wtof(const wchar_t *str);
 extern size_t my_strncpy(TCHAR*Dest, const TCHAR*Src, size_t cchMax);
 template<class T> bool strtrycpy(T*Dest, const T*Src, size_t cchCap) { size_t c = my_strncpy(Dest, Src, cchCap); return c < cchCap && !Src[c]; }
