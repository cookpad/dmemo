namespace :admin do
  task activate: :environment do
    user = User.find_by!(email: ENV["EMAIL"], admin: false)
    user.update!(admin: true)
    Rails.logger.info "admin activated: #{user.email}"
  end

  task deactivate: :environment do
    user = User.find_by!(email: ENV["EMAIL"], admin: true)
    user.update!(admin: false)
    Rails.logger.info "admin deactivated: #{user.email}"
  end
end
