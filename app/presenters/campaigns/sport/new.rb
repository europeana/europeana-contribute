# frozen_string_literal: true

module Campaigns
  module Sport
    class New < ApplicationPresenter
      include FormifiedView
      include HerofiedView

      def page_hero_url
        asset_path('sport-new-hero.jpg')
      end

      def page_content_subheading
        t('contribute.campaigns.sport.pages.new.subtitle')
      end

      def page_content_heading
        t('contribute.campaigns.sport.pages.new.title')
      end
    end
  end
end
