#:  * `octave-app-collect-licenses`:
#:    Collects the license documents from Octave and all its dependencies.
#:
#:  Running this command will produce a lot of "cp: foo*: No such file or directory"
#:  error messages. Those are fine; you can ignore them.

require "fileutils"

require "formula"
require "formulary"
require "tap"

include FileUtils

default_target_formula = "octave-unversioned"
target_tap_name = "octave-app/octave-app"

formula_name = ARGV.named.empty? ? default_target_formula : ARGV.named.first

tap = Tap.fetch(target_tap_name)
copying_dir = tap.path/"assets/COPYING"
pkgs_license_dir = copying_dir/"package-licenses"

mkdir pkgs_license_dir

formula = Formula[formula_name]
deps = formula.recursive_dependencies.map { |d| d.to_formula }
formulae = [formula] + deps

empty_dirs = []
formulae.each do |f|
  oh1 "Collecting #{f.name}"
  pkg_license_dir = pkgs_license_dir/f.name
  mkdir pkg_license_dir
  f.stable.stage do |stg|
    status = system("cp -f README* LICENSE* license* LICENCE* licence* COPYING* COPYRIGHT* Copyright* copyright* AUTHORS* #{pkg_license_dir.to_s} 2>/dev/null")
    exit status if status
    empty_dirs.push(f.name) if Dir.entries(pkg_license_dir).length < 3
  end
end

unless empty_dirs.empty?
  puts "Empty license dirs: #{empty_dirs.join(" ")}"
end