# frozen_string_literal: true

module Europeana
  module Contribute
    module OAI
      module Provider
        class Base < ::OAI::Provider::Base
          admin_email 'development@europeana.eu'
          deletion_support ::OAI::Const::Delete::PERSISTENT
          record_prefix 'oai:europeana:contribute'
          repository_name 'Europeana Contribute'
          repository_url "#{Rails.configuration.x.base_url}/oai"
          sample_id '11305a60-04f7-0136-b4a4-7824afbb2f37'

          register_format Europeana::Contribute::OAI::Provider::Metadata::Format.instance
          source_model Europeana::Contribute::OAI::Provider::Model.new

          class << self
            def formats
              @formats ||= {}
              @formats.without('oai_dc')
            end
          end

          # +OAI::Provider::Response::Identify#to_xml+ hard-codes ":" as separator
          # in +sampleIdentifier+, despite +OAI::Provider::Response::RecordResponse#identifier_for+
          # using "/". Compensate for that here.
          def identify(options = {})
            super.sub("<sampleIdentifier>#{self.class.prefix}:", "<sampleIdentifier>#{self.class.prefix}/")
          end
        end
      end
    end
  end
end
