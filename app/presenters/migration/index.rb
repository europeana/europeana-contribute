# frozen_string_literal: true

module Migration
  class Index < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          channel_info: {
            name: page_content_heading
          },
          title: page_content_heading,
          hero: {
            url:              asset_path('channel_hero_migrations.jpg'),
            title:            t('hero.title'),
            subtitle:         t('hero.subtitle'),
            attribution_text: t('hero.attribution_text'),
            attribution_url:  'http://www.europeana.eu/portal/record/2048211/449.html',
            license_public:   true
          },
          description: t('description'),
          closing_remark: t('closing_remark'),
          begin_link: {
            url: new_migration_path,
            text: t('begin_link.text'),
            text_long: t('begin_link.text_long')
          },
          call_to_action: call_to_action,
          previews: [
            preview_data(1),
            preview_data(2),
            preview_data(3, {is_person: true, button_text: t('preview_3.button_text')})
          ]
        }
      end
    end

    def preview_data(index, opts = {})
      {
        caption: t("preview_#{index}.caption"),
        img_url: asset_path("ugc-preview-#{index}.jpg"),
        is_person: false,
        text: t("preview_#{index}.text"),
        url: false
      }.merge(opts)
    end

    def include_nav_searchbar
      false
    end

    def call_to_action
      t('call_to_action')
    end

    def page_content_heading
      t('title')
    end

    protected

    def t(*args, **options)
      I18n.t(*args, options.reverse_merge(scope: 'contribute.campaigns.migration.pages.index'))
    end
  end
end
