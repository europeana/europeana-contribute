# frozen_string_literal: true

module Europeana
  module Stories
    module OAI
      class Provider < ::OAI::Provider::Base
        # TODO: implement persistent deletion support!
        deletion_support 'persistent'
        record_prefix 'oai:europeana:stories'
        repository_name 'Europeana Stories'
        # TODO: derive this from running env
        repository_url 'https://stories.europeana.eu/oai'
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
