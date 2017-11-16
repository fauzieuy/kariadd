module ZiCorners
  class ValidationException < StandardError
    attr_reader :success, :code, :message

    def initialize(success = false, code, message)
      @success = success
      @code = code
      @message = message
    end

  end
end