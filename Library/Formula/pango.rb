require 'formula'

class Pango < Formula
  homepage 'http://www.pango.org/'
  url 'http://download.gnome.org/sources/pango/1.29/pango-1.29.3.tar.xz'
  sha256 'b0da90cdac7f384a1c678b9467d00b6b8167f12044f9db089bf359f88644e86e'
  version '1.29.3'

  depends_on 'pkg-config' => :build
  depends_on 'glib'

  fails_with_llvm "Undefined symbols when linking", :build => "2326"

  if MacOS.leopard?
    depends_on 'fontconfig' # Leopard's fontconfig is too old.
    depends_on 'cairo' # Leopard doesn't come with Cairo.
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--without-x"
    system "make install"
  end
end
