require 'hakuto/models'

module Hakuto
  module API
    module ACM
      class Loader
        class << self

          def load(id)
            paper = Paper.first(acm_id:id, acm_status: :doc)
            return paper if paper
            parent_ids = []
            child_ids = []
            acm_object = Reader.read(id)
            my_id = insert(acm_object, :doc).id
            acm_object[:references].to_a.each do |o|
              parent_id = insert(o, :link).id
              parent_ids << parent_id
            end
            acm_object[:citings].to_a.each do |o|
              child_id = insert(o, :link).id
              child_ids << child_id
            end
            parent_ids.uniq.each do |parent_id|
              Link.first_or_create(src_id:my_id, dst_id:parent_id)
            end
            child_ids.uniq.each do |child_id|
              Link.first_or_create(src_id:child_id, dst_id:my_id)
            end
            return Paper.first(acm_id:id)
          end

          def insert(acm_object, acm_status)
            paper = get(acm_object)
            if paper.new? || (paper.acm_status == :link && acm_status == :doc)
              paper.doi          = acm_object[:doi]      if acm_object[:doi]
              paper.acm_id       = acm_object[:id]       if acm_object[:id]
              paper.acm_title    = acm_object[:title]    if acm_object[:title]
              paper.acm_year     = acm_object[:year]     if acm_object[:year]
              paper.acm_abstract = acm_object[:abstract] if acm_object[:abstract]
              paper.acm_text     = acm_object[:text]     if acm_object[:text]
              paper.acm_object   = acm_object
              paper.acm_status   = acm_status
              paper.save
            end
            return paper
          end

          def get(object)
            if object[:id]
              return Paper.first(acm_id:object[:id]) || Paper.new
            end
            if object[:text]
              return Paper.first(acm_text:object[:text]) || Paper.new
            end
            raise "Object must have a key of :id or :text (#{object})"
          end

        end
      end
    end
  end
end
