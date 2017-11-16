# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'Validation' do
    it 'should validate presence of email' do
      record = User.new({email: ''})
      record.valid? # run validations
      expect(record.errors[:email]).to include('can\'t be blank')
    end

    it 'should validate uniqueness of email' do
      user1 = User.new({email: 'me@mfauzi.id'})
      user1.save # run validations
      user2 = User.new({email: 'me@mfauzi.id'})
      user2.valid?
      expect(user2.errors[:email]).to include('has already been taken')
    end
  end

  describe 'Create & Update a user' do
    it "should create a new instance of a user" do
      user = User.new({email: 'me@mfauzi.id'})
      user.save
      expect(User.find_by(email: 'me@mfauzi.id')).to eq(user)
    end

    it "should update a user" do
      user = User.new({email: 'me@mfauzi.id'})
      user.save
      user.update_attributes(email: 'fauzieuy@gmail.com')
      expect(User.find_by(email: 'fauzieuy@gmail.com').email).to eq(user.email)
    end
  end

end
