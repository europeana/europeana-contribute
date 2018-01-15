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
      # can what?
    end
  end
end
