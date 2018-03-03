# frozen_string_literal: true

module Europeana
  module Contribute
    module OAI
      class MetadataFormat < ::OAI::Provider::Metadata::Format
        def initialize
          @prefix = 'oai_edm'
          @schema = 'http://www.europeana.eu/schemas/edm/EDM.xsd'
          @namespace = "#{Rails.configuration.x.base_url}/oai/oai_edm/"
          @element_namespace = 'edm'
          @fields = %i(updated_at)
        end

        def header_specification
          {
            'xmlns:oai_edm' => @namespace,
            'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
            'xsi:schemaLocation' => @namespace + ' ' + @schema
          }
        end
      end
    end
  end
end
