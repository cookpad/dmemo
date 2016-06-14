namespace :bower do
  task :install do
    cd "vendor/assets" do
      sh "bower", "install", "-p"
    end
  end
end
