# frozen_string_literal: true

module Migration
  class FormBuilder < ApplicationFormBuilder
    def find_input(*_)
      super.tap do |input|
        def input.i18n_scope
          'contribute.campaigns.generic.form'
        end
      end
    end
  end
end
