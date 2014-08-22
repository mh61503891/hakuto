require 'hakuto/api/acm/adapter'

module Hakuto
  module API
    module ACM
      class Loader < Hakuto::API::Loader

        def merge(paper, acm_obj, acm_status)
          paper.doi          = acm_obj[:doi]      if acm_obj[:doi]
          paper.acm_id       = acm_obj[:id]       if acm_obj[:id]
          paper.acm_title    = acm_obj[:title]    if acm_obj[:title]
          paper.acm_year     = acm_obj[:year]     if acm_obj[:year]
          paper.acm_abstract = acm_obj[:abstract] if acm_obj[:abstract]
          paper.acm_test     = acm_obj[:test]     if acm_obj[:test]
          paper.acm_object   = acm_obj
          paper.acm_status   = acm_status
          return paper
        end

        # TODO: refactor
        def load(id)
          DataMapper::Transaction.new(Paper, Link).commit do
            @paper = Paper.first(acm_id:id) || Paper.new
            if @paper.acm_status == :link || @paper.new?
              @acm_object = @adapter.get(id)
              if !@acm_object.empty?
                merge(@paper, @acm_object, :doc)
                if @acm_object[:references]
                  @acm_object[:references].each do |e|
                    if e[:id]
                      if Paper.count(acm_id:e[:id]).zero?
                        c = Paper.new
                        merge(c, e, :link)
                        @paper.references << c
                      end
                    else
                      c = Paper.new
                      merge(c, e, :blank)
                      @paper.references << c
                    end
                  end
                end
                if @acm_object[:citings]
                  @acm_object[:citings].each do |e|
                    if e[:id]
                      if Paper.count(acm_id:e[:id]).zero?
                        c = Paper.new
                        merge(c, e, :link)
                        c.references << @paper
                        if !c.save
                          require 'pry'
                          binding.pry
                        end
                      end
                    else
                      c = Paper.new
                      merge(c, e, :blank)
                      c.references << @paper
                      if !c.save
                        require 'pry'
                        binding.pry
                      end
                    end
                  end
                end
              end
            end
            if !@paper.save
              require 'pry'
              binding.pry
              raise @paper.errors.to_s
            end



            # return @paper if @paper && @paper.acm_status == :doc
            # return nil if @data.empty?
            # @paper = Paper.new
            # @paper.doi          = @data[:doi]      if @data[:doi]
            # @paper.acm_id       = @data[:id]       if @data[:id]
            # @paper.acm_title    = @data[:title]    if @data[:title]
            # @paper.acm_year     = @data[:year]     if @data[:year]
            # @paper.acm_abstract = @data[:abstract] if @data[:abstract]
            # @paper.acm_test     = @data[:test]     if @data[:test]
            # @paper.acm_object   = @data
            # @paper.acm_status   = :doc
            # if @data[:references]
            #   @data[:references].each do |e|
            #     if e[:id] && Paper.count(acm_id:e[:id]).zero?
            #       reference = Paper.new
            #       reference.doi      = e[:doi]  if e[:doi]
            #       reference.acm_id   = e[:id]   if e[:id]
            #       reference.acm_year = e[:year] if e[:year]
            #       reference.acm_text = e[:text] if e[:text]
            #       reference.acm_status = :link
            #       @paper.references << reference
            #     else
            #       reference = Paper.new
            #       reference.acm_year = e[:year] if e[:year]
            #       reference.acm_text = e[:text] if e[:text]
            #       reference.acm_status = :blank
            #       @paper.references << reference
            #     end
            #   end
            # end
            # if @data[:citings]
            #   @data[:citings].each do |e|
            #     if e[:id] && Paper.count(acm_id:e[:id]).zero?
            #       citing = Paper.new
            #       citing.acm_year = e[:year] if e[:year]
            #       citing.acm_text = e[:text] if e[:text]
            #       citing.acm_status = :link
            #       citing.references << @paper
            #       citing.save
            #     else
            #       citing = Paper.new
            #       citing.acm_year = e[:year] if e[:year]
            #       citing.acm_text = e[:text] if e[:text]
            #       citing.acm_status = :blank
            #       citing.references << @paper
            #       citing.save
            #     end
            #   end
            # end
          end
          Paper.first(acm_id:id)
        end

      end
    end
  end
end
