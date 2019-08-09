# frozen_string_literal: true

namespace :db do
  namespace :migrate do
    desc 'Migration to propagate AASM state from contributions to other models. Backup DB before use!'
    task propagate_aasm_state_to_related_models: :environment do
      contributions = client['contributions']
      aggregations = client['ore_aggregations']
      chos = client['edm_provided_chos']
      web_resources = client['edm_web_resources']

      contributions.find.each do |contribution|
        aasm_state = contribution['aasm_state']
        next unless %w(draft published).include?(aasm_state)

        puts "Updating associations for contribution: #{contribution['_id']}"

        aggregation_id = contribution['ore_aggregation_id']
        aggregation = aggregations.find(_id: aggregation_id).first
        aggregations.update_one({ _id: aggregation_id }, { '$set' => { aasm_state: aasm_state } })

        cho_id = aggregation['edm_aggregatedCHO_id']
        cho = chos.find(_id: cho_id).first
        chos.update_one({ _id: cho_id }, { '$set' => { aasm_state: aasm_state } })

        web_resources.find('$or': [{ edm_isShownBy_for_id: aggregation_id }, { edm_hasView_for_id: aggregation_id } ]).each do |web_resource|
          web_resources.update_one({ _id: web_resource['_id'] }, { '$set' => { aasm_state: aasm_state } })
        end
      end
    end

    private

    def client
      @mongo_client ||= begin
        address = Mongoid::Config.clients['default']['hosts'].first
        options = Mongoid::Config.clients['default']['options'] || {}
        options[:database] = Mongoid::Config.clients['default']['database']
        Mongo::Client.new([address], **options.symbolize_keys)
      end
    end
  end
end
