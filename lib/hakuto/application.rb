require 'sinatra/base'
require 'sinatra/json'
require 'sass'
require 'hakuto/api'

module Hakuto
  class Application < Sinatra::Base

    configure :development do
      register Sinatra::Reloader
    end

    get '/lib/hakuto/index.css' do
      scss :"style/index"
    end

    get '/' do
      send_file File.join(settings.public_folder, 'index.html')
    end

    get '/paper.json' do
      begin
        @paper = Hakuto::API::Loaders.load(params)
        response = {
          id:@paper.id,
          doi:@paper.doi,
          acm_id:@paper.acm_id,
          title:@paper.title,
          year:@paper.year,
          abstract:@paper.abstract,
          text:@paper.text,
          references:Link.all(src_id:@paper.id).map { |link|
            e = link.dst
            {
              id:e.id,
              doi:e.doi,
              acm_id:e.acm_id,
              year:e.year,
            }
          },
          citings:Link.all(dst_id:@paper.id).map { |link|
            e = link.src
            {
              id:e.id,
              doi:e.doi,
              acm_id:e.acm_id,
              year:e.year,
            }
          }
        }
        json response
      rescue => e
        logger.error(e)
        status 403
        response = {errors:[{message: e.message}]}
        json response
      end
    end

  end
end
