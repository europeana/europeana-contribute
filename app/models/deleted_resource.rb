# frozen_string_literal: true

##
# Model to store a record of deleted resources.
# These may be used in order to serve '410 Gone' statuses.
class DeletedResource
  include Mongoid::Document

  belongs_to :deleted_by, class_name: 'User', optional: true, inverse_of: :deleted_resources,
                          index: true

  field :resource_type, type: String
  field :resource_identifier, type: String
  field :deleted_at, type: DateTime

  index(resource_type: 1, resource_identifier: 1)

  scope :web_resources, -> { where(resource_type: 'EDM::WebResource') }
  scope :contributions, -> { where(resource_type: 'Contribution') }

  set_callback :create, :before, :set_deleted_at

  # Update the deleted_at field on the Document to the current time. This is
  # only called on create.
  #
  def set_deleted_at
    unless deleted_at
      self.deleted_at = Time.now.utc
    end
  end
end
