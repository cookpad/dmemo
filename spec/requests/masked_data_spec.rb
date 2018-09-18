require "rails_helper"

describe :masked_data, type: :request do
  let(:user) { FactoryBot.create(:user, admin: true) }
  before do
    login!(user: user)
  end

  describe "#index" do
    it "redirects" do
      get masked_data_path
      expect(response).to redirect_to(setting_path)
    end
  end

  describe "#new" do
    let!(:database_memo) { FactoryBot.create(:database_memo, name: "foo") }

    it "shows" do
      get new_masked_datum_path
      expect(response).to render_template("masked_data/new")
      expect(assigns(:database_name_options)).to eq([["*", "*"], ["foo", "foo"]])
    end
  end
end
