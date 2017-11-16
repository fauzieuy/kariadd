class UserBlock < ApplicationRecord
  belongs_to :requestor, class_name: 'User', foreign_key: 'requestor_id'
  belongs_to :target, class_name: 'User', foreign_key: 'target_id'

  validates :requestor, uniqueness: { scope: :target_id,
                                       message: I18n.t('errors.user_block.already_blocked') }

  def self.unblock(requestor, target)
    where(requestor: requestor, target: target).destroy_all
  end

end
