$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'data_mapper'
require 'vcr'

DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.auto_upgrade!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end
