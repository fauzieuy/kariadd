module V1
  class FriendshipService
    include ZiCorners::BaseService

    validate_params :friends_list, :validate_friends_list_params
    def friends_list(params)
      requestor = User.find_by(email: params[:email])
      if requestor.nil?
        return { success: false, message: I18n.t('errors.email.not_found') }
      end
      friends_list = requestor.friends_list
      { success: true, friends: friends_list, count: friends_list.size }
    end

    validate_params :friend_connection, :validate_friend_connection_params
    def friend_connection(params)
      validate_email = validate_email_user(params)
      if validate_email[:success] == false
        return validate_email
      end
      user1 = validate_email[:user1]
      user2 = validate_email[:user2]
      user_relationship = user1.connect(user2)
      if user_relationship.save
        return { success: true }
      else
        return { success: false, message: user_relationship.errors.full_messages.first }
      end
    end

    validate_params :unfriend_connection, :validate_friend_connection_params
    def unfriend_connection(params)
      validate_email = validate_email_user(params)
      if validate_email[:success] == false
        return validate_email
      end
      user1 = validate_email[:user1]
      user2 = validate_email[:user2]
      unfriend = UserRelationship.unfriend(user1, user2)
      if unfriend.size > 0
        return { success: true }
      else
        return { success: false, message: I18n.t('errors.friendship.not_connected') }
      end
    end

    validate_params :common_friend, :validate_common_friend_params
    def common_friend(params)
      validate_email = validate_email_user(params)
      if validate_email[:success] == false
        return validate_email
      end
      user1 = validate_email[:user1]
      user2 = validate_email[:user2]
      common_friend = UserRelationship.common_friend(user1, user2)
      { success: true, friends: common_friend, count: common_friend.size }
    end

    private

    def validate_friends_list_params(params)
      if params[:email].present?
        unless params[:email] =~ /\A(\S+)@(.+)\.(\S+)\z/
          raise ValidationException.new('Friendship#List', I18n.t('errors.email.invalid'))
        end
      else
        raise ValidationException.new('Friendship#List', I18n.t('errors.email.blank'))
      end
    end

    def validate_friend_connection_params(params)
      if params[:friends].present?
        if !params[:friends].is_a?(Array) || params[:friends].size != 2
          raise ValidationException.new('Friendship#connect', I18n.t('errors.friendship.invalid'))
        else
          if params[:friends].map{|x| x =~ /\A(\S+)@(.+)\.(\S+)\z/ }.include?(nil)
            raise ValidationException.new('Friendship#connect', I18n.t('errors.email.invalid'))
          end
        end
      else
        raise ValidationException.new('Friendship#connect', I18n.t('errors.friendship.blank'))
      end
    end

    def validate_common_friend_params(params)
      if params[:friends].present?
        if !params[:friends].is_a?(Array) || params[:friends].size != 2
          raise ValidationException.new('Friendship#common', I18n.t('errors.friendship.invalid'))
        else
          if params[:friends].map{|x| x =~ /\A(\S+)@(.+)\.(\S+)\z/ }.include?(nil)
            raise ValidationException.new('Friendship#common', I18n.t('errors.email.invalid'))
          end
        end
      else
        raise ValidationException.new('Friendship#common', I18n.t('errors.friendship.blank'))
      end
    end


    def validate_email_user(params)
      email1, email2 = params[:friends]
      user1 = User.find_by(email: email1)
      result = { success: true }
      unless user1
        result = { success: false, message: I18n.t('errors.email.not_found', email: email1) }
      end
      user2 = User.find_by(email: email2)
      unless user2
        result = { success: false, message: I18n.t('errors.email.not_found', email: email2) }
      end
      if result[:success] != false
        result = { user1: user1, user2: user2, result: result }
      end
      return result
    end

  end
end