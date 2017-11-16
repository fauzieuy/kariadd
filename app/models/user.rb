# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: /\A(\S+)@(.+)\.(\S+)\z/ }

  has_many :user_relationships, foreign_key: 'user_one_id'
  has_many :friends, through: :user_relationships, source: :user_two
  has_many :inverse_friendships, class_name: 'UserRelationship', foreign_key: 'user_two_id'
  has_many :inverse_friends, through: :inverse_friendships, source: :user_one

  has_many :user_subscribes, foreign_key: 'subscriber_id'
  has_many :subscriptions, through: :user_subscribes, source: :publisher
  has_many :inverse_subscribes, class_name: 'UserSubscribe', foreign_key: 'publisher_id'
  has_many :inverse_publishers, through: :inverse_subscribes, source: :subscriber

  has_many :user_blocks, foreign_key: 'requestor_id'
  has_many :user_blockeds, through: :user_blocks, source: :target
  has_many :inverse_blocks, class_name: 'UserBlock', foreign_key: 'target_id'
  has_many :inverse_blockers, through: :inverse_blocks, source: :requestor


  def all_friends
    self.friends + self.inverse_friends
  end

  def friends_list
    all_friends.map(&:email) rescue []
  end

  def subscriptions_list
    subscriptions.map(&:email) rescue []
  end

  def blocked_list
    user_blockeds.map(&:email) rescue []
  end

  def connect(target)
    self.user_relationships.build(user_two: target)
  end

  def is_connected_with?(target)
    self.friends.find_by(user_two: target) || self.inverse_friends.find_by(user_one: target)
  end

  def subscribe(target)
    self.user_subscribes.build(publisher: target)
  end

  def block(target)
    self.user_blocks.build(target: target)
  end

  def get_recipients(text)
    mentions = text.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) { |x| x }
    emails = self.subscriptions_list
    blocked_emails = self.blocked_list
    ((mentions & emails) | emails - blocked_emails)
  end

end
