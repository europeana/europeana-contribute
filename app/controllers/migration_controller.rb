# frozen_string_literal: true

class MigrationController < ApplicationController
  layout false

  def index; end

  def new
    @aggregation = new_aggregation
  end

  def create
    @aggregation = new_aggregation
    @aggregation.update(aggregation_params)

    if @aggregation.valid?
      @aggregation.save
      flash[:notice] = 'Thank you for sharing your story!'
      redirect_to action: :index
    else
      # flash.now[:error] = errors
      render action: :new
    end
  end

  private

  def errors
    @aggregation.errors.full_messages +
      @aggregation.edm_aggregatedCHO.errors.full_messages +
      @aggregation.edm_isShownBy.errors.full_messages
  end

  def new_aggregation
    ORE::Aggregation.new(aggregation_defaults).tap do |aggregation|
      aggregation.edm_aggregatedCHO.build_dc_contributor
      aggregation.edm_aggregatedCHO.build_dc_creator
      aggregation.build_edm_isShownBy
    end
  end

  def aggregation_defaults
    {
      edm_provider: 'Europeana Migration',
      edm_dataProvider: 'Europeana Stories'
    }
  end

  def aggregation_params
    params.require(:ore_aggregation).
      permit(:edm_rights,
             edm_aggregatedCHO_attributes: [
               :dc_title, :dc_description, :dc_language, :dc_relation, :dc_type, :dcterms_created, :dcterms_medium, :edm_currentLocation, :edm_type, {
                 dc_contributor_attributes: %i(foaf_mbox foaf_name),
                 dc_creator_attributes: %i(foaf_name rdaGr2_dateOfBirth rdaGr2_dateOfDeath rdaGr2_placeOfBirth rdaGr2_placeOfDeath)
               }
             ],
             edm_isShownBy_attributes: %i(media media_cache))
  end
end
