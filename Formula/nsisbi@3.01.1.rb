class NsisbiAT3011 < Formula
  desc "System to create big Windows installers"
  homepage "https://sourceforge.net/projects/nsisbi/"
  url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.01.1/nsis-code-6823-NSIS-trunk.zip"
  version "3.01.1"
  sha256 "3733e43ffd9ba07ee7757ca4b1ca30a4fc45cc33633d44eb46cef09c7bc4f4bd"

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "mingw-w64" => :build
  depends_on "scons" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsisbi/nsisbi3.01.1/nsis-binary-6823.zip"
    sha256 "34835eb409d3f1630e26d429d79e754f8a0fb2738b15fa369df1f0eb54383e69"
  end

  # Patch util.h to define 64-bit aliases
  patch :DATA

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
