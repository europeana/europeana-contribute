# frozen_string_literal: true

##
# Store serialisations of contribution metadata, e.g. RDF/XML
#
# Because on-the-fly generation can be expensive.
class Serialisation
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :contribution, class_name: 'Contribution', inverse_of: :serialisations,
                            index: true

  # @!attribute format
  #   Format of this serialisation, e.g. "rdfxml"
  #   @return [String]
  field :format, type: String

  # @!attribute data
  #   Data for this serialisation, e.g. as RDF/XML
  #   @return [String]
  field :data, type: String

  index(format: 1)

  scope :rdfxml, -> { where(format: 'rdfxml') }

  validates :format, presence: true, inclusion: { in: %w(rdfxml) },
                     uniqueness: { scope: :contribution_id }
  validates :data, presence: true
end
