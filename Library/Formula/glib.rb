require 'formula'

def build_tests?; ARGV.include? '--test'; end

class Glib < Formula
  homepage 'http://developer.gnome.org/glib/2.28/'
  url 'ftp://ftp.gnome.org/pub/gnome/sources/glib/2.28/glib-2.28.7.tar.bz2'
  sha256 '0e1b3816a8934371d4ea2313dfbe25d10d16c950f8d02e0a7879ae10d91b1631'

  depends_on 'pkg-config' => :build
  depends_on 'gettext'

  fails_with_llvm "Undefined symbol errors while linking" unless MacOS.lion?

  def patches
    mp = "https://svn.macports.org/repository/macports/trunk/dports/devel/glib2/files/"
    {
      :p0 => [
        mp+"patch-configure.ac.diff",
        mp+"patch-glib-2.0.pc.in.diff",
        mp+"patch-glib_gunicollate.c.diff",
        mp+"patch-gi18n.h.diff",
        mp+"patch-gio_xdgmime_xdgmime.c.diff",
        mp+"patch-gio_gdbusprivate.c.diff"
      ],
      :p1 => [ DATA ]
    }
  end

  def options
  [
    ['--universal', 'Build universal binaries.'],
    ['--test', 'Build a debug build and run tests. NOTE: Tests may hang on "unix-streams".']
  ]
  end

  def install
    ENV.universal_binary if ARGV.build_universal?

    # indeed, amazingly, -w causes gcc to emit spurious errors for this package!
    ENV.enable_warnings

    args = ["--disable-dependency-tracking", "--disable-rebuilds",
            "--prefix=#{prefix}"]

    args << "--disable-debug" unless build_tests?

    if ARGV.build_universal?
      # autoconf 2.61 is fine don't worry about it
      inreplace ["aclocal.m4", "configure.ac"] do |s|
        s.gsub! "AC_PREREQ([2.62])", "AC_PREREQ([2.61])"
      end

      # Run autoconf so universal builds will work
      system "autoconf"
    end

    system "./configure", *args

    # Fix for 64-bit support, from MacPorts
    curl "https://svn.macports.org/repository/macports/trunk/dports/devel/glib2/files/config.h.ed", "-O"
    system "ed - config.h < config.h.ed"

    system "make"
    # Supress a folder already exists warning during install
    # Also needed for running tests
    ENV.j1
    system "make test" if build_tests?
    system "make install"

    # This sucks; gettext is Keg only to prevent conflicts with the wider
    # system, but pkg-config or glib is not smart enough to have determined
    # that libintl.dylib isn't in the DYLIB_PATH so we have to add it
    # manually.
    gettext = Formula.factory('gettext')
    inreplace lib+'pkgconfig/glib-2.0.pc' do |s|
      s.gsub! 'Libs: -L${libdir} -lglib-2.0 -lintl',
              "Libs: -L${libdir} -lglib-2.0 -L#{gettext.lib} -lintl"

      s.gsub! 'Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include',
              "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include -I#{gettext.include}"
    end

    (share+'gtk-doc').rmtree
  end
end

__END__
diff --git a/glib/gconvert.c b/glib/gconvert.c
index b363bca..9924c6c 100644
--- a/glib/gconvert.c
+++ b/glib/gconvert.c
@@ -62,7 +62,6 @@
 #error GNU libiconv in use but included iconv.h not from libiconv
 #endif
 #if !defined(USE_LIBICONV_GNU) && defined (_LIBICONV_H)
-#error GNU libiconv not in use but included iconv.h is from libiconv
 #endif
 
 
