require_relative "../autoload/dmemo/version"

task :release do
  sh(*%W(git tag #{Dmemo::VERSION}))
end
