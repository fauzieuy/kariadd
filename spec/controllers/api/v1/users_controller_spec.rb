require 'rails_helper'
require 'pry'

RSpec.describe Api::V1::UsersController, type: :controller do

  describe 'POST /api/v1/users' do
    let(:empty_params) { {  } }
    let(:invalid_params) { { user: { email: 'mfauzi.id' } } }

    context 'when request is invalid' do
      it "raise an error parameter missing" do
        expect{ post(:create, empty_params) }.to raise_error ActionController::ParameterMissing
      end

      it "returns error with message : Email is invalid format" do
        post 'create', params: invalid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: 'Email is invalid format.'}.to_json)
      end
    end

    let(:valid_params) { { user: { email: 'me@mfauzi.id' } } }
    let(:valid_params_with_email_empty) { { user: { email: '' } } }
    let(:valid_params_with_email_taken) { { user: { email: 'already@mfauzi.id' } } }

    before {
      User.create!(email: 'already@mfauzi.id')
    }

    context 'when request is valid' do
      it 'returns success' do
        post 'create', params: valid_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(true)
      end

      it 'returns success is false with message : Email can\'t be blank' do
        post 'create', params: valid_params_with_email_empty
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: 'Email can\'t be blank.'}.to_json)
      end

      it 'returns success is false with message : Email already been taken' do
        post 'create', params: valid_params_with_email_taken
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: 'Email already been taken.'}.to_json)
      end
    end
  end

  describe 'POST /api/v1/users/block' do
    let(:empty_params) { {  } }
    let(:invalid_format_params) { { requestor: 'requestor@mfauzi.id', target: ['target@mfauzi.id'] } }

    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.user_block.invalid')}" do
        post 'block', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.user_block.invalid'))
      end

      it "returns error with message : #{I18n.t('errors.target.invalid')}" do
        post 'block', params: invalid_format_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.target.invalid'))
      end
    end

    let(:valid_params) { { requestor: 'requestor@mfauzi.id', target: 'target@mfauzi.id' } }
    let(:valid_params_with_email_not_found) { { requestor: 'not_found@mfauzi.id', target: 'target@mfauzi.id' } }
    let(:valid_params_with_already_blocked) { { requestor: 'already1@mfauzi.id', target: 'already2@mfauzi.id' } }

    before {
      User.create!({email: 'requestor@mfauzi.id'})
      User.create!({email: 'target@mfauzi.id'})
      user1 = User.create!({email: 'already1@mfauzi.id'})
      user2 = User.create!({email: 'already2@mfauzi.id'})
      user1.user_blocks.build(target: user2).save
    }

    context 'when request is valid' do
      it 'returns success' do
        post 'block', params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true}.to_json)
      end

      it 'returns success is false with message : User not_found@mfauzi.id not found' do
        post 'block', params: valid_params_with_email_not_found
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.email.not_found', email: 'not_found@mfauzi.id')}.to_json)
      end

      it "returns success is false with message : #{I18n.t('errors.user_block.already_blocked')}" do
        post 'block', params: valid_params_with_already_blocked
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.user_block.already_blocked')}.to_json)
      end
    end
  end

  describe 'POST /api/v1/users/unblock' do
    let(:empty_params) { {  } }
    let(:invalid_format_params) { { requestor: 'requestor@mfauzi.id', target: ['target@mfauzi.id'] } }

    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.user_block.invalid')}" do
        post 'unblock', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.user_block.invalid'))
      end

      it "returns error with message : #{I18n.t('errors.target.invalid')}" do
        post 'unblock', params: invalid_format_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.target.invalid'))
      end
    end

    let(:valid_params) { { requestor: 'requestor@mfauzi.id', target: 'target@mfauzi.id' } }
    let(:valid_params_with_email_not_found) { { requestor: 'not_found@mfauzi.id', target: 'target@mfauzi.id' } }
    let(:valid_params_with_not_blocked) {  { requestor: 'requestor@mfauzi.id', target: 'target2@mfauzi.id' } }

    before {
      requestor = User.create!({email: 'requestor@mfauzi.id'})
      target = User.create!({email: 'target@mfauzi.id'})
      target2 = User.create!({email: 'target2@mfauzi.id'})
      requestor.user_blocks.build(target: target).save
    }

    context 'when request is valid' do
      it 'returns success' do
        post 'unblock', params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: true}.to_json)
      end

      it 'returns success is false with message : User not_found@mfauzi.id not found' do
        post 'unblock', params: valid_params_with_email_not_found
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.email.not_found', email: 'not_found@mfauzi.id')}.to_json)
      end

      it "returns success is false with message : #{I18n.t('errors.user_block.not_found')}" do
        post 'unblock', params: valid_params_with_not_blocked
        expect(response).to have_http_status(200)
        expect(response.body).to eq({success: false, message: I18n.t('errors.user_block.not_found')}.to_json)
      end
    end
  end

  describe 'POST /api/v1/users/send_text' do
    let(:empty_params) { {  } }
    let(:invalid_format_params) { { sender: 'requestor@mfauzi.id', text: ['foo bar'] } }

    context 'when request is invalid' do
      it "returns error with message : #{I18n.t('errors.send_text.invalid')}" do
        post 'send_text', params: empty_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.send_text.invalid'))
      end

      it "returns error with message : #{I18n.t('errors.text.valid')}" do
        post 'send_text', params: invalid_format_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('errors.text.invalid'))
      end

    end
  end
end
