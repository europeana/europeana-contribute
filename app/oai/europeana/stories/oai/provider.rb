# frozen_string_literal: true

module Europeana
  module Stories
    module OAI
      class Provider < ::OAI::Provider::Base
        # TODO: derive this from running env
        repository_url 'https://stories.europeana.eu/oai'
        record_prefix 'oai:europeana:stories'
        source_model Europeana::Stories::OAI::Model.new

        class << self
          def formats
            @formats ||= {}
            @formats.delete('oai_dc')
            @formats
          end
        end

        register_format Europeana::Stories::OAI::MetadataFormat.instance
      end
    end
  end
end
