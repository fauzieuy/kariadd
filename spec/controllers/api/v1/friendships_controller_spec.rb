require 'rails_helper'

RSpec.describe Api::V1::FriendshipsController, type: :controller do

  describe 'GET /api/v1/friendships/list' do
    let(:empty_params) { {  } }
    let(:invalid_params) { { email: 'mfauzi.id' } }


    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.email.blank')}" do
        get 'list', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.email.blank'))
      end

      it "returns error with message : #{I18n.t('errors.email.invalid')}" do
        get 'list', params: invalid_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.email.invalid'))
      end
    end

    let(:valid_params) { { email: 'requestor@mfauzi.id'} }
    let(:valid_params_with_no_friend) { { email: 'wkwkwk@mfauzi.id'} }

    before {
      user1 = User.create!({email: 'requestor@mfauzi.id'})
      user2 = User.create!({email: 'target@mfauzi.id'})
      user1.user_relationships.build(user_two: user2).save
      User.create!({email: 'wkwkwk@mfauzi.id'})
    }

    context 'when request is valid' do
      it 'returns success with one friend' do
        get 'list', params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true, friends: ['target@mfauzi.id'], count: 1}.to_json)
      end
    end

    context 'when request are valid and don\'t have a friend' do
      it 'return success with no friend' do
        get 'list', params: valid_params_with_no_friend
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true, friends: [], count: 0}.to_json)
      end
    end
  end

  describe 'POST /api/v1/friendships/connect' do
    let(:empty_params) { {  } }
    let(:invalid_format_params) { { friends: 'mfauzi.id, target@mfauzi.id' } }
    let(:invalid_format_email_params) { { friends: ['mfauzi.id', 'target@mfauzi.id'] } }

    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.friendship.blank')}" do
        post 'connect', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.friendship.blank'))
      end

      it "returns error with message : #{I18n.t('errors.friendship.blank')}" do
        post 'connect', params: invalid_format_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.friendship.blank'))
      end

      it "returns error with message : #{I18n.t('errors.email.invalid')}" do
        post 'connect', params: invalid_format_email_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.email.invalid'))
      end
    end

    let(:valid_params) { { friends: ['requestor@mfauzi.id', 'target@mfauzi.id'] } }
    let(:valid_params_with_email_not_found) { { friends: ['not_found@mfauzi.id', 'target@mfauzi.id'] } }
    let(:valid_params_with_already_connected) { { friends: ['already1@mfauzi.id', 'already2@mfauzi.id'] } }
    let(:valid_params_with_already_blocked) { { friends: ['requestor@mfauzi.id', 'blocked@mfauzi.id'] } }

    before {
      requestor = User.create!({email: 'requestor@mfauzi.id'})
      target = User.create!({email: 'target@mfauzi.id'})
      user_block = User.create!({email: 'blocked@mfauzi.id'})
      user1 = User.create!({email: 'already1@mfauzi.id'})
      user2 = User.create!({email: 'already2@mfauzi.id'})
      user1.user_relationships.build(user_two: user2).save
      requestor.user_blocks.build(target: user_block).save
    }

    context 'when request is valid' do
      it 'returns success' do
        post 'connect', params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true}.to_json)
      end

      it 'returns success is false with message : User not_found@mfauzi.id not found' do
        post 'connect', params: valid_params_with_email_not_found
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.email.not_found', email: 'not_found@mfauzi.id')}.to_json)
      end

      it "returns success is false with message : #{I18n.t('errors.friendship.already_connected')}" do
        post 'connect', params: valid_params_with_already_connected
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.friendship.already_connected')}.to_json)
      end

      it "returns success is false with message : #{I18n.t('errors.friendship.already_blocked')}" do
        post 'connect', params: valid_params_with_already_blocked
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.friendship.already_blocked')}.to_json)
      end
    end

  end

  describe 'GET /api/v1/friendships/unfriend' do
    let(:empty_params) { {  } }
    let(:invalid_format_params) { { friends: 'mfauzi.id, target@mfauzi.id' } }
    let(:invalid_format_email_params) { { friends: ['mfauzi.id', 'target@mfauzi.id'] } }

    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.friendship.blank')}" do
        post 'unfriend', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.friendship.blank'))
      end

      it "returns error with message : #{I18n.t('errors.friendship.blank')}" do
        post 'unfriend', params: invalid_format_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.friendship.blank'))
      end

      it "returns error with message : #{I18n.t('errors.email.invalid')}" do
        post 'unfriend', params: invalid_format_email_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.email.invalid'))
      end
    end

    let(:valid_params) { { friends: ['already1@mfauzi.id', 'already2@mfauzi.id'] } }
    let(:valid_params_with_email_not_found) { { friends: ['not_found@mfauzi.id', 'target@mfauzi.id'] } }
    let(:valid_params_with_not_connected) { { friends: ['requestor@mfauzi.id', 'target@mfauzi.id'] } }

    before {
      User.create!({email: 'requestor@mfauzi.id'})
      User.create!({email: 'target@mfauzi.id'})
      user1 = User.create!({email: 'already1@mfauzi.id'})
      user2 = User.create!({email: 'already2@mfauzi.id'})
      user1.user_relationships.build(user_two: user2).save
    }

    context 'when request is valid' do
      it 'returns success' do
        post 'unfriend', params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true}.to_json)
      end

      it 'returns success is false with message : User not_found@mfauzi.id not found' do
        post 'unfriend', params: valid_params_with_email_not_found
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.email.not_found', email: 'not_found@mfauzi.id')}.to_json)
      end

      it "returns success is false with message : #{I18n.t('errors.friendship.not_connected')}" do
        post 'unfriend', params: valid_params_with_not_connected
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.friendship.not_connected')}.to_json)
      end
    end
  end

  describe 'GET /api/v1/friendships/common' do
    let(:empty_params) { {  } }
    let(:invalid_format_params) { { friends: 'mfauzi.id, user@mfauzi.id' } }
    let(:invalid_format_email_params) { { friends: ['mfauzi.id', 'user@mfauzi.id'] } }

    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.friendship.blank')}" do
        get 'common', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.friendship.blank'))
      end

      it "returns error with message : #{I18n.t('errors.friendship.blank')}" do
        get 'common', params: invalid_format_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.friendship.blank'))
      end

      it "returns error with message : #{I18n.t('errors.email.invalid')}" do
        get 'common', params: invalid_format_email_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.email.invalid'))
      end
    end

    let(:valid_params) { { friends: ['user2@mfauzi.id', 'user3@mfauzi.id'] } }
    let(:valid_params_with_email_not_found) { { friends: ['not_found@mfauzi.id', 'user1@mfauzi.id'] } }
    let(:valid_params_without_common) { { friends: ['user2@mfauzi.id', 'user4@mfauzi.id'] } }

    before {
      user1 = User.create!({email: 'user1@mfauzi.id'})
      user2 = User.create!({email: 'user2@mfauzi.id'})
      user3 = User.create!({email: 'user3@mfauzi.id'})
      user4 = User.create!({email: 'user4@mfauzi.id'})
      user5 = User.create!({email: 'user5@mfauzi.id'})
      user1.user_relationships.build(user_two: user2).save
      user1.user_relationships.build(user_two: user3).save
      user4.user_relationships.build(user_two: user5).save
    }

    context 'when request is valid' do
      it 'returns success with one common friend' do
        get 'common', params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true, friends: ['user1@mfauzi.id'], count: 1}.to_json)
      end

      it 'return success with no email not found' do
        get 'common', params: valid_params_with_email_not_found
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.email.not_found', email: 'not_found@mfauzi.id')}.to_json)
      end

      it 'returns success with no common friend' do
        get 'common', params: valid_params_without_common
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true, friends: [], count: 0}.to_json)
      end
    end

  end

end
