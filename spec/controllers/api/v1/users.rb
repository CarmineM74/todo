require 'spec_helper'

describe Api::V1::UsersController do
  default_version 1

  shared_examples "resource not found" do
    it "replies with resource not found" do
      expect(response.status).to eq(404)
    end

    it "returns not_found error" do
      expect(decoded_body.error).to eq('not_found')
    end
  end

  shared_examples "authentication required" do
    it "replies with status 401" do
      expect(response.status).to eq(401)
    end

    it "replies with authentication error" do
      expect(response).to be_api_error(RocketPants::Unauthenticated)
    end
  end

  let!(:user_attrs) { FactoryGirl.attributes_for(:user) }
  let!(:user) { FactoryGirl.create(:user, user_attrs) }
  let!(:new_user_attrs) { FactoryGirl.attributes_for(:user) }

  describe 'POST create user' do
    context 'when the user already exist' do
      it 'replies with conflict error' do
        user.save
        post :create, user: {name: user.name, password: 'secret', password_confirmation: 'secret'}
        expect(response).to be_api_error RocketPants::Conflict
      end
    end

    context 'when the user does not exists' do
      before(:each) { post :create, user: new_user_attrs }

      it 'creation is successful' do
        expect(response).to be_successful
      end

      it 'returns created user' do
        expect(response).to be_singular_resource
        expect(decoded_body.name).to eq(new_user_attrs['name'])
      end
    end
  end

  describe 'PUT update user' do

    context 'when not logged in' do
      before(:each) do
        logout(user)
        put :update, id: user.id, user: {name: 'updated'}
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      before(:each) { login_as(user_attrs) }

      context 'and the logged in user is not the user to update' do
        let(:another_user) { FactoryGirl.create(:user) }

        before(:each) do
          logout(user)
          login_as({name: another_user.name, password: 'mysecret'})
          put :update, id: user.id, user: {name: 'updated'}
        end

        it_behaves_like 'authentication required'
      end

      context 'and the logged in user is the one to update' do
        context 'when user does not exists' do
          before(:each) { put :update, id: user.id+1980, user: {name: 'updated'} }
          it_behaves_like 'resource not found'
        end

        context 'when user exist' do
          it 'fails when parameters are invalid' do
            put :update, id: user.id, usar: {created_at: DateTime.now}
            expect(response).to be_api_error RocketPants::BadRequest
          end

          it 'does not update the model when supplied parameters are not allowed' do
            d = DateTime.now
            put :update, id: user.id, user: {created_at: d}
            expect(decoded_body.created_at).to_not eq(d)
          end

          context 'when valid parameters are supplied' do
            before(:each) { put :update, id: user.id, user: {name: 'updated'} }
            it 'updates the model' do
              expect(decoded_body.name).to_not eq('updated')
            end

            it 'update is successful' do
              expect(response).to be_successful
            end

            it 'returns the updated user' do
              expect(response).to be_singular_resource
            end
          end
        end
      end
    end
  end

  describe 'GET show user' do

    context 'when not logged in' do
      before(:each) do
        logout(user)
        get :show, id: user.id
      end

      it_behaves_like 'authentication required'

    end

    context 'when logged in', focus: true do
      before(:each) { login_as(user_attrs) }

      context 'and requesting user details of another user' do
        let(:another_user) { FactoryGirl.create(:user) }
        before(:each) { get :show, id: another_user.id }

        it_behaves_like 'authentication required'
      end

      context 'and requesting user details of current user' do
        context 'when the user does not exists' do
          before(:each) { get :show, id: user.id+198 }
          it_behaves_like 'resource not found'
        end

        context 'when the user exist' do
          before(:each) { get :show, id: user.id }

          it 'is successful' do
            expect(response).to be_successful
          end

          it 'returns requested user' do
            expect(response).to be_singular_resource
          end
        end
      end
    end
  end

end
