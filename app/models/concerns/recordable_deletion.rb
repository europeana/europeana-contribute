# frozen_string_literal: true

# Module to add to models that should record their own deletion in the DeletedResource collection.
# The identifer defaults to the id, but can be specified via the identifies_deleted_resources_by
# @example using Mongo uuids to track deleted resources
#   class Dummy
#     include RecordableDeletion
#     include Mongoid::Uuid
#
#     identifies_deleted_resource_by :uuid
#   end
#
module RecordableDeletion
  extend ActiveSupport::Concern

  included do
    class_attribute :deleted_resource_identifier
    self.deleted_resource_identifier = :id
  end

  class_methods do
    def identifies_deleted_resources_by(attribute)
      self.deleted_resource_identifier = attribute
    end
  end

  def create_deleted_resource
    DeletedResource.create(resource_type: self.class, resource_identifier: send(self.class.deleted_resource_identifier),
                           deleted_by: Current.user)
  end
end
