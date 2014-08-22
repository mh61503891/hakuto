require 'open-uri'

module Hakuto
  module API

    class Adapter
      attr_accessor :keys, :routers, :parsers, :getter
      # raise ArgumentError if the key is undefined
      def route_content(key, id)
        if @routers[key]
          return @routers[key].call(id)
        else
          raise ArgumentError, "Router not found: #{key}"
        end
      end
      # raise OpenURI::HTTPError if an error occurs or a body does not exist
      def get_content(uri)
        @getter ||= lambda { |uri|
          open(uri){ |io| io.read }
        }
        return @getter.call(uri)
      end
      # raise ArgumentError if the @parser not found
      def parse_content(key, content)
        if @parsers[key]
          @parsers[key].call(content)
        else
          raise ArgumentError, "Parser not found: #{key}"
        end
      end
      def get(id)
        paper = {}
        @keys.each do |key|
          uri = route_content(key, id)
          content = get_content(uri)
          object = parse_content(key, content)
          paper.merge! object
        end
        return paper
      end
    end

    class Loader
      attr_accessor :adapter
      def initialize(adapter=nil)
        @adapter = adapter
      end
      def load(id)
        raise NotImplementedError
      end
    end

    class Loaders
      # TODO: auto loading
      def self.load(params)
        if params['acm_id'] && !params['acm_id'].empty?
          require 'hakuto/api/acm'
          return Hakuto::API::ACM::Loader.new(Hakuto::API::ACM::Adapter.new).load(params['acm_id'])
        else
          raise ArgumentError, "#{params} has no ids"
        end

        # if type.nil? || id.nil? || type.empty? || id.empty?
        #   raise ArgumentError, "Arguments cannot be blank: (type:#{type}, id:#{id})"
        # end
        # case type
        # when 'system'
        #   require 'hakuto/api/system'
        #   return Hakuto::API::System::Loader.new(Hakuto::API::System::Adapter.new).load(id)
        # when 'acm'
        #   require 'hakuto/api/acm'
        #   return Hakuto::API::ACM::Loader.new(Hakuto::API::ACM::Adapter.new).load(id)
        # else
        #   raise ArgumentError, "Type must be system or acm: #{type}"
        # end
      end
    end

  end
end
