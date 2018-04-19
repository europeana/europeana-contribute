# frozen_string_literal: true

require 'oai/provider/response/record_response'

module OAI
  module Provider
    module Response
      # Override some too-prescriptive +OAI::Provider::Response::RecordResponse+ methods
      class RecordResponse
        private

        def identifier_for(record)
          "#{provider.prefix}/#{record.oai_pmh_record_id}"
        end

        def deleted?(record)
          !record.published?
        end
      end
    end
  end
end
