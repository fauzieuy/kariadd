module V1
  class SubscribeService
    include ZiCorners::BaseService

    validate_params :subscriptions_list, :validate_subscriptions_list_params
    def subscriptions_list(params)
      requestor = User.find_by(email: params[:email])
      if requestor.nil?
        return { success: false, message: I18n.t('errors.email.not_found') }
      end
      subscriptions_list = requestor.subscriptions_list
      { success: true, subscriptions: subscriptions_list, count: subscriptions_list.size }
    end

    validate_params :subscribe, :validate_subscribe_params
    def subscribe(params)
      validate_email = validate_email_user(params)
      if validate_email[:success] == false
        return validate_email
      end
      requestor = validate_email[:user1]
      target = validate_email[:user2]
      user_subscribe = requestor.subscribe(target)
      if user_subscribe.save
        return { success: true }
      else
        return { success: false, message: user_subscribe.errors.full_messages.first }
      end
    end

    validate_params :unsubscribe, :validate_unsubscribe_params
    def unsubscribe(params)
      validate_email = validate_email_user(params)
      if validate_email[:success] == false
        return validate_email
      end
      requestor = validate_email[:user1]
      target = validate_email[:user2]
      unsubscribe = UserSubscribe.unsubscribe(requestor, target)
      if unsubscribe.size > 0
        return { success: true }
      else
        return { success: false, message: I18n.t('errors.subscribe.not_found') }
      end
    end

    private

    def validate_subscriptions_list_params(params)
      if params[:email].present?
        unless params[:email] =~ /\A(\S+)@(.+)\.(\S+)\z/
          raise ValidationException.new('Subscribe#subscription', I18n.t('errors.email.invalid'))
        end
      else
        raise ValidationException.new('Subscribe#subscription', I18n.t('errors.email.blank'))
      end
    end

    def validate_subscribe_params(params)
      if !params.has_key?(:requestor) && !params.has_key?(:target)
        raise ValidationException.new('Subscribe#subscribe', I18n.t('errors.subscribe.invalid'))
      else
        unless params[:requestor].is_a?(String)
          raise ValidationException.new('Subscribe#subscribe', I18n.t('errors.requestor.invalid'))
        end
        unless params[:target].is_a?(String)
          raise ValidationException.new('Subscribe#subscribe', I18n.t('errors.target.invalid'))
        end
      end
    end

    def validate_unsubscribe_params(params)
      if !params.has_key?(:requestor) && !params.has_key?(:target)
        raise ValidationException.new('Subscribe#subscribe', I18n.t('errors.subscribe.invalid'))
      else
        unless params[:requestor].is_a?(String)
          raise ValidationException.new('Subscribe#subscribe', I18n.t('errors.requestor.invalid'))
        end
        unless params[:target].is_a?(String)
          raise ValidationException.new('Subscribe#subscribe', I18n.t('errors.target.invalid'))
        end
      end
    end


    def validate_email_user(params)
      email1, email2 = params[:requestor], params[:target]
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