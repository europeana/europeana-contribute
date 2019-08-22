# frozen_string_literal: true

module CurrentUserHelper
  private

  def current_user_ability
    @current_user_ability ||= Ability.new(current_user)
  end

  def current_user_can?(*args)
    current_user_ability.can?(*args)
  end

  def set_current_user
    Current.user = current_user
    yield
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver,
    # see https://stackoverflow.com/a/8291218/738371
    Current.user = nil
  end
end
