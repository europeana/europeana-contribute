# frozen_string_literal: true

module FormifiedView
  extend ActiveSupport::Concern

  def form
    @view.render partial: 'generic/form'
  end

  protected

  def errors
    return '' unless flash[:error].present?
    flash[:error].join('<br>')
  end
end

