#:  * `octave-app-grab` <formulae>:
#:    Grabs formulae from core tap and converts them to versioned
#:    formulae in the octave-app/octave-app tap.
#:
#:  * `octave-app-grab` `--deps` <formula>:
#:    Grabs a formula's recursive dependencies instead of the formula itself.
#:
#:  In our versioning scheme, we use "_" instead of "@" because having
#:  "@" in pathnames causes problems with some dependencies, such as texinfo.

# "oa" is an abbreviation for "octave-app" in this code

require "fileutils"

require "formula"
require "formulary"
require "tap"
require "utils/inreplace"

include Utils::Inreplace

default_target_formula = "octave-octave-app"
target_tap_name = "octave-app/octave-app"
# Manually-maintained formulae which should not be overwritten once they exist
# Formulae which require manual modification, such as those whose default options
# are changed, go in here. If you really want to regenerate one of these, delete it
# manually, and then re-run 'brew octave-app-grab'.
$blacklist = ["octave" "octave-octave-app"]
# Formulae that we can't get to compile from the versioned variants for some reason,
# so we just use the unversioned variants and hope for the best.
# TODO: It's our goal to keep the greenlist entirely empty by getting these to build.
$greenlist_main = []
# And these are the recursive dependencies of the main greenlist formulae, which must
# also be included in the greenlist, to avoid conflicts between versioned and 
# unversioned formulae.
$greenlist_deps = []
$greenlist = $greenlist_main + $greenlist_deps

if ARGV.include? "--deps"
  if ARGV.named.length > 1
    odie "Only one formula name argument can be given with --deps"
  end
  first_formula_name = ARGV.named.empty? ? default_target_formula : ARGV.named.first
  first_formula = Formula[first_formula_name]
  puts "first_formula: #{first_formula}"
  deps = first_formula.recursive_dependencies do |_dependent, _dep|
    # Include optional dependencies
    true
  end
  target_formula_names = deps.map { |d|
    d.to_formula.name 
  }.map { |name|
    name.sub(/@.*/, "")
  }.sort
  target_formula_names = [first_formula_name] + target_formula_names
else
  if ARGV.named.empty?
    odie "You must supply some formula names when not using --deps. If you want to re-grab octave-octave-app, supply --deps."
  else
    target_formula_names = ARGV.named
  end
end

$target_tap = Tap.fetch(target_tap_name)
$skip_count = 0
$skipped_blacklist = []
$skipped_greenlist = []

# A version of Utils::Inreplace::inreplace that ignores errors.
# So you can use this to replace text that may not exist
def maybe_inreplace(paths, before = nil, after = nil)
  Array(paths).each do |path|
    s = File.open(path, "rb", &:read).extend(StringInreplaceExtension)

    if before.nil? && after.nil?
      yield s
    else
      after = after.to_s if after.is_a? Symbol
      s.gsub!(before, after)
    end

    Pathname(path).atomic_write(s)
  end
end

def grab_formula(f_name)
  # Locate formula in main tap and get info
  formula = Formula[f_name]
  version = formula.version
  revision = formula.revision
  formula_path = formula.path
  versioned_name = "#{formula.name}_#{version}_#{revision}"
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
      $skipped_blacklist.push(f_name)
      return
    end
  end
  if $greenlist.include? f_name
    $skipped_greenlist.push(f_name)
    return
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
    if $greenlist.include? dep.name
      # Do not version-freeze greenlisted formulae
      next
    end
    dep_base_name = dep.name.sub(/@.*/, "")
    dep_version = dep.to_formula.version
    dep_revision = dep.to_formula.revision
    dep_versioned_name = "#{dep_base_name}_#{dep_version}_#{dep_revision}"
    maybe_inreplace(oa_versioned_formula_path, "depends_on \"#{dep.name}\"", "depends_on \"#{dep_versioned_name}\"")
    maybe_inreplace(oa_versioned_formula_path, "Formula[\"#{dep.name}\"]", "Formula[\"#{dep_versioned_name}\"]")
  end
  # Wipe out bottle info
  maybe_inreplace(oa_versioned_formula_path, /bottle do.*?end/m, "")
  # Announce
  puts "#{formula.name} => #{versioned_name}"
end


# Main

target_formula_names.each do |f_name|
  grab_formula(f_name)
end
puts "Skipped #{$skip_count} existing versioned formulae" if $skip_count > 0
if $skipped_blacklist.length > 0
  puts "Skipped #{$skipped_blacklist.length} existing blacklisted formulae: #{$skipped_blacklist}" 
end
if $skipped_greenlist.length > 0
  puts "Skipped #{$skipped_greenlist.length} greenlisted formulae: #{$skipped_greenlist}" 
end


