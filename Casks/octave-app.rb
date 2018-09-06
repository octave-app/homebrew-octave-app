cask 'octave-app' do
  version '4.4.0'
  sha256 'a8a66450563efd1cbf3746c456b02c6ad2389f3f2ef6bce69972ed8bba9bf2b4'

  url "https://github.com/octave-app/octave-app/releases/download/v4.4.0-rc1/Octave-4.4.0-rc1.dmg"
  name 'Octave'
  homepage 'https://octave-app.org'

  depends_on macos: '>= :yosemite'

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
