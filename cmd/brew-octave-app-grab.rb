#:  * `octave-app-grab` <formulae>:
#:    Grabs formulae from core tap and converts them to versioned
#:    formulae in the octave-app/octave-app tap.
#:
#:  * `octave-app-grab` `--deps` <formula>:
#:    Grabs a formula's recursive dependencies instead of the formula itself.

# "oa" is an abbreviation for "octave-app" in this code

require "fileutils"

require "formula"
require "formulary"
require "tap"
require "utils/inreplace"

include Utils::Inreplace

default_target_formula = "octave@4.4.0"
target_tap_name = "octave-app/octave-app"
# Manually-maintained formulae which should not be overwritten once they exist
$blacklist = ["octave"]

if ARGV.include? "--deps"
  if ARGV.named.length > 1
    odie "Only one formula name argument can be given with --deps"
  end
  first_formula_name = ARGV.named.empty? ? default_target_formula : ARGV.named.first
  first_formula = Formula[first_formula_name]
  deps = first_formula.recursive_dependencies
  target_formula_names = deps.map { |d| d.to_formula.name }.sort
else
  if ARGV.named.empty?
    odie "You must supply some formula names when not using --deps"
  else
    target_formula_names = ARGV.named
  end
end

$target_tap = Tap.fetch(target_tap_name)
$skip_count = 0

def grab_formula(f_name)
  # Locate formula in main tap and get info
  formula = Formula[f_name]
  version = formula.version
  formula_path = formula.path
  versioned_name = "#{formula.name}@#{version}"
  # Locate versioned formula in octave-app tap
  qual_versioned_dep_name = "#{$target_tap}/#{versioned_name}"
  oa_formula_dir = $target_tap.path/"Formula"
  oa_versioned_formula_path = oa_formula_dir/"#{versioned_name}.rb"
  # Copy it over
  if oa_versioned_formula_path.exist?
    if !ARGV.include?("--overwrite")
    	#puts "#{formula.name}: Formula #{versioned_name} exists; not overwriting"
    	$skip_count = $skip_count + 1
      return
    elsif $blacklist.include? f_name
      odie "Cannot overwrite blacklisted formula #{f_name}"
    end
  end
  FileUtils.cp(formula_path, oa_versioned_formula_path)
  # Munge the versioned formula
  # Munge the class name inside the formula
  old_class_name = Formulary.class_s(formula.name)
  new_class_name = Formulary.class_s(versioned_name)
  inreplace(oa_versioned_formula_path, "class #{old_class_name}", "class #{new_class_name}")
  # Freeze its dependencies to versioned ones
  deps = formula.deps
  deps.each do |dep|
    dep_version = dep.to_formula.version
    inreplace(oa_versioned_formula_path, "depends_on \"#{dep.name}\"", "depends_on \"#{dep.name}@#{dep_version}\"")
  end
  # Announce
  puts "#{formula.name} => #{versioned_name}"
end


# Main

target_formula_names.each do |f_name|
  grab_formula(f_name)
end
puts "Skipped #{$skip_count} existing versioned formulae" if $skip_count > 0
