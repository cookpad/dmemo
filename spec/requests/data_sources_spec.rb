require "rails_helper"

describe :data_sources, type: :request do
  before do
    login!(admin: true)
  end

  describe "#create" do
    let(:data_source_param) {
      { name: "dmemo", description: "", adapter: "postgresql", host: "localhost", port: 5432, dbname: "dmemo_test", user: "postgres" }
    }

    it "creates data_source and related memos" do
      post data_sources_path, data_source: data_source_param
      data_source = assigns(:data_source)
      expect(data_source).to be_present
      expect(response).to redirect_to(data_sources_path)
    end
  end

  describe "#update" do
    let!(:data_source) { FactoryGirl.create(:data_source) }

    it "updates related memos" do
      patch data_source_path(data_source.id), data_source: { description: "hello" }

      expect(data_source.id).to eq(assigns(:data_source).id)
      expect(response).to redirect_to(data_sources_path)

      expect(assigns(:data_source).description).to eq("hello")
    end
  end
end
