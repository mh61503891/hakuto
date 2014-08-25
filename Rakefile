require 'rspec/core/rake_task'

task default:'spec'

desc 'Run Rackup'
task 'rackup' do
	sh 'rackup'
end

desc 'Upgrade Database'
task 'db:upgrade' do
	$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
	require 'hakuto/models'
	DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:db/development.db')
	DataMapper.auto_upgrade!
end

RSpec::Core::RakeTask.new(:spec) do |t|
	t.rspec_opts = ['--color', '--format documentation']
	# t.rspec_opts = ['--color']
end
