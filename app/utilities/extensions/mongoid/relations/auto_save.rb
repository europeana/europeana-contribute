# frozen_string_literal: true

require 'mongoid/relations/auto_save'

module Mongoid
  module Relations
    # This extension backports the auto-save cascading fix to Mongoid 6.
    # @see https://github.com/mongodb/mongoid/pull/4415
    #
    # NB: A consequence of this is that relations are always "saved" whether or
    # not they have changes. If they have no changes, then no writes to MongoDB
    # will result, but the save callbacks *will* be triggered.
    module AutoSave
      module ClassMethods
        def autosave(metadata)
          if metadata.autosave? && !metadata.embedded?
            save_method = :"autosave_documents_for_#{metadata.name}"
            define_method(save_method) do
              if before_callback_halted?
                self.before_callback_halted = false
              else
                __autosaving__ do
                  if relation = ivar(metadata.name)
                    if metadata.macro == :belongs_to
                      relation.with(persistence_context, &:save)
                    else
                      Array(relation).each do |doc|
                        doc.with(persistence_context, &:save)
                      end
                    end
                  end
                end
              end
            end

            after_save save_method, unless: :autosaved?
          end
        end
      end
    end
  end
end
