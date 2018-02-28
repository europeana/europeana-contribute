# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    role = user&.role

    if role == :admin
      can :manage, :all
    elsif role == :events && user.active?
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
      can :show, Story, &:published?
    end
  end
end
