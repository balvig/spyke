require 'spyke/config'
require 'spyke/path'
require 'spyke/result'
require 'spyke/normalized_validation_error'

module Spyke
  module Http
    extend ActiveSupport::Concern
    METHODS = %i{ get post put patch delete }

    included do
      class_attribute :connection, instance_accessor: false
    end

    module ClassMethods
      METHODS.each do |method|
        define_method(method) do
          new_instance_or_collection_from_result scoped_request(method)
        end
      end

      def request(method, path, params = {})
        ActiveSupport::Notifications.instrument('request.spyke', method: method) do |payload|
          response = send_request(method, path, params)
          payload[:url], payload[:status] = response.env.url, response.status
          Result.new_from_response(response)
        end
      end

      def new_instance_from_result(result)
        new_or_return result.data if result.data
      end

      def new_collection_from_result(result)
        Collection.new Array(result.data).map { |record| new_or_return(record) }, result.metadata
      end

      def uri(uri_template = nil)
        @uri ||= uri_template || default_uri
      end

      private

        def send_request(method, path, params)
          connection.send(method) do |request|
            if method == :get
              path, params = merge_query_params(path, params)
              request.url path, params
            else
              request.url path.to_s
              request.body = params
            end
          end
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError
          raise ConnectionError
        end

        def merge_query_params(path, params)
          parsed_uri = Addressable::URI.parse(path.to_s)
          path = parsed_uri.path
          params = params.merge(parsed_uri.query_values || {})
          [path, params]
        end

        def scoped_request(method)
          uri = new.uri
          params = current_scope.params.except(*uri.variables)
          request(method, uri, params)
        end

        def new_instance_or_collection_from_result(result)
          if result.data.is_a?(Array)
            new_collection_from_result(result)
          else
            new_instance_from_result(result)
          end
        end

        def new_or_return(attributes_or_object)
          if attributes_or_object.is_a?(Spyke::Base)
            attributes_or_object
          else
            new attributes_or_object
          end
        end

        def default_uri
          "#{model_name.element.pluralize}(/:#{primary_key})"
        end
    end

    METHODS.each do |method|
      define_method(method) do |action = nil, params = {}|
        params = action if action.is_a?(Hash)
        path = resolve_path_from_action(action)

        result = self.class.request(method, path, params)

        add_errors_to_model(result.errors)
        self.attributes = result.data
        self
      end
    end

    def uri
      Path.new(@uri_template, attributes) if @uri_template
    end

    private

      def add_errors_to_model(errors_hash)
        errors_hash.each do |field, field_errors|
          field_errors.each do |error_attributes|
            error = NormalizedValidationError.new(error_attributes)

            if ActiveSupport::VERSION::MAJOR < 5
              errors.add(field.to_sym, error.message, error.options)
            else
              errors.add(field.to_sym, error.message, **error.options)
            end
          end
        end
      end

      def resolve_path_from_action(action)
        case action
        when Symbol then uri.join(action)
        when String then Path.new(action, attributes)
        else uri
        end
      end
  end
end
