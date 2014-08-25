$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'data_mapper'
require 'hakuto/models'
require 'hakuto/application'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:db/development.db')
DataMapper.auto_upgrade!
options = {
	root:File.dirname(__FILE__),
	logging:true
}

run Hakuto::Application.set(options)
