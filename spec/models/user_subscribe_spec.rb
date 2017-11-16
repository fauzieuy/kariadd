require 'rails_helper'

RSpec.describe UserSubscribe, type: :model do
  describe 'subscribe and unsubscribe' do
    it 'should subcribe and unsubcribe publisher' do
      subscriber = User.create!({email: 'subscriber@mfauzi.id'})
      publisher = User.create!({email: 'publisher@mfauzi.id'})
      user_subcribe = subscriber.user_subscribes.build(publisher: publisher).save
      expect(subscriber.subscriptions.include?(publisher)).to eq(true)
      user_unsubcriber = subscriber.user_subscribes.find_by(publisher_id: publisher.id).destroy
      expect(user_unsubcriber.destroyed?).to eq(true)
    end
  end
end
