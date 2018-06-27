cask 'octave-app' do
  version '4.4.0'
  sha256 'e56993677fcb5fe83221ed92fc5eb79abbf5bd680fc41fac586831bf7b1ca1b4'

  url "https://github.com/octave-app/octave-app/releases/download/untagged-4e9d0ab25492be932368/Octave-4.4.0-beta2.dmg"
  name 'Octave'
  homepage 'https://octave-app.org'

  depends_on macos: '>= :yosemite'

  auto_updates false

  app 'Octave-4.4.0.app'

  caveats do
    depends_on_java '8'

    <<~EOS
    This is a BETA release! It may be buggy or unstable.

    For help or bug reports, contact the Octave.app organization at https://octave-app.org.
    EOS
  end
end
