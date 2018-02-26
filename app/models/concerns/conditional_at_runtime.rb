# frozen_string_literal: true

# ActiveSupport::Callbacks-like runtime condition checking on :if and :unless
# options.
#
# TODO: use ActiveSupport::Callbacks for the :if/:unless logic?
module ConditionalAtRuntime
  extend ActiveSupport::Concern

  def _options_permit_execution?(**options)
    if options.key?(:if)
      return false unless _evaluate_runtime_condition(options[:if])
    end
    if options.key?(:unless)
      return false if _evaluate_runtime_condition(options[:unless])
    end
    true
  end

  def _evaluate_runtime_condition(proc_or_symbol)
    case proc_or_symbol
    when Symbol
      send(proc_or_symbol)
    when Proc
      call(proc_or_symbol)
    else
      fail "Unknown runtime condition: #{proc_or_symbol.inspect}"
    end
  end
end
