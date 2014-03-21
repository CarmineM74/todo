require 'spec_helper'

describe Api::V1::ProjectsController  do
  default_version 1

  shared_examples "authentication required" do
    it "replies with status 401" do
      expect(response.status).to eq(401)
    end

    it "replies with authentication error" do
      expect(response).to be_api_error(RocketPants::Unauthenticated)
    end
  end

  let(:user_attrs) { FactoryGirl.attributes_for(:user) }
  let!(:user) { FactoryGirl.create(:user, user_attrs) }
  let(:proj_attrs) { FactoryGirl.attributes_for(:project) }
  let!(:user_with_prj) { FactoryGirl.create(:user_with_projects) }
  let(:first_prj) { user_with_prj.projects.first }

  context 'GET index', index: true do
    shared_examples "paginated results" do
      it "returns pagination data" do
        expect(response).to be_paginated_resource
      end
    end

    context 'when not logged in' do
      before(:each) do
        logout(user)
        get :index
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      context "and there are no projects" do
        before(:each) do
          logout(user)
          login_as(user_attrs)
          get :index
        end

        it_behaves_like "paginated results"

        it "response is empty" do
          expect(decoded_body.response).to be_empty
        end
      end

      context "and there are projects" do
        let!(:project) { FactoryGirl.create(:project, user: user) }
        before(:each) do
          logout(user)
          login_as(user_attrs)
          get :index
        end

        it_behaves_like "paginated results"

        it "returns an array of projects" do
          expect(response).to be_paginated_resource
        end

        it "returns project for current user" do
          u2 = FactoryGirl.create(:user)
          p2 = FactoryGirl.create(:project, user: u2)
          get :index
          expect(decoded_body.response.map {|p| p.user_id}).to_not include(u2.id)
        end
      end
    end
  end

  context "POST create project", create: true do

    context 'when not logged in' do
      before(:each) do
        logout(user)
        post :create, project: proj_attrs
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      before(:each) { logout(user); login_as(user_attrs) }

      context 'and post is successful' do
        it "returns the project created" do
          # attributes_for returns only the attributes defined
          # on the factory (no id, created_at ...)
          post :create, project: proj_attrs
          expect(decoded_body.response.title).to eq(proj_attrs[:title])
          expect(decoded_body.response.description).to eq(proj_attrs[:description])
        end

        it "returned project belongs to logged in user" do
          post :create, project: proj_attrs
          expect(decoded_body.response.user_id).to eq(user.id)
        end
      end

      context 'and post is unsuccessful' do
        it "returns the error/s that prevented project creation" do
          proj_attrs[:title] = ''
          post :create, project: proj_attrs
          expect(decoded_body.error).to_not be_empty
          expect(decoded_body.messages).to_not be_empty
        end
      end
    end
  end

  context "PUT update project", update: true do
    let!(:proj) { FactoryGirl.create(:project, proj_attrs) }

    def update(p)
      put :update, id: p['id'], project: p
    end

    context 'when not logged in' do
      before(:each) do
        logout(user)
        put :update, id: proj['id'], project: {title: 'updated'}
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      before(:each) do
        login_as({name: user_with_prj.name, password: 'mysecret'})
      end

      it "returns not_found error if project does not exists" do
        first_prj.id = first_prj.id+1974
        first_prj.title = 'updated'
        update(first_prj.attributes)
        expect(decoded_body.error).to eq('not_found')
      end

      it "returns not_found error if the project does not belong to current user" do
        update(proj.attributes)
        expect(decoded_body.error).to eq('not_found')
      end

      it "the updated project is returned if it exists" do
        first_prj.title = 'updated'
        update(first_prj.attributes)
        expect(decoded_body.response.title).to eq first_prj.title
      end

      it "the updated project belongs to current user" do
        first_prj.title = 'updated'
        update(first_prj.attributes)
        expect(decoded_body.response.user_id).to eq(user_with_prj.id)
      end
    end
  end

  context "DELETE delete project", delete: true do
    def remove(p)
      delete :destroy, id: p['id']
    end

    context 'when not logged in' do
      before(:each) do
        logout(user)
        delete :destroy, id: 1234
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      before(:each) do
        logout(user_with_prj)
        login_as({name: user_with_prj.name, password: 'mysecret'})
      end

      context "and the project does not exist" do
        it "returns not_found error" do
          remove({'id' => first_prj.id+19802})
          expect(decoded_body.error).to eq('not_found')
        end
      end

      context "and the project exist" do
        it "if the project belongs to current user it returns a success notification" do
          remove(first_prj.attributes)
          expect(response).to be_successful
        end
      end
    end

  end

end
