require "rails_helper"

describe :data_sources, type: :request do
  before do
    login!(admin: true)
  end

  describe "#index" do
    it "redirects" do
      get data_sources_path
      expect(response).to redirect_to(setting_path)
    end
  end

  describe "#show" do
    let(:data_source) { FactoryGirl.create(:data_source) }

    it "redirects" do
      get data_source_path(data_source)
      expect(response).to redirect_to(setting_path)
    end
  end

  describe "#new" do
    it "shows form" do
      get new_data_source_path
      expect(response).to render_template("data_sources/new")
    end
  end

  describe "#create" do
    let(:data_source_param) {
      { name: "dmemo", description: "", adapter: "postgresql", host: "localhost", port: 5432, dbname: "dmemo_test", user: "postgres" }
    }

    it "creates data_source and related memos" do
      post data_sources_path, params: { data_source: data_source_param }
      data_source = assigns(:data_source)
      expect(data_source).to be_present
      expect(response).to redirect_to(data_sources_path)
    end

    context "with empty name" do
      before do
        data_source_param[:name] = ""
      end

      it "shows error" do
        post data_sources_path, params: { data_source: data_source_param }
        expect(response).to redirect_to(new_data_source_path)
        expect(flash[:error]).to include("Name")
      end
    end
  end

  describe "#edit" do
    let(:data_source) { FactoryGirl.create(:data_source) }

    it "shows form" do
      get edit_data_source_path(data_source)
      expect(response).to render_template("data_sources/edit")
      expect(page).to have_xpath("//input[@id='data_source_name'][@value='#{data_source.name}']")
    end
  end

  describe "#update" do
    let!(:data_source) { FactoryGirl.create(:data_source) }

    it "updates data_source" do
      patch data_source_path(data_source.id), params: { data_source: { description: "hello" } }

      expect(data_source.id).to eq(assigns(:data_source).id)
      expect(response).to redirect_to(data_sources_path)

      expect(assigns(:data_source).description).to eq("hello")
    end

    context "with empty name" do
      it "shows error" do
        patch data_source_path(data_source.id), params: { data_source: { name: "" } }

        expect(response).to redirect_to(edit_data_source_path(data_source.id))
        expect(flash[:error]).to include("Name")
      end
    end
  end

  describe "#destroy" do
    let(:data_source) { FactoryGirl.create(:data_source) }

    it "deletes data_source" do
      delete data_source_path(data_source)

      expect(response).to redirect_to(data_sources_path)
      expect(DataSource.find_by(id: data_source.id)).to eq(nil)
    end
  end
end
