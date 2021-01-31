cask 'octave-app' do
  version '6.1.0'
  sha256 'fe45f23e307e922e6ad75d3e4ef1b357b3e4d656205f659741986704f96a17f7'

  url "https://github.com/octave-app/octave-app/releases/download/v6.1.0/Octave-6.1.0.dmg"
  name 'Octave'
  homepage 'https://octave-app.org'

  depends_on macos: '>= :mojave'

  auto_updates false

  app 'Octave-6.1.0.app'
end
