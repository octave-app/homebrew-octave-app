cask 'octave-app' do
  version '4.4.1'
  sha256 'bb5928281e130b09798b106b04bec241898d7b927e8a5495ae041c60ccf7c779'

  url "https://github.com/octave-app/octave-app/releases/download/v4.4.1/Octave-4.4.1.dmg"
  name 'Octave'
  homepage 'https://octave-app.org'

  depends_on macos: '>= :el_capitan'

  auto_updates false

  app 'Octave-4.4.1.app'
end
