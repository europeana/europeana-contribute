# frozen_string_literal: true

module Fields
  module Types
    class LocalizedHash < RailsAdmin::Config::Fields::Types::String
      def parse_input(params)
        add_localisations_from_input(params) if params[method_name] && params[method_name]['+']
        remove_localisations_from_input(params) if params[method_name] && params[method_name]['-']
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

      protected

      def add_localisations_from_input(params)
        locale = params[method_name]['+']['locale']
        value = params[method_name]['+']['value']
        params[method_name].delete('+')
        params[method_name][locale] = value unless value.blank?
      end

      def remove_localisations_from_input(params)
        params[method_name]['-'].each_key do |locale|
          params[method_name].delete(locale)
        end
        params[method_name].delete('-')
      end
    end
  end
end
