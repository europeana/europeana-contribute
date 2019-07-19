# frozen_string_literal: true

namespace :db do

  namespace :migrate do

    desc "Migration to update webResource-aggregation relationships, backup DB before use"
    task :update_webResource_aggregation_relationships => :environment do
      address = Mongoid::Config.clients['default']['hosts'].first
      db_name = Mongoid::Config.clients['default']['database']
      client = Mongo::Client.new([ address ], :database => db_name)
      aggregations = client['ore_aggregations']
      web_resources = client['edm_web_resources']

      # Go through each aggregation
      aggregations.find.each do |aggregation|
        puts "updating associations for #{aggregation['_id']}"
        aggregation_id = BSON::ObjectId(aggregation['_id'])

        # Find isShownBys
        web_resources.find({edm_isShownBy_for_id: aggregation_id}).each do |is_shown_by|
          is_shown_by_id = BSON::ObjectId(is_shown_by['_id'])

          # Update the aggregation
          aggregations.update_one({ _id: aggregation_id }, {'$set' => { edm_isShownBy_id: is_shown_by_id } })

          # Update the is_shown_by to remove the aggregation id
          web_resources.update_one({ edm_isShownBy_for_id: aggregation_id }, {'$set' => { edm_isShownBy_for_id: nil } })
          puts 'updated 1 isShownBy relation'
        end

        # Find is hasViews and gather their formatted ids into an array
        has_view_ids = []
        web_resources.find({ edm_hasView_for_id: aggregation_id }).each do |has_view|
          has_view_ids << BSON::ObjectId(has_view['_id'])
        end

        if has_view_ids.count.positive?
          # update the aggregation
          aggregations.update_one({ _id: aggregation_id }, {'$set' => { edm_hasView_ids: has_view_ids } })

          # Update all has_views to remove the aggregation_id
          has_view_update = web_resources.update_many({ edm_hasView_for_id: aggregation_id }, {'$set' => { edm_hasView_for_id: nil } })
          puts "updated #{has_view_update.modified_count} hasView relations"
        end
      end

      # Create an indexes on aggregations
      existing_indexes = aggregations.indexes.map { |index| index[:key].keys.first }
      unless existing_indexes.include?('edm_isShownBy_id')
        aggregations.indexes.create_one({ edm_isShownBy_id: 1 })
        puts 'created index edm_isShownBy_id'
      end
      unless existing_indexes.include?('edm_hasView_for_id')
        aggregations.indexes.create_one({ edm_hasView_for_id: 1 })
        puts 'created index edm_hasView_for_id'
      end

      # Drop the edm_hasView_for_id and edm_isShownBy indexes if they exist.
      web_resources.indexes.each do |index|
        if ['edm_hasView_for_id', 'edm_isShownBy_for_id'].include?(index[:key].keys.first)
          web_resources.indexes.drop_one( index[:name] )
          puts "removed index #{index[:key].keys.first}"
        end
      end
    end
  end
end
