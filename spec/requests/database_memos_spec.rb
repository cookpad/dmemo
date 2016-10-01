require "rails_helper"

describe :database_memos, type: :request do
  let(:database_memo) { FactoryGirl.create(:database_memo) }
  before do
    login!
  end

  describe "#index" do
    it "redirects" do
      get database_memos_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "#show" do
    it "shows memo" do
      get database_memo_path(database_memo.name)
      expect(response).to render_template("database_memos/show")
      expect(page).to have_content(database_memo.name)
    end

    context "with id param" do
      it "redirects" do
        get database_memo_path(database_memo.id)
        expect(response).to redirect_to(database_memo_path(database_memo.name))
      end
    end
  end

  describe "#edit" do
    it "shows form" do
      get edit_database_memo_path(database_memo)
      expect(response).to render_template("database_memos/edit")
      expect(page).to have_content(database_memo.name)
    end
  end

  describe "#update" do
    it "updates memo" do
      patch database_memo_path(database_memo), database_memo: { description: "foo description" }
      expect(response).to redirect_to(database_memo_path(database_memo.name))
      expect(assigns(:database_memo).description).to eq("foo description")
    end
  end

  describe "#destroy" do
    it "destroys memo" do
      delete database_memo_path(database_memo)
      expect(response).to redirect_to(root_path)
      expect { DatabaseMemo.find(database_memo.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
