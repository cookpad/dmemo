namespace :docker do
  require_relative "../autoload/dmemo/version"

  IMAGE_NAME = "hogelog/dmemo:#{Dmemo::VERSION}"
  IMAGE_NAME_LATEST = "hogelog/dmemo:latest"

  task :build do
    sh *%W(docker build -t #{IMAGE_NAME} .)
    sh *%W(docker tag #{IMAGE_NAME} #{IMAGE_NAME_LATEST})
  end

  task :push do
    [IMAGE_NAME, IMAGE_NAME_LATEST].each do |name|
      sh *%W(docker push #{name})
    end
  end
end
