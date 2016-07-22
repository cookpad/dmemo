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

      expect(data_source.database_memo.name).to eq("dmemo")

      schema_memo = data_source.database_memo.schema_memos.take!
      expect(schema_memo.name).to eq("public")

      expect(schema_memo.table_memos.find_by!(name: "data_sources")).to be_present

      dataset = schema_memo.table_memos.find_by!(name: "data_sources").raw_dataset
      expect(dataset.count).to eq(1)
      expect(dataset.columns.map(&:name)).to match_array(%w(id name description adapter host port dbname user password encoding pool created_at updated_at))
      expect(dataset.rows.take.row[1..7]).to match_array(["dmemo", "", "postgresql", "localhost", "5432", "dmemo_test", "postgres"])
    end

    context "with invalid connection param" do
      before do
        data_source_param[:port] = 5439
      end

      it "fails data_sources sync" do
        post data_sources_path, data_source: data_source_param
        data_source = assigns(:data_source)
        expect(data_source).to be_present
        expect(response).to redirect_to(data_sources_path)
        expect(flash[:error]).to be_present

        expect(data_source.database_memo).to be_present
        expect(data_source.database_memo.schema_memos.count).to eq(0)
      end
    end
  end

  describe "#update" do
    let!(:data_source) { FactoryGirl.create(:data_source) }

    it "updates related memos" do
      expect(DatabaseMemo.count).to eq(0)

      put data_source_path(data_source.id), data_source: { update: 1 }

      expect(data_source).to eq(assigns(:data_source))
      expect(response).to redirect_to(data_sources_path)

      expect(data_source.database_memo.name).to eq("dmemo")

      schema_memo = data_source.database_memo.schema_memos.take!
      expect(schema_memo.name).to eq("public")

      expect(schema_memo.table_memos.find_by!(name: "data_sources")).to be_present
    end
  end
end
