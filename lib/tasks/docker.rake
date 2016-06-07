namespace :docker do
  require_relative "../autoload/dmemo/version"

  IMAGE_NAME = "hogelog/dmemo:#{Dmemo::VERSION}"

  task :build do
    sh *%W(docker build -t #{IMAGE_NAME} .)
  end

  task :push do
    sh *%W(docker push #{IMAGE_NAME})
  end
end
