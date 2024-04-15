require_relative "../../config/application"

task :release do
  sh(*%W(git tag #{Dmemo::VERSION}))
end
