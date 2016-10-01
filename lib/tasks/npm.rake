namespace :npm do
  task :install do
    cd "vendor/assets" do
      sh "npm", "install", "-p"
      rm_rf "node_modules/jquery"
    end
  end

  task :clean do
    rm_rf "vendor/assets/node_modules"
  end
end
