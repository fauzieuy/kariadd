# == Schema Information
#
# Table name: user_relationships
#
#  id         :integer          not null, primary key
#  user_one   :integer
#  user_two   :integer
#  is_blocked :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserRelationship < ApplicationRecord
  belongs_to :user_one, class_name: 'User', foreign_key: 'user_one_id'
  belongs_to :user_two, class_name: 'User', foreign_key: 'user_two_id'

  validates :user_one_id, uniqueness: { scope: :user_two_id,
                                        message: I18n.t('errors.friendship.already_connected') }
  validate :uniqueness_friendships
  validate :user_is_blocked?


  def self.unfriend(user1, user2)
    where(user_one: user1, user_two: user2).or(self.where(user_two: user1, user_one: user2)).destroy_all
  end

  def self.common_friend(user1, user2)
    user1_friends = user1.all_friends.map(&:email)
    user2_friends = user2.all_friends.map(&:email)
    user1_friends.select{|x| user2_friends.include?(x) } || []
  end

  private

  def uniqueness_friendships
    if UserRelationship.where(user_one_id: self.user_two_id, user_two_id: self.user_one_id).present?
      errors.add(:user_one_id, :already_connected, message: I18n.t('errors.friendship.already_connected'))
    end
  end

  def user_is_blocked?
    if UserBlock.where(requestor: self.user_one, target: self.user_two).present?
      errors.add(:user_one_id, :already_blocked, message: I18n.t('errors.friendship.already_blocked'))
    end
    if UserBlock.where(requestor: self.user_two, target: self.user_one).present?
      errors.add(:user_two_id, :you_are_blocked, message: I18n.t('errors.friendship.you_are_blocked'))
    end
  end

end
