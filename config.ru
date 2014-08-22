require 'bundler'
Bundler.require
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'hakuto'


# if ENV['RACK_ENV'] == 'development'
#   require 'sinatra/reloader'
#   require 'dm-sqlite-adapter'
# end


# if ENV['RACK_ENV'] == 'development'
# 	require 'sinatra/reloader'
# 	Sinatra.register(Sinatra::Reloader)
# 	p 'deve'
# 	# use Rack::Reloader
# 	# use Sinatra::Reloader
# 	#   require 'dm-sqlite-adapter'
# end


DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:db/development.db')
DataMapper.auto_upgrade!
options = {
	root:File.dirname(__FILE__),
	logging:true
}


# class Hakuto::Application
# 	configure :development do
# 		p 'cccccc'
# 		register Sinatra::Reloader
# 	end
# end

run Hakuto::Application.set(options)
