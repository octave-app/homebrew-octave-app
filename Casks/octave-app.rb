cask 'octave-app' do
  version '4.4.0'
  sha256 '05155e0e3bd3a14c48e082bff104f0f73581ee8aad4ac475e7b6da6f94a9c563'

  url "https://github.com/octave-app/octave-app/releases/download/v4.4.0-beta10/Octave-4.4.0-beta10.dmg"
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
