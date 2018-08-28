require "rails_helper"

describe :schema_memos, type: :request do
  let(:memo_log) { FactoryBot.create(:schema_memo_log) }
  let(:memo) { memo_log.schema_memo }
  before do
    login!
  end

  describe "#index" do
    it "shows" do
      get schema_memo_logs_path(memo.id)
      expect(response).to render_template("schema_memo_logs/index")
      expect(page).to have_content(memo.name)
      expect(page).to have_content(memo_log.description_diff)
    end
  end
end
