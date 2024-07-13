# homebrew-octave-app

Homebrew formulae for Octave.app.

This is the custom Homebrew tap for the [Octave.app project](https://github.com/octave-app), which bundles GNU Octave into a macOS Octave.app app bundle. This homebrew-octave-app repo contains the custom Homebrew formulae that [octave-app-bundler](https://github.com/octave-app/octave-app-bundler) uses in building Octave.app.

These formulae are intended primarily for use in the bundled app, so they have minimal options defined in them, and may have other special tweaks to work correctly in this context. But they should all work in regular Homebrew installations, too!

This tap lives at <https://github.com/octave-app/homebrew-octave-app>. Please report any bugs there. To use this tap in Homebrew, run `brew tap octave-app/octave-app`.

## Version numbering

This repo has version numbers. These are used to refer to interesting milestones in its history in a concise way, or do tag-based git operations. We don't actually publish releases; that's not how Homebrew Taps are consumed.

Octave.app, this homebrew-octave-app tap, and the octave-app-bundler tool all have independent version numbers. The version numbers for this repo do not match the release numbers for the Octave.app releases that were built with them.
