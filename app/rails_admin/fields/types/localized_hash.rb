# frozen_string_literal: true

module Fields
  module Types
    class LocalizedHash < RailsAdmin::Config::Fields::Types::String
      def parse_input(params)
        if params[method_name] && params[method_name]['+']
          locale, value = params[method_name]['+']['locale'], params[method_name]['+']['value']
          params[method_name].delete('+')
          params[method_name][locale] = value unless value.blank?
        end

        if params[method_name] && params[method_name]['-']
          params[method_name]['-'].keys.each do |locale|
            params[method_name].delete(locale)
          end
          params[method_name].delete('-')
        end
      end

      def method_name
        "#{name}_translations".to_sym
      end

      register_instance_option :partial do
        :localized_hash
      end

      register_instance_option :pretty_value do
        formatted_value&.map { |locale, value| "#{locale}: #{value}" }&.join('; ')
      end
    end
  end
end
