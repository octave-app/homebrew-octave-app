#:  * `deps-with-versions` <formula>:
#:    Displays dependencies which are versioned formulae

require "formula"
require "formulary"

if ARGV.named.empty?
  odie "Must supply a formula argument"
elsif ARGV.named.length > 1
  odie "Can only supply a single formula argument"
end

formula_name = ARGV.first
formula = Formula[formula_name]
deps = formula.recursive_dependencies
deps.each do |d|
  f = d.to_formula
  if f.versioned_formula?
    puts "#{f.name}"
  end
end