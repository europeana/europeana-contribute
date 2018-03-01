# frozen_string_literal: true

module Blankness
  module Mongoid
    # Detect and reject blank Mongoid relations
    #
    # TODO: consider moving some of this into custom validator and splitting
    #   the responsibilities of this module into: detection; rejection
    module Relations
      extend ActiveSupport::Concern
      include Check

      included do
        before_save :reject_blank_relations!
        checks_blankness_with :all_relations_blank?
      end

      class_methods do
        # Relations to remove instances of, before saving, if they are `#blank?`
        def rejects_blank(*args)
          args.each do |name|
            assert_valid_relation!(name)
            rejectable_relations.push(name.to_s)
          end
        end

        # Relations to test blankness of for this object to be considered blank
        def is_present_unless_blank(*args)
          args.each do |name|
            assert_valid_blankness_relation!(name)
            blankness_relations.push(name.to_s)
          end
        end

        def rejectable_relations
          @rejectable_relations ||= []
        end

        def blankness_relations
          @blankness_relations ||= []
        end

        def assert_valid_relation!(name)
          fail ArgumentError, %(Unknown relation "#{name}") unless relations.key?(name.to_s)
        end

        # Do not permit circular references to relation blankness checking as that
        # would result in infinite recursion back and forth across the relation to
        # check for blankness of each side's relations.
        #
        # This is not fool-proof, but depends on inverse_of being set on the
        # relation being validated here.
        def assert_valid_blankness_relation!(name)
          assert_valid_relation!(name)
          relation = relations[name.to_s]

          return unless relation.key?(:inverse_of) && relation.klass.respond_to?(:blankness_relations)

          inverse_relation = relation.klass.relations[relation[:inverse_of].to_s]
          if relation.klass.blankness_relations.include?(inverse_relation.to_s)
            fail ArgumentError,
              %(Circular dependency: inverse relation of "#{name}", #{relation.class_name}.#{inverse_relation} is already `is_present_unless_blank`.")
          end
        end
      end

      def all_relations_blank?
        self.class.blankness_relations.all? { |name| blank_relation?(name) }
      end

      def blank_relation?(name)
        blank_relation_value?(send(name))
      end

      def blank_relation_value?(value)
        if value.is_a?(Array)
          value.all? { |element| blank_relation_value?(element) }
        else
          value.blank?
        end
      end

      protected

      def reject_blank_relations!
        self.class.rejectable_relations.each do |name|
          relation = relations[name.to_s]
          value = send(name)

          case relation.macro
          when :embeds_one, :belongs_to, :has_one
            next if value.nil?
            if blank_relation_value?(value)
              Rails.logger.debug("Blank relation detected: #{name}")
              send(relation.setter, nil)
            end
          when :embeds_many, :has_many, :has_and_belongs_to_many
            next if value == []
            blank_relations = value.select { |element| blank_relation_value?(element) }
            blank_relations.each do |blank|
              Rails.logger.debug("Blank value in relation detected: #{name}")
              value.delete(blank)
            end
          end
        end
      end
    end
  end
end
