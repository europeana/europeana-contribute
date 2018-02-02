# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest users have no privileged access
    return unless user.present?

    case user.role
    when :admin
      can :manage, :all
    when :events
      can :index, ORE::Aggregation
      can :edit, ORE::Aggregation do |aggregation|
        user.event_ids.include?(aggregation.edm_aggregatedCHO.edm_wasPresentAt_id)
      end
      can :read, EDM::Event do |event|
        user.event_ids.include?(event.id)
      end
    end
  end
end
