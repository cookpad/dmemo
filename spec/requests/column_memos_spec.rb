require "rails_helper"

describe :column_memos, type: :request do
  let(:column_memo) { FactoryBot.create(:column_memo) }
  let(:table_memo) { column_memo.table_memo }
  let(:schema_memo) { table_memo.schema_memo }
  let(:database_memo) { schema_memo.database_memo }
  before do
    login!
  end

  describe "#show" do
    it "redirects table_memo" do
      get column_memo_path(column_memo)
      expect(response).to redirect_to(table_memo_path(table_memo))
    end
  end

  describe "#edit" do
    it "shows form" do
      get edit_column_memo_path(column_memo)
      expect(response).to render_template("column_memos/edit")
      expect(page).to have_content(column_memo.description)
    end
  end

  describe "#update" do
    it "updates memo" do
      patch column_memo_path(column_memo), params: { column_memo: { description: "foo description" } }
      expect(response).to redirect_to(redirect_to database_schema_table_path(database_memo.name, schema_memo.name, table_memo.name))
      expect(assigns(:column_memo).description).to eq("foo description")
    end
  end

  describe "#destroy" do
    it "destroys memo" do
      delete column_memo_path(column_memo)
      expect(response).to redirect_to(table_memo_path(column_memo.table_memo_id))
      expect { ColumnMemo.find(column_memo.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
