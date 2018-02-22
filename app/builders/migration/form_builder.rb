# frozen_string_literal: true

module Migration
  class FormBuilder < SimpleForm::FormBuilder
    def find_input(*_)
      super.tap do |input|
        def input.i18n_scope
          'contribute.campaigns.migration.form'
        end

        # Overriding SimpleForm::Inputs::Base to log lookup candidates to 
        # facilitate development.
        #
        # Toggled on by setting ENV['ENABLE_SIMPLE_FORM_I18N_LOGGING']
        if ENV['ENABLE_SIMPLE_FORM_I18N_LOGGING']
          def input.translate_from_namespace(namespace, default = '')
            model_names = lookup_model_names.dup
            lookups     = []

            while !model_names.empty?
              joined_model_names = model_names.join(".")
              model_names.shift

              lookups << :"#{joined_model_names}.#{lookup_action}.#{reflection_or_attribute_name}"
              lookups << :"#{joined_model_names}.#{reflection_or_attribute_name}"
            end
            lookups << :"defaults.#{lookup_action}.#{reflection_or_attribute_name}"
            lookups << :"defaults.#{reflection_or_attribute_name}"
            lookups << default

            log_msg = "#{object.class.inspect}.#{attribute_name} SimpleForm i18n:\n" +
                      "* scope: #{i18n_scope}.#{namespace}\n" +
                      "* lookups:\n" +
                      lookups.reject(&:blank?).map { |l| "  - #{l}" }.join("\n")
            Rails.logger.debug(log_msg)

            I18n.t(lookups.shift, scope: :"#{i18n_scope}.#{namespace}", default: lookups).presence
          end
        end
      end
    end
  end
end
