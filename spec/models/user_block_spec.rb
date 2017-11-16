require 'rails_helper'

RSpec.describe UserBlock, type: :model do
  describe 'Block & Unblock' do
    it "should block and ublock a user" do
      requestor = User.create!({email: 'requestor@mfauzi.id'})
      target = User.create!({email: 'target@mfauzi.id'})
      user_block = requestor.user_blocks.build(target: target).save
      expect(requestor.user_blockeds.include?(target)).to eq(true)
      user_unblock = requestor.user_blocks.find_by(target_id: target.id).destroy
      expect(user_unblock.destroyed?).to eq(true)
    end
  end
end
