# frozen_string_literal: true

module Campaigns
  module Migration
    class New < ApplicationPresenter
      include FormifiedView
      include HerofiedView

      def page_hero_url
        asset_path('migration-new-hero.jpg')
      end

      def page_content_subheading
        t('contribute.campaigns.migration.pages.new.subtitle')
      end

      def page_content_heading
        t('contribute.campaigns.migration.pages.new.title')
      end
    end
  end
end
