require 'bundler'
Bundler.require(:default, :test)
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'hakuto'
DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.auto_upgrade!
