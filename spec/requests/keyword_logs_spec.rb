require "rails_helper"

describe :keyword_logs, type: :request do
  let(:memo_log) { FactoryBot.create(:keyword_log) }
  let(:memo) { memo_log.keyword }
  before do
    login!
  end

  describe "#index" do
    it "shows" do
      get keyword_logs_path(memo.id)
      expect(response).to render_template("keyword_logs/index")
      expect(page).to have_content(memo.name)
      expect(page).to have_content(memo_log.description_diff)
    end
  end
end
