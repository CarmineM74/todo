require 'spec_helper'

describe Api::V1::SessionsController do
  default_version 1
  let!(:user) { FactoryGirl.create(:user) }

  shared_examples 'unauthorized request' do
    it 'response status is unauthorized' do
      expect(response.status).to eq(401)
    end

    it 'replies with unauthorized error' do
      expect(response).to be_api_error RocketPants::Unauthenticated
    end
  end

  describe 'POST create session' do
    context 'with invalid credentials' do
      before(:each) { post :create, user: {name: user.name, password: 'badpassword' } }

      it_behaves_like 'unauthorized request'
    end

    context 'with valid credentials' do
      before(:each) { post :create, user: {name: user.name, password: 'mysecret' } }

      it 'completes successfully' do
        expect(response).to be_successful
      end

      it 'returns authenticated user' do
        expect(response).to be_singular_resource
        expect(decoded_body.response.name).to eq(user.name)
      end

      it 'user has auth_token' do
        user.reload
        expect(user.auth_token).not_to be_nil
      end
    end
  end

  describe 'DELETE destroy session' do
    context 'when the token does not exists' do
      before(:each) do
        request.headers['Authorization'] = 'Token unexisting_token'
        delete :destroy
      end
      it_behaves_like 'unauthorized request'
    end

    context 'when the token exist' do
      let(:user_attrs) { {name: user.name, password: 'mysecret'} }

      before(:each) do
        login_as(user_attrs)
        delete :destroy
      end

      it 'completes successfully' do
        expect(response).to be_successful
      end

      it 'clears auth token from user' do
        user.reload
        expect(user.auth_token).to be_nil
      end

    end
  end

end
