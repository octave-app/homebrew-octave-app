#:  * `octave-app-list-formulae`:
#:    Lists all formulae with version and description info

require "formula"
require "formulary"

Formula.installed.each do |f|
  puts "#{f.name} #{f.version.to_s}"
  puts f.desc
  puts f.homepage
  puts ""
end
