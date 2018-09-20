cask 'octave-app' do
  version '4.4.0'
  sha256 '6ed7213f4f2e2eb474ceaf12b2302ea097aaf71ada31898c1f1e768f0498eb7c'

  url "https://github.com/octave-app/octave-app/releases/download/v4.4.0-beta8/Octave-4.4.0-beta8.dmg"
  name 'Octave'
  homepage 'https://octave-app.org'

  depends_on macos: '>= :el_capitan'

  auto_updates false

  app 'Octave-4.4.0.app'

  caveats do
    depends_on_java '8'

    <<~EOS
    This is a BETA release! It may be buggy or unstable.

    For help, please contact the Octave.app organization at https://octave-app.org.
    Bug reports may be filed at https://github.com/octave-app/octave-app/issues.
    EOS
  end
end
