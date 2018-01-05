# frozen_string_literal: true

##
# Configure the stache gem
#
# @see https://github.com/agoragames/stache

ApplicationController.view_paths = ApplicationController.view_paths.reject do |path|
  path.to_s == Rails.root.join('app', 'views').to_s
end

Stache.configure do |c|
  c.use :mustache
  # Store compiled templates in memory
  # (stache template cache does not work with Redis; see
  # https://github.com/agoragames/stache/issues/58)
  c.template_cache = ActiveSupport::Cache::MemoryStore.new
  c.template_base_class = '::ApplicationPresenter'
  c.template_base_path = ::Rails.root.join('app', 'views')
end
