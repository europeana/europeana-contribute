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
        register_format Europeana::Contribute::OAI::MetadataFormat.instance

        class << self
          def formats
            @formats ||= {}
            @formats.delete('oai_dc')
            @formats
          end
        end

        # Everything that follows is needed solely to override ::OAI::PMH's use
        # of +record.id+ for record identifiers, from
        # +OAI::Provider::Response::RecordResponse#identifier_for+

        # @see OAI::Provider::Base#get_record
        def get_record(options = {})
          Response::GetRecord.new(self.class, options).to_xml
        end

        # @see OAI::Provider::Base#list_identifiers
        def list_identifiers(options = {})
          Response::ListIdentifiers.new(self.class, options).to_xml
        end

        # @see OAI::Provider::Base#list_metadata_formats
        def list_metadata_formats(options = {})
          Response::ListMetadataFormats.new(self.class, options).to_xml
        end

        # @see OAI::Provider::Base#list_records
        def list_records(options = {})
          Response::ListRecords.new(self.class, options).to_xml
        end

        module Response
          module ContributionIdentifiers
            private

            # Override +OAI::Provider::Response::RecordResponse#identifier_for+
            def identifier_for(record)
              "#{provider.prefix}/#{record.edm_providedCHO_uuid}"
            end
          end

          class GetRecord < ::OAI::Provider::Response::GetRecord
            include ContributionIdentifiers
          end

          class ListIdentifiers < ::OAI::Provider::Response::ListIdentifiers
            include ContributionIdentifiers
          end

          class ListMetadataFormats < ::OAI::Provider::Response::ListMetadataFormats
            include ContributionIdentifiers
          end

          class ListRecords < ::OAI::Provider::Response::ListRecords
            include ContributionIdentifiers
          end
        end
      end
    end
  end
end
