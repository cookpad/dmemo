module DescriptionLogger
  extend ActiveSupport::Concern

  included do
    def build_log(user_id)
      last_log = logs.last
      current_revision = last_log.try(:revision).to_i
      logs.build(
        revision: current_revision + 1,
        user_id:,
        description: self.description,
        description_diff: diff(last_log.try(:description), self.description),
      )
    end
  end
end
