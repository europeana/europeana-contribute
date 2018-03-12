# frozen_string_literal: true

module Europeana
  module Contribute
    module OAI
      module Provider
        module Metadata
          class Format < ::OAI::Provider::Metadata::Format
            def initialize
              @prefix = 'oai_edm'
              @schema = 'http://www.europeana.eu/schemas/edm/EDM.xsd'
              @namespace = "#{Rails.configuration.x.base_url}/oai/oai_edm/"
              @element_namespace = 'edm'
              @fields = []
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
  end
end
