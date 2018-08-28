require "rails_helper"

describe :ignored_tables, type: :request do
  let(:user) { FactoryBot.create(:user, admin: true) }
  before do
    login!(user: user)
  end

  describe "#index" do
    it "redirects" do
      get ignored_tables_path
      expect(response).to redirect_to(setting_path)
    end
  end

  describe "#show" do
    let!(:ignored_table) { FactoryBot.create(:ignored_table) }

    it "redirects" do
      get ignored_table_path(ignored_table)
      expect(response).to redirect_to(setting_path)
    end
  end

  describe "#new" do
    let!(:data_source) { FactoryBot.create(:data_source) }

    it "shows form" do
      get new_ignored_table_path
      expect(response).to render_template("ignored_tables/new")
      expect(page).to have_xpath("//option[text()='#{data_source.name}']")
    end
  end

  describe "#create" do
    let(:data_source) { FactoryBot.create(:data_source) }

    it "creates ignored_table" do
      post ignored_tables_path, params: { ignored_table: { data_source_id: data_source.id, pattern: "foo" } }
      expect(response).to redirect_to(setting_path)
      expect(assigns(:ignored_table).pattern).to eq("foo")
    end

    context "with empty pattern" do
      it "shows error" do
        post ignored_tables_path, params: { ignored_table: { data_source_id: data_source.id, pattern: "" } }
        expect(response).to redirect_to(new_ignored_table_path)
        expect(flash[:error]).to include("Pattern")
      end
    end
  end

  describe "#destroy" do
    let(:ignored_table) { FactoryBot.create(:ignored_table) }

    it "deletes ignored_table" do
      delete ignored_table_path(ignored_table)
      expect(response).to redirect_to(setting_path)
      expect(IgnoredTable.find_by(id: ignored_table.id)).to eq(nil)
    end
  end
end
