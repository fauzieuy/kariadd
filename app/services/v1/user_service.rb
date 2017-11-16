module V1
  class UserService
    include ZiCorners::BaseService

    validate_params :new_user, :validate_new_user_params
    def new_user(params)
      new_user = User.new(params)
      if new_user.save
        { success: true }
      else
        { success: false, message: new_user.errors.full_messages.first }
      end
    end

    validate_params :block, :validate_block_params
    def block(params)
      validate_email = validate_email_user(params)
      if validate_email[:success] == false
        return validate_email
      end
      requestor = validate_email[:user1]
      target = validate_email[:user2]
      user_block = requestor.block(target)
      if user_block.save
        return { success: true }
      else
        return { success: false, message: user_block.errors.full_messages.first }
      end
    end

    validate_params :unblock, :validate_unblock_params
    def unblock(params)
      validate_email = validate_email_user(params)
      if validate_email[:success] == false
        return validate_email
      end
      requestor = validate_email[:user1]
      target = validate_email[:user2]
      unblock = UserBlock.unblock(requestor, target)
      if unblock.size > 0
        return { success: true }
      else
        return { success: false, message: I18n.t('errors.user_block.not_found') }
      end
    end

    validate_params :send_text, :validate_send_text_params
    def send_text(params)
      sender = User.find_by(email: params[:sender])
      if sender.nil?
        return { success: false, message: I18n.t('errors.email.not_found') }
      end
      receipients = sender.get_recipients(params[:text])
      { success: true, recipients: [] }
    end

    private

    def validate_new_user_params(params)
        unless params.has_key?(:email)
          raise ValidationException.new('User#create', I18n.t('errors.email.blank'))
        end
    end

    def validate_block_params(params)
      if !params.has_key?(:requestor) && !params.has_key?(:target)
        raise ValidationException.new('User#block', I18n.t('errors.user_block.invalid'))
      else
        unless params[:requestor].is_a?(String)
          raise ValidationException.new('User#block', I18n.t('errors.requestor.invalid'))
        end
        unless params[:target].is_a?(String)
          raise ValidationException.new('User#block', I18n.t('errors.target.invalid'))
        end
      end
    end

    def validate_unblock_params(params)
      if !params.has_key?(:requestor) && !params.has_key?(:target)
        raise ValidationException.new('User#unblock', I18n.t('errors.user_block.invalid'))
      else
        unless params[:requestor].is_a?(String)
          raise ValidationException.new('User#unblock', I18n.t('errors.requestor.invalid'))
        end
        unless params[:target].is_a?(String)
          raise ValidationException.new('User#unblock', I18n.t('errors.target.invalid'))
        end
      end
    end

    def validate_send_text_params(params)
      if !params.has_key?(:sender) && !params.has_key?(:text)
        raise ValidationException.new('User#unblock', I18n.t('errors.send_text.invalid'))
      else
        unless params[:sender].is_a?(String)
          raise ValidationException.new('User#unblock', I18n.t('errors.sender.invalid'))
        end
        unless params[:text].is_a?(String)
          raise ValidationException.new('User#unblock', I18n.t('errors.text.invalid'))
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