require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.build(:user) }

  context 'validations' do
    context 'is valid' do
      it 'when using factory defaults' do
        user.save
        expect(user).to be_valid
      end

      it 'when creating multiple users without an auth_token' do
        u1 = FactoryGirl.create(:user)
        expect(u1).to be_valid
        u2 = FactoryGirl.create(:user)
        expect(u2).to be_valid
      end

    end

    context 'is invalid' do
      after(:each) { user.save; expect(user).to be_invalid }

      it 'without a name' do
        user.name = ''
      end

      it 'if name is already taken' do
        u = FactoryGirl.create(:user, name: user.name)
      end

      it 'without a password confirmation' do
        user.password_confirmation = ''
      end

      it 'when password confirmation does not match the password' do
        user.password = 'mismatch'
      end
    end

    context 'is invalid' do
      it 'when auth_token has already been taken' do
        user.auth_token = 'taken'
        user.save
        expect(user).to be_valid
        u2 = FactoryGirl.build(:user, auth_token: 'taken')
        u2.save
        expect(u2).to_not be_valid
      end
    end
  end

end
