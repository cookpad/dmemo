require "rails_helper"

describe :markdown_previews, type: :request do
  describe "#create" do
    before do
      login!
    end

    it "creates markdown preview" do
      post markdown_preview_path(md: "**hoge**"), format: :json
      expect(response).to render_template("markdown_previews/create")
      data = JSON.parse(response.body)
      expect(data["html"]).to be_include("<strong>hoge</strong>")
    end
  end
end
