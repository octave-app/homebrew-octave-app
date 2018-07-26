#:  * `freshen` [`--display-times`] <formulae>:
#:    Ensure that all named formulae are installed and updated to the latest
#:    version. Does not warn if formulae are already installed and updated.
#:
#:    All formula options are ignored; they are always installed with the
#:    defaults. `--HEAD` and `--devel` are also ignored.
#:

require "cmd/upgrade.rb"
require "cmd/install.rb"

module Homebrew
  module_function

  def freshen
    raise FormulaUnspecifiedError if ARGV.named.empty?

    install_referenced_taps

    # Get list of requested formulae
    requested = ARGV.named
    outdated = ARGV.resolved_formulae.select do |f|
      f.outdated?
    end
    not_installed = ARGV.resolved_formulae.select do |f|
      !(f.installed?)
    end
    already_fresh = ARGV.resolved_formulae.select do |f|
      !(outdated.include? f) && !(not_installed.include? f)
    end
    pinned = outdated.select(&:pinned?)
    outdated -= pinned
    to_install = outdated + not_installed

    if !pinned.empty?
      puts "Ignoring #{pinned.length} pinned formulae: #{pinned}"
    end
    oh1 "Installing #{not_installed.length} and upgrading #{outdated.length} packages:"
    puts "#{to_install.map { |f| f.name }}"

    # Sort keg_only before non-keg_only formulae to avoid any needless conflicts
    # with outdated, non-keg_only versions of formulae being upgraded.
    outdated.sort! do |a, b|
      if !a.keg_only? && b.keg_only?
        1
      elsif a.keg_only? && !b.keg_only?
        -1
      else
        0
      end
    end

    outdated.each do |f|
      begin
        upgrade_formula(f)
        next if !ARGV.include?("--cleanup") && !ENV["HOMEBREW_UPGRADE_CLEANUP"]
        next unless f.installed?
        Homebrew::Cleanup.cleanup_formula f
      rescue UnsatisfiedRequirements => e
        Homebrew.failed = true
        onoe "#{f}: #{e}"
      end
    end

    not_installed.each do |f|
      install_formula(f)
    end

    Homebrew.messages.display_messages
  end

  def install_referenced_taps
    unless ARGV.force?
      ARGV.named.each do |name|
        next if File.exist?(name)
        if name !~ HOMEBREW_TAP_FORMULA_REGEX && name !~ HOMEBREW_CASK_TAP_CASK_REGEX
          next
        end
        tap = Tap.fetch(Regexp.last_match(1), Regexp.last_match(2))
        tap.install unless tap.installed?
      end
    end
  end

end

# Adapter for using as an external command

Homebrew.freshen