# frozen_string_literal: true

# Touch relations when saved or touched
#
# @example
#   class Chapter
#     include Mongoid::Document
#     has_many :pages, class_name: 'Page'
#   end
#
#   class Page
#     include Mongoid::Document
#     field :number, type: Integer
#     field :text, type: String
#     belongs_to :chapter, class_name: 'Chapter'
#     include RelationToucher
#     touches_related :chapter
#   end
#
#   chapter = Chapter.new
#   page = Page.new(number: 1)
#   chapter.pages << page
#   chapter.save
#   page.text = 'Page 1'
#   page.save # touches chapter
module RelationToucher
  extend ActiveSupport::Concern

  included do
    after_save :touch_relations, if: :changed?
    after_touch :touch_relations
  end

  class_methods do
    def relations_to_touch
      @relations_to_touch ||= []
    end

    def touches_related(*relation_names)
      relation_names.each do |relation_name|
        relations_to_touch.push(relation_name)
      end
    end
  end

  def touch_relations
    self.class.relations_to_touch.each do |relation_name|
      send(relation_name)&.touch
    end
  end
end
