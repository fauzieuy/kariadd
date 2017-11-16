require 'rails_helper'

RSpec.describe Api::V1::SubscribesController, type: :controller do

  describe 'GET /api/v1/subscribes/subscription' do
    let(:empty_params) { {  } }
    let(:invalid_params) { { email: 'mfauzi.id' } }

    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.email.blank')}" do
        get 'subscription', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.email.blank'))
      end

      it "returns error with message : #{I18n.t('errors.email.invalid')}" do
        get 'subscription', params: invalid_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.email.invalid'))
      end
    end

    let(:valid_params) { { email: 'requestor@mfauzi.id'} }
    let(:valid_params_with_no_subscription) { { email: 'wkwkwk@mfauzi.id'} }

    before {
      requestor = User.create!({email: 'requestor@mfauzi.id'})
      target = User.create!({email: 'target@mfauzi.id'})
      requestor.user_subscribes.build(publisher: target).save
      User.create!({email: 'wkwkwk@mfauzi.id'})
    }

    context 'when request is valid' do
      it 'returns success with one subscription' do
        get 'subscription', params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true, subscriptions: ['target@mfauzi.id'], count: 1}.to_json)
      end
    end

    context 'when request are valid and don\'t have a subscription' do
      it 'return success with no subscription' do
        get 'subscription', params: valid_params_with_no_subscription
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true, subscriptions: [], count: 0}.to_json)
      end
    end

  end

  describe 'POST /api/v1/subscribes/subscribe' do
    let(:empty_params) { {  } }
    let(:invalid_format_params) { { requestor: 'requestor@mfauzi.id', target: ['target@mfauzi.id'] } }

    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.subscribe.invalid')}" do
        post 'subscribe', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.subscribe.invalid'))
      end

      it "returns error with message : #{I18n.t('errors.target.invalid')}" do
        post 'subscribe', params: invalid_format_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.target.invalid'))
      end
    end

    let(:valid_params) { { requestor: 'requestor@mfauzi.id', target: 'target@mfauzi.id' } }
    let(:valid_params_with_email_not_found) { { requestor: 'not_found@mfauzi.id', target: 'target@mfauzi.id' } }
    let(:valid_params_with_already_subscribed) { { requestor: 'already1@mfauzi.id', target: 'already2@mfauzi.id' } }
    let(:valid_params_with_already_blocked) { { requestor: 'requestor@mfauzi.id', target: 'blocked@mfauzi.id' } }

    before {
      requestor = User.create!({email: 'requestor@mfauzi.id'})
      target = User.create!({email: 'target@mfauzi.id'})
      user_blocked = User.create!({email: 'blocked@mfauzi.id'})
      user1 = User.create!({email: 'already1@mfauzi.id'})
      user2 = User.create!({email: 'already2@mfauzi.id'})
      user1.user_subscribes.build(publisher: user2).save
      requestor.user_blocks.build(target: user_blocked).save
    }

    context 'when request is valid' do
      it 'returns success' do
        post 'subscribe', params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true}.to_json)
      end

      it 'returns success is false with message : User not_found@mfauzi.id not found' do
        post 'subscribe', params: valid_params_with_email_not_found
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.email.not_found', email: 'not_found@mfauzi.id')}.to_json)
      end

      it "returns success is false with message : #{I18n.t('errors.subscribe.already_subscribed')}" do
        post 'subscribe', params: valid_params_with_already_subscribed
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.subscribe.already_subscribed')}.to_json)
      end

      it "returns success is false with message : #{I18n.t('errors.subscribe.already_blocked')}" do
        post 'subscribe', params: valid_params_with_already_blocked
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.subscribe.already_blocked')}.to_json)
      end
    end

  end

  describe 'GET /api/v1/subscribes/unsubscribe' do
    let(:empty_params) { {  } }
    let(:invalid_format_params) { { requestor: 'requestor@mfauzi.id', target: ['target@mfauzi.id'] } }

    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.subscribe.invalid')}" do
        post 'unsubscribe', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.subscribe.invalid'))
      end

      it "returns error with message : #{I18n.t('errors.target.invalid')}" do
        post 'unsubscribe', params: invalid_format_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.target.invalid'))
      end

    end

    let(:valid_params) { { requestor: 'requestor@mfauzi.id', target: 'target@mfauzi.id' } }
    let(:valid_params_with_email_not_found) { { requestor: 'not_found@mfauzi.id', target: 'target@mfauzi.id' } }
    let(:valid_params_with_not_subscribe) {  { requestor: 'requestor@mfauzi.id', target: 'target2@mfauzi.id' } }

    before {
      requestor = User.create!({email: 'requestor@mfauzi.id'})
      target = User.create!({email: 'target@mfauzi.id'})
      target2 = User.create!({email: 'target2@mfauzi.id'})
      requestor.user_subscribes.build(publisher: target).save
    }

    context 'when request is valid' do
      it 'returns success' do
        post 'unsubscribe', params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true}.to_json)
      end

      it 'returns success is false with message : User not_found@mfauzi.id not found' do
        post 'unsubscribe', params: valid_params_with_email_not_found
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.email.not_found', email: 'not_found@mfauzi.id')}.to_json)
      end

      it "returns success is false with message : #{I18n.t('errors.subscribe.not_found')}" do
        post 'unsubscribe', params: valid_params_with_not_subscribe
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.subscribe.not_found')}.to_json)
      end
    end

  end

end
