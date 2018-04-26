# frozen_string_literal: true

module Blankness
  # Customisable blankness checking
  #
  # @example With two blankness checks
  #   class Dummy
  #     include Blankness::Check
  #     checks_blankness_with :blank_title?, :blank_description?
  #
  #     def blank_title?
  #       @title.blank?
  #     end
  #
  #     def blank_description?
  #       @description.blank?
  #     end
  #   end
  #
  #   Dummy.new.blank? # Calls Dummy#blank_title? and Dummy#blank_description?
  #                    # and only returns true if both of those return true
  module Check
    extend ActiveSupport::Concern

    included do
      class_attribute :blankness_checkers
      self.blankness_checkers = []
    end

    class_methods do
      # Registers one or more methods with which to check for blankness.
      # Only if all these methods return `true` is the object considered blank.
      def checks_blankness_with(*meths)
        meths.each do |meth|
          blankness_checkers.push(meth)
        end
      end
    end

    def blank?
      return super if self.class.blankness_checkers.blank?
      self.class.blankness_checkers.map { |meth| send(meth) }.all?
    end
  end
end
