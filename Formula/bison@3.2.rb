class BisonAT32 < Formula
  desc "Parser generator"
  homepage "https://www.gnu.org/software/bison/"
  url "https://ftp.gnu.org/gnu/bison/bison-3.2.4.tar.xz"
  mirror "https://ftpmirror.gnu.org/bison/bison-3.2.4.tar.xz"
  sha256 "523d44419f4df68286503740c95c7b3400b748d7d8b797209195ee5d67f05634"

  keg_only :provided_by_macos, "some formulae require a newer version of bison"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.y").write <<~EOS
      %{ #include <iostream>
         using namespace std;
         extern void yyerror (char *s);
         extern int yylex ();
      %}
      %start prog
      %%
      prog:  //  empty
          |  prog expr '\\n' { cout << "pass"; exit(0); }
          ;
      expr: '(' ')'
          | '(' expr ')'
          |  expr expr
          ;
      %%
      char c;
      void yyerror (char *s) { cout << "fail"; exit(0); }
      int yylex () { cin.get(c); return c; }
      int main() { yyparse(); }
    EOS
    system "#{bin}/bison", "test.y"
    system ENV.cxx, "test.tab.c", "-o", "test"
    assert_equal "pass", shell_output("echo \"((()(())))()\" | ./test")
    assert_equal "fail", shell_output("echo \"())\" | ./test")
  end
end
