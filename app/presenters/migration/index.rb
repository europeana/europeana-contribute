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
            url:              '/images/channel_hero_migrations.jpg',
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
            {
              caption: t('preview_1.caption'),
              img_url: '/images/ugc-preview-1.jpg',
              is_person: false,
              text: t('preview_1.text'),
              url: 'javascript:alert("follow link to preview")'
            },
            {
              caption: t('preview_2.caption'),
              img_url: '/images/ugc-preview-2.jpg',
              is_person: false,
              text: t('preview_2.text'),
              url: 'javascript:alert("follow link to preview")'
            },
            {
              button_text: t('preview_3.button_text'),
              caption: t('preview_3.caption'),
              img_url: '/images/ugc-preview-3.jpg',
              is_person: true,
              text: t('preview_3.text'),
              url: 'javascript:alert("follow link to preview")'
            }
          ]
        }
      end
    end

    def include_nav_searchbar
      true
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
