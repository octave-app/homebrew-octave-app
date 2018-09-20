cask 'octave-app' do
  version '4.4.0'
  sha256 '8703984d1c79a387a479e311b298c14b2aac2bde8c1a5d0138ec3e2ea15c87f2'

  url "https://github.com/octave-app/octave-app/releases/download/v4.4.0-beta9/Octave-4.4.0-beta9.dmg"
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
