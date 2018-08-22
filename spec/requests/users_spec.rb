require "rails_helper"

describe :users, type: :request do
  let(:user) { FactoryGirl.create(:user) }
  before do
    login!(user: user)
  end

  describe "#index" do
    it "shows index" do
      get users_path
      expect(response).to render_template("users/index")
      expect(page).to have_text(user.name)
    end
  end

  describe "#edit" do
    it "shows form" do
      get edit_user_path(user)
      expect(response).to render_template("users/edit")
      expect(page).to have_text(user.name)
      expect(page).not_to have_css("input#user_admin")
    end

    context "with admin" do
      let(:user) { FactoryGirl.create(:user, admin: true) }
      let(:another_user) { FactoryGirl.create(:user) }

      it "shows another user form" do
        get edit_user_path(another_user)
        expect(response).to render_template("users/edit")
        expect(page).to have_text(user.name)
        expect(page).to have_css("input#user_admin")
      end
    end

    context "with another user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:another_user) { FactoryGirl.create(:user) }

      it "returns 401" do
        get edit_user_path(another_user)
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "#update" do
    it "updates user" do
      patch user_path(user), params: { user: { name: "foo" } }
      expect(response).to redirect_to(edit_user_path(user))
      expect(user.reload.name).to eq("foo")
    end

    context "with admin" do
      let(:user) { FactoryGirl.create(:user, admin: true) }
      let(:another_user) { FactoryGirl.create(:user) }

      it "updates another user" do
        patch user_path(another_user), params: { user: { name: "foo", admin: true } }
        expect(response).to redirect_to(edit_user_path(another_user))
        expect(another_user.reload.name).to eq("foo")
        expect(another_user.admin).to eq(true)
      end
    end

    context "with another user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:another_user) { FactoryGirl.create(:user) }

      it "returns 401" do
        patch user_path(another_user), params: { user: { name: "foo" } }
        expect(response).to have_http_status(401)
      end
    end

    context "with normal user" do
      let(:user) { FactoryGirl.create(:user) }

      it "cannot update admin column" do
        patch user_path(user), params: { user: { admin: true } }
        expect(response).to have_http_status(401)
      end
    end
  end
end
