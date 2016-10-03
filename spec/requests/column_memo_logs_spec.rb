require "rails_helper"

describe :column_memos, type: :request do
  let(:memo_log) { FactoryGirl.create(:column_memo_log) }
  let(:memo) { memo_log.column_memo }
  before do
    login!
  end

  describe "#index" do
    it "shows" do
      get column_memo_logs_path(memo.id)
      expect(response).to render_template("column_memo_logs/index")
      expect(page).to have_content(memo_log.description_diff)
    end
  end
end
