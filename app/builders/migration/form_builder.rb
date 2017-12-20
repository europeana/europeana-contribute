# frozen_string_literal: true

module Migration
  class FormBuilder < SimpleForm::FormBuilder
    def find_input(*_)
      super.tap do |input|
        def input.i18n_scope
          'site.campaigns.migration.attributes'
        end
      end
    end
  end
end
