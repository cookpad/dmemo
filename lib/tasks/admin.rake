namespace :admin do
  task activate: :environment do
    user = User.find_by!(email: ENV["EMAIL"], admin: false)
    user.update!(admin: true)
    puts "admin activated: #{user.inspect}"
  end

  task deactivate: :environment do
    user = User.find_by!(email: ENV["EMAIL"], admin: true)
    user.update!(admin: false)
    puts "admin deactivated: #{user.inspect}"
  end
end
