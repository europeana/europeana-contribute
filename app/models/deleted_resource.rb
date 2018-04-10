# frozen_string_literal: true

##
# Model to store deleted resources.
# These may be used in order to serve '410 Gone' statuses.
class DeletedResource
  include Mongoid::Document

  belongs_to :deleted_by, class_name: 'User', optional: true, inverse_of: :deleted_resources,
                          index: true

  field :resource_type, type: String
  field :resource_uuid, type: String
  field :deleted_at, type: Time

  index(resource_type: 1, resource_uuid: 1)

  scope :web_resources, -> { where(resource_type: 'EDM::WebResource') }

  set_callback :create, :before, :set_deleted_at

  # Update the deleted_at field on the Document to the current time. This is
  # only called on create.
  #
  def set_deleted_at
    unless deleted_at
      time = Time.now.utc
      self.deleted_at = time
    end
  end
end
