# == Schema Information
#
# Table name: user_relationships
#
#  id         :integer          not null, primary key
#  user_one   :integer
#  user_two   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe UserRelationship, type: :model do
  describe 'Create a relationship' do
    it "should create a new instance of a user relationship" do
      user1 = User.create!({email: 'requestor@mfauzi.id'})
      user2 = User.create!({email: 'target@mfauzi.id'})
      user_relationship = user1.user_relationships.build(user_two: user2).save
      expect(user1.all_friends.include?(user2)).to eq(true)
    end
  end

end

