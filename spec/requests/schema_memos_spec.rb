require "rails_helper"

describe :schema_memos, type: :request do
  let(:schema_memo) { FactoryBot.create(:schema_memo) }
  let(:database_memo) { schema_memo.database_memo }
  before do
    login!
  end

  describe "#show" do
    context "with multiple schemas" do
      before do
        FactoryBot.create(:schema_memo, database_memo: database_memo)
      end

      it "shows memo" do
        get database_schema_path(database_memo.name, schema_memo.name)
        expect(response).to render_template("schema_memos/show")
        expect(page).to have_content(schema_memo.name)
      end
    end

    context "with single schema" do
      it "redirects" do
        get database_schema_path(database_memo.name, schema_memo.name)
        expect(response).to redirect_to(database_memo_path(database_memo.name))
      end
    end

    context "with id param" do
      it "redirects" do
        get schema_memo_path(schema_memo.id)
        expect(response).to redirect_to(database_schema_path(database_memo.name, schema_memo.name))
      end
    end
  end

  describe "#edit" do
    it "shows form" do
      get edit_schema_memo_path(schema_memo)
      expect(response).to render_template("schema_memos/edit")
      expect(page).to have_content(schema_memo.name)
    end
  end

  describe "#update" do
    it "updates memo" do
      patch schema_memo_path(schema_memo), params: { schema_memo: { description: "foo description" } }
      expect(response).to redirect_to(database_schema_path(database_memo.name, schema_memo.name))
      expect(assigns(:schema_memo).description).to eq("foo description")
    end
  end

  describe "#destroy" do
    it "destroys memo" do
      delete schema_memo_path(schema_memo)
      expect(response).to redirect_to(database_memo_path(schema_memo.database_memo.name))
      expect { SchemaMemo.find(schema_memo.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
