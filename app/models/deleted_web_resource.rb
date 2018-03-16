# frozen_string_literal: true

##
# Model to go with the list of deleted webResources.
# These uuids are maintained in order to serve '410 Gone' statuses for removed media.
class DeletedWebResource
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uuid, type: String

  index(uuid: 1)
end