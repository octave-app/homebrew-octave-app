# This cask lets you install the published Octave.app using the Homebrew cask
# mechanism. Unlike most of the stuff in this repo, it is for Octave.app *users* to
# use, not just for Octave.app *developers* to use.
cask 'octave-app' do
  version '6.2.0'
  sha256 'f847a22d386cbb357d996d8a67f03969f9a668d14f512b3890cdd18ec9a2a958'

  url "https://github.com/octave-app/octave-app/releases/download/v#{version}/Octave-#{version}.dmg"
  name 'Octave'
  homepage 'https://octave-app.org'

  auto_updates false

  livecheck do
    url "https://github.com/octave-app/octave-app/releases"
    strategy :page_match
    regex(%r{href=.*?/Octave[._-]?(\d+(?:\.\d+)+)\.dmg}i)
  end

  depends_on macos: '>= :mojave'

  app 'Octave-6.2.0.app'
end
