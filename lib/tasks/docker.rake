namespace :docker do
  task :build do
    sh *%W(docker build -t hogelog/dmemo:latest .)
  end
end
