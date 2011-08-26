require 'formula'

class Pango < Formula
  homepage 'http://www.pango.org/'
  url 'git://git.gnome.org/pango', :using => :git, :tag => '1.29.3'
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
