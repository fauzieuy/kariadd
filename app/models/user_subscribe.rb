class UserSubscribe < ApplicationRecord
  belongs_to :subscriber, class_name: 'User', foreign_key: 'subscriber_id'
  belongs_to :publisher, class_name: 'User', foreign_key: 'publisher_id'

  validates :subscriber, uniqueness: { scope: :publisher_id,
                                        message: I18n.t('errors.subscribe.already_subscribed') }
  validate :user_is_blocked?

  def self.unsubscribe(requestor, target)
    where(subscriber: requestor, publisher: target).destroy_all
  end

  private

  def user_is_blocked?
    if UserBlock.where(requestor: self.subscriber, target: self.publisher).present?
      errors.add(:subscriber_id, :already_blocked, message: I18n.t('errors.subscribe.already_blocked'))
    end
    if UserBlock.where(requestor: self.publisher, target: self.subscriber).present?
      errors.add(:publisher_id, :you_are_blocked, message: I18n.t('errors.subscribe.you_are_blocked'))
    end
  end
end
