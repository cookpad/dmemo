require "rails_helper"

describe :table_memo_logs, type: :request do
  let(:memo_log) { FactoryGirl.create(:table_memo_log) }
  let(:memo) { memo_log.table_memo }
  before do
    login!
  end

  describe "#index" do
    it "shows" do
      get table_memo_logs_path(memo.id)
      expect(response).to render_template("table_memo_logs/index")
      expect(page).to have_content(memo.name)
      expect(page).to have_content(memo_log.description_diff)
    end
  end
end
