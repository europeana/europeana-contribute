# frozen_string_literal: true

module Europeana
  module Contribute
    module OAI
      class Provider < ::OAI::Provider::Base
        # TODO: implement persistent deletion support!
        deletion_support 'persistent'
        record_prefix 'oai:europeana:contribute'
        repository_name 'Europeana Contribute'
        repository_url "#{Rails.configuration.x.base_url}/oai"
        source_model Europeana::Contribute::OAI::Model.new

        class << self
          def formats
            @formats ||= {}
            @formats.delete('oai_dc')
            @formats
          end
        end

        register_format Europeana::Contribute::OAI::MetadataFormat.instance
      end
    end
  end
end
