# frozen_string_literal: true

module Europeana
  module Contribute
    module OAI
      # Custom OAI-PMH resumption token class for our own format.
      #
      # Token strings have the format:
      #   %{metadataPrefix}:%{last};set=%{set};from=%{from};until=%{until}
      #
      # +%{metadataPrefix}:%{last}+ is required. All other elements are optional,
      # and un-ordered.
      #
      # +%{last}+ will be a contribution's +#oai_pmh_resumption_token+.
      #
      # @example required parts
      #   "oai_edm:2018-03-08T11:42:51.589+00:00/c1dd9b90-04f3-0136-b4a0-7824afbb2f37"
      # @example required and optional parts
      #   "oai_edm:2018-03-08T11:42:51.589+00:00/c1dd9b90-04f3-0136-b4a0-7824afbb2f37;set=migration;from=2018-03-08T08:37:30Z;until=2018-03-12T08:37:30Z"
      class ResumptionToken < ::OAI::Provider::ResumptionToken
        # Construct a resumption token instance from a token string
        #
        # @param token_string [String] token string from the request
        # @return [Europeana::Contribute::OAI::ResumptionToken] parsed token
        # @raise [OAI::ResumptionTokenException] on invalid optional parameters
        def self.parse(token_string)
          options = {}
          matches = token_string.match(%r{\A([^:]+):([^;]+)(.*)\z})
          options[:metadata_prefix] = matches[1]
          options[:last] = matches[2]

          unless matches[3].blank?
            matches[3].split(';').reject(&:blank?).each do |optional|
              optional_parts = optional.split('=')
              param_name = optional_parts.first
              param_value = optional_parts.last
              fail ::OAI::ResumptionTokenException.new unless %w(set from until).include?(param_name)
              options[param_name.to_sym] = param_value
            end
          end

          new(options)
        end
      end
    end
  end
end
