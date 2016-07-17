require "rails_helper"

describe :table_memos, type: :request do
  let(:data_source) { FactoryGirl.create(:data_source).tap {|ds| DatabaseMemo.import_data_source!(ds.id) } }
  let(:database_memo) { data_source.database_memo }
  let(:schema_memo) { database_memo.schema_memos.take! }
  let(:table_memo) { schema_memo.table_memos.find_by!(name: "data_sources") }
  before do
    login!
  end

  describe "#show" do
    it "shows table memo and data" do
      get database_schema_table_path(database_memo.name, schema_memo.name, table_memo.name)
      expect(response).to render_template("table_memos/show")
      expect(table_memo).to eq(assigns(:table_memo))
      data_source.attributes.values.each {|value| expect(page).to have_content(value) }
    end
  end
end
