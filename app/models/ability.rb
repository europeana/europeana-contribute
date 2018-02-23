# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role == :admin
      can :manage, :all
    elsif user.role == :events && user.active?
      can :index, Story
      can :show, Story
      can :save_draft, Story
      can :edit, Story do |story|
        user.event_ids.include?(story.ore_aggregation.edm_aggregatedCHO.edm_wasPresentAt_id)
      end
      can :read, EDM::Event do |event|
        user.event_ids.include?(event.id)
      end
    else
      can :show, Story do |story|
        story.published?
      end
    end
  end
end
