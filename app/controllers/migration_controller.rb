# frozen_string_literal: true

class MigrationController < ApplicationController
  layout false

  def index; end

  def new
    @story = new_story
    build_story_associations_unless_present(@story)
  end

  def create
    @story = new_story
    @story.assign_attributes(story_params)
    annotate_dcterms_spatial_places(@story)

    if [validate_humanity, @story.valid?].all?
      @story.save
      flash[:notice] = 'Thank you for sharing your story!'
      redirect_to action: :index, c: 'eu-migration'
    else
      build_story_associations_unless_present(@story)
      # flash.now[:error] = errors
      render action: :new, status: 400
    end
  end

  def edit
    @story = Story.find(params[:id])
    authorize! :edit, @story

    build_story_associations_unless_present(@story)
    render action: :new
  end

  def update
    @story = Story.find(params[:id])
    authorize! :edit, @story

    @story.assign_attributes(story_params)
    annotate_dcterms_spatial_places(@story)

    if @story.valid?
      @story.save
      flash[:notice] = 'Story saved.'
      redirect_to controller: :stories, action: :index, c: 'eu-migration'
    else
      build_story_associations_unless_present(@story)
      render action: :new, status: 400
    end
  end

  private

  def errors
    [@story, @story.ore_aggregation, @story.ore_aggregation.edm_aggregatedCHO,
     @story.ore_aggregation.edm_isShownBy].map do |object|
      object.errors.full_messages
    end.flatten
  end

  def new_story
    Story.new(story_defaults)
  end

  def build_story_associations_unless_present(story)
    story.ore_aggregation.edm_aggregatedCHO.build_dc_contributor unless story.ore_aggregation.edm_aggregatedCHO.dc_contributor.present?
    story.ore_aggregation.edm_aggregatedCHO.dc_subject_agents.build unless story.ore_aggregation.edm_aggregatedCHO.dc_subject_agents.present?
    story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.build while story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.size < 2
    story.ore_aggregation.build_edm_isShownBy unless story.ore_aggregation.edm_isShownBy.present?
    story.ore_aggregation.edm_isShownBy.build_dc_creator unless story.ore_aggregation.edm_isShownBy.dc_creator.present?
  end

  def story_defaults
    {
      created_by: current_user,
      ore_aggregation_attributes: {
        edm_provider: 'Europeana Migration',
        edm_dataProvider: 'Europeana Stories',
        edm_rights: CC::License.find_by(rdf_about: 'http://creativecommons.org/licenses/by-sa/4.0/'),
        edm_aggregatedCHO_attributes: {
          dc_language: I18n.locale.to_s
        }
      }
    }
  end

  def annotate_dcterms_spatial_places(story)
    first = story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.first
    unless first.nil? || first.blank_attributes?
      first.skos_note = 'Where the migration began'
    end
    last = story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.last
    unless last.nil? || last.blank_attributes?
      last.skos_note = 'Where the migration ended'
    end
  end

  def story_params
    params.require(:story).
      permit(ore_aggregation_attributes: {
               edm_aggregatedCHO_attributes: [
                 :dc_identifier, :dc_title, :dc_description, :dc_language, :dc_subject,
                 :dc_subject_autocomplete, :dc_type, :dcterms_created, :edm_wasPresentAt_id, {
                   dc_contributor_attributes: %i(foaf_mbox foaf_name skos_prefLabel),
                   dc_subject_agents_attributes: [%i(id _destroy foaf_name rdaGr2_dateOfBirth rdaGr2_dateOfDeath rdaGr2_placeOfBirth
                                                     rdaGr2_placeOfBirth_autocomplete rdaGr2_placeOfDeath rdaGr2_placeOfDeath_autocomplete)],
                   dcterms_spatial_places_attributes: [%i(id owl_sameAs owl_sameAs_autocomplete)]
                 }
               ],
               edm_isShownBy_attributes: [:dc_description, :dc_type, :dcterms_created, :media, :media_cache, :remove_media, {
                 dc_creator_attributes: [:foaf_name]
               }],
               edm_hasViews_attributes: [[:id, :_destroy, :dc_description, :dc_type, :dcterms_created, :media, :media_cache, :remove_media, {
                 dc_creator_attributes: [:foaf_name]
               }]]
             })
  end

  def validate_humanity
    if current_user
      true
    else
      verify_recaptcha(model: @story)
    end
  end
end
