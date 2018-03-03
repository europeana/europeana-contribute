# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    role = user&.role

    if role == :admin
      can :manage, :all
    elsif role == :events && user.active?
      can :index, Contribution
      can :show, Contribution
      can :save_draft, Contribution
      can :edit, Contribution do |contribution|
        user.event_ids.include?(contribution.ore_aggregation.edm_aggregatedCHO.edm_wasPresentAt_id)
      end
      can :read, EDM::Event do |event|
        user.event_ids.include?(event.id)
      end
    else
      can :show, Contribution, &:published?
    end
  end
end
