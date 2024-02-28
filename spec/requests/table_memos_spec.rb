require "rails_helper"

describe :table_memos, type: :request do
  let(:table_memo) { FactoryBot.create(:table_memo) }
  let(:schema_memo) { table_memo.schema_memo }
  let(:database_memo) { schema_memo.database_memo }
  before do
    login!
  end

  describe "#show" do
    let!(:data_source) { FactoryBot.create(:data_source) }
    let(:database_memo) { data_source.database_memo }
    let(:schema_memo) { database_memo.schema_memos.take! }
    let(:table_memo) { schema_memo.table_memos.find_by!(name: "data_sources") }
    before do
      SynchronizeDataSources.run
    end

    it "shows table memo and data" do
      get database_schema_table_path(database_memo.name, schema_memo.name, table_memo.name)
      expect(response).to render_template("table_memos/show")
      expect(table_memo).to eq(assigns(:table_memo))
      %w(id name description adapter host port db_name user).each { |attr| expect(page).to have_content(data_source[attr]) }
      expect(page).not_to have_content(/\d+:\d+:\d+ UTC/)
    end

    context "with id param" do
      it "redirects to named path" do
        get table_memo_path(table_memo.id)
        expect(page).to redirect_to(database_schema_table_path(database_memo.name, schema_memo.name, table_memo.name))
      end
    end
  end

  describe "#edit" do
    it "shows table memo form" do
      get edit_table_memo_path(table_memo)
      expect(response).to render_template("table_memos/edit")
      expect(table_memo).to eq(assigns(:table_memo))
    end
  end

  describe "#update" do
    it "updates table memo" do
      patch table_memo_path(table_memo), params: { table_memo: { description: "foo description" } }
      expect(response).to redirect_to(database_schema_table_path(table_memo.database_memo.name, table_memo.schema_memo.name, table_memo.name))
      expect(assigns(:table_memo).description).to eq("foo description")
    end
  end

  describe "#destroy" do
    it "destroys table memo" do
      delete table_memo_path(table_memo)
      expect(response).to redirect_to(database_memo_path(table_memo.database_memo.name))
      expect { TableMemo.find(table_memo.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
