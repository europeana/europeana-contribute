# frozen_string_literal: true

module Blankness
  module Mongoid
    # Detect and reject blank attributes in Mongoid documents
    module Attributes
      extend ActiveSupport::Concern
      include Blankness::Attributes

      def blank_attribute?(name)
        super(name.to_s)
      end

      def ignore_attribute_presence?(name)
        mongoid_relation_attribute?(name) ||
          mongoid_internal_attribute?(name) ||
          mongoid_timestamp_attribute?(name)
      end

      def rejectable_attribute?(name)
        !mongoid_relation_attribute?(name) &&
          !mongoid_internal_attribute?(name) &&
          !mongoid_timestamp_attribute?(name)
      end

      def mongoid_relation_attribute?(name)
        relations.values.map(&:key).include?(name)
      end

      def mongoid_internal_attribute?(name)
        name.start_with?('_')
      end

      def mongoid_timestamp_attribute?(name)
        %w(created_at updated_at).include?(name)
      end
    end
  end
end
