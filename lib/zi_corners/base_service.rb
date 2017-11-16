module ZiCorners
  module BaseService

    def result_error(success, code, message)
      result = ServiceResult.new
      result.success = success
      result.code = code
      result.message = message
      result
    end

    # Method Hook using Decorator Pattern
    # this method is invoked whenever a new instance method is added to a class
    def method_added(method_name)
      # do nothing if the method that was added was an actual hook method, or
      # if it already had hooks added to it
      return if hook_methods.include?(method_name) || hooked_methods.include?(method_name)
      add_hooks_to(method_name)
    end

    # this is the DSL method that classes use to add before hooks
    def validate_params(method_name, hook_method_name)
      # check if already exists
      hooks.select { |pair| pair.has_key?(method_name) }.each do |elem|
        return if elem[method_name] == hook_method_name
      end
      hook_methods << hook_method_name
      hooks << { method_name => hook_method_name }
    end

    # keeps track of all before hooks
    def hooks
      @hooks ||= []
    end

    # keeps track of all hook methods
    def hook_methods
      @hook_methods ||= []
    end

    private
    # keeps track of all currently hooked methods
    def hooked_methods
      @hooked_methods ||= []
    end

    def add_hooks_to(method_name)
      # add this method to known hook mappings to avoid infinite
      # recursion when we redefine the method below
      hooked_methods << method_name

      # grab the original method definition
      original_method = instance_method(method_name)

      # re-define the method, but notice how we reference the original method definition
      define_method(method_name) do |*args, &block|
        begin
          # invoke the hook methods with parameters needed
          self.class.hooks.select { |pair| pair.has_key?(method_name) }.each do |elem|
            method(elem[method_name]).call(*args, &block)
          end

          # now invoke the original method
          original_method.bind(self).call(*args, &block)
        rescue ZiCorners::ValidationException => e
          result_error e.success, e.code, e.message
        end
      end
    end

  end


  # Make it available to all classes.
  Class.send(:include, ZiCorners::BaseService)
end