require 'data_mapper'
DataMapper::Model.raise_on_save_failure = true

module Hakuto

  class Paper
    include DataMapper::Resource
    # IDs
    property :id, Serial
    property :doi, String, unique:true
    # ACM
    property :acm_id, String, unique:true
    property :acm_title, Text
    property :acm_year, Integer
    property :acm_abstract, Text
    property :acm_text, Text
    property :acm_object, Object
    property :acm_status, Enum[:doc, :link, :blank, :error]
    # IEEE (not implemented yet)
    property :ieee_id, String, unique:true
    property :ieee_title, Text
    property :ieee_year, Integer
    property :ieee_abstract, Text
    property :ieee_text, Text
    property :ieee_object, Object
    property :ieee_status, Enum[:doc, :link, :blank, :error]
    # relations
    has n, :links, child_key:[:src_id]
    has n, :references, self, through: :links, via: :dst
    def title
      acm_title || ieee_title
    end
    def year
      acm_year || ieee_year
    end
    def abstract
      acm_abstract || ieee_abstract
    end
    def text
      return acm_text  if acm_status  == :link || acm_status  == :blank
      return ieee_text if ieee_status == :link || ieee_status == :blank
      return nil
    end
  end

  class Link
    include DataMapper::Resource
    belongs_to :src, 'Paper', key:true
    belongs_to :dst, 'Paper', key:true
  end

  class Project
    include DataMapper::Resource
    property :id, Serial
    property :name, String, required:true, unique:true
    property :updowns, Object, default:{}
    property :notes, Object, default:{}
  end

end
