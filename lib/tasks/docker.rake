namespace :docker do
  require_relative "../autoload/dmemo/version"

  IMAGE_NAME = "hogelog/dmemo:#{Dmemo::VERSION}"
  IMAGE_NAME_LATEST = "hogelog/dmemo:latest"

  def rc_build?
    Dmemo::VERSION.end_with?("-rc")
  end

  task :build do
    sh *%W(docker build -t #{IMAGE_NAME_LATEST} .)
    sh *%W(docker tag #{IMAGE_NAME_LATEST} #{IMAGE_NAME}) unless rc_build?
  end

  task :push do
    names = [IMAGE_NAME_LATEST]
    names << IMAGE_NAME unless rc_build?
    names.each do |name|
      sh *%W(docker push #{name})
    end
  end
end
