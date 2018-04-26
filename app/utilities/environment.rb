# frozen_string_literal: true

# Utility class for working with variables from the application environment
class Environment
  # Values an environment variable may take to toggle a feature
  #
  # This may either enable or disable, whichever is not the app's default state.
  FEATURE_TOGGLES = %w(1 on true yes).freeze

  class << self
    # Convenience method for accessing +ENV+
    def variables
      @variables ||= ENV
    end

    # Checks if an environment variable is feature-toggled
    #
    # @param name [String] environment variable name
    def feature_toggled?(name)
      FEATURE_TOGGLES.include?(variables[name])
    end
  end
end
