cask 'octave-app' do
  version '4.4.0'
  sha256 '5b797f99f9e6ba028db3047783d63e87e2456001d3f98dd10403a762c0f7076c'

  url "https://github.com/octave-app/octave-app/releases/download/v4.4.0/Octave-4.4.0.dmg"
  name 'Octave'
  homepage 'https://octave-app.org'

  depends_on macos: '>= :el_capitan'

  auto_updates false

  app 'Octave-4.4.0.app'

  caveats do
    depends_on_java '8'
  end
end
