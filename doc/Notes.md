# Notes for octave-app Formulae

## TODO

(currently nothing)

## Misc Notes

### Reproducible builds

I keep around a lot of old formulae basically indefinitely so I can still build old versions of Octave.app. But those are not reproducible builds. They won't pick up the same versions of their dependencies when you run them later. And the formula definitions themselves change over time to keep them building against newer states of Homebrew.

To make even reproducible-ish builds, you need to check out the older versions of both this homebrew-octave-app repo and the Homebrew core tap as of the build time you want, and build against those older formula versions. Odds are good it won't work. There's some support for it in the octave-app-bundler tool, but we don't use it much, so it doesn't work well.

## Structure and Terminology

"octapp" – The formulae with "-octapp" suffixes in their names are variants of core Homebrew formulae that we hacked (modified) for our purposes. These are mostly for a patch we do to Qt in order to gt rid of a "bad FSEvent id" error message it spams the command window with, in some sessions printing it every time a command prompt is printed. Yep, we have a whole customized qt formula just to fix a cosmetic issue. But it's a real annoying cosmetic issue.

"vanillaqt" – The "octave-octapp" formulae with "-vanilla-qt" suffixes are things that build against the regular core qt formula instead of our hacked "-octapp" variant of it, but otherwise use octapp customizations. OTOH, I like that these -octapp-vanilla-qt formulae are "just like octapp's build, but with vanilla qt, even when installed with regular `brew`", so maybe leave them in place. Was called "-vanilla-qt" instead of "-vanillaqt" prior to 2024-01.

"-qt5xx" – These are formulae built against specific minor versions of qt, instead of tracking the latest in the major version series.

## Octapp Customization

The "-octapp" formula have Octave.app-related customizations. For the octave formula, this includes:

* Munging the HG_ID version info to indicate we patched it.
* Adds deps on formulae used by Octave Forge packages, though not by Octave itself.
* Builds doco, and adds a MacTeX dependency (w/ a special Requirement definition) to do so.

As of 2023 and Octave 6.x, some of those other customizations are gone, and what's left is minor stuff like adjusting the HG_ID version info string to reflect our patching, etc. The need for these formulae might go away entirely if octave-app-bundler can take over that patching. I don't think there's much other use for them?

## History

Dropped the gnuplot dependency as of Octave 6.x and 2023. The core Homebrew octave formula dropped it a while back, saying that upstream (core octave) recommends just using Qt instead of gnuplot, since gnuplot is unmaintained, hard for Octave to use, and it has issues in modern build environments. I have the same experience; gnuplot builds just keep having more problems over time. I'm happy to just drop it at this point; doesn't seem to be much demand for gnuplot among our users, so little reason to put work in to continued support for it.

In early 2024-01, I changed the "-octave-app" suffix to "-octapp", since it's more concise and distinctive.
