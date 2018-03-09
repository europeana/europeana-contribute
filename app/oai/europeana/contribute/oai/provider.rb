# frozen_string_literal: true

module Europeana
  module Contribute
    module OAI
      class Provider < ::OAI::Provider::Base
        admin_email 'development@europeana.eu'
        # TODO: implement persistent deletion support
        deletion_support ::OAI::Const::Delete::PERSISTENT
        record_prefix 'oai:europeana:contribute'
        repository_name 'Europeana Contribute'
        repository_url "#{Rails.configuration.x.base_url}/oai"

        register_format Europeana::Contribute::OAI::MetadataFormat.instance
        source_model Europeana::Contribute::OAI::Model.new

        class << self
          def formats
            @formats ||= {}
            @formats.without('oai_dc')
          end
        end
      end
    end
  end
end
