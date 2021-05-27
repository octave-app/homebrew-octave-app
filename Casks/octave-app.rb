cask 'octave-app' do
  version '6.2.0'
  sha256 'f847a22d386cbb357d996d8a67f03969f9a668d14f512b3890cdd18ec9a2a958'

  url "https://github.com/octave-app/octave-app/releases/download/v#{version}/Octave-#{version}.dmg"
  name 'Octave'
  homepage 'https://octave-app.org'

  auto_updates true
 
  livecheck do
    url "https://github.com/octave-app/octave-app/releases"
    strategy :page_match
    regex(%r{href=.*?/Octave[._-]?(\d+(?:\.\d+)+)\.dmg}i)
  end

  depends_on macos: '>= :mojave'

  app 'Octave-#{version}.app'
end
