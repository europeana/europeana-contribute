# frozen_string_literal: true

module Debug
  # Include this in an ActiveModel class to get some debug logging on validation
  module Validation
    extend ActiveSupport::Concern

    def valid?
      Rails.logger.debug("[ActiveModel::Validation] #{self.class}#valid? <#{id}>")
      super
    end
  end
end
