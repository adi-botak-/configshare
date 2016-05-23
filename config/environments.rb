require 'sinatra'

configure :development do
	ENV['DATABASE_URL'] = 'sqlite://db/dev.db'
end

configure :test do
	ENV['DATABASE_URL'] = 'sqlite://db/test.db'
end

configure :development, :test do
	require 'config_env'
	ConfigEnv.path_to_config("#{__dir__}/config_env.rb")
end

configure :production do
	# ENV['DATABASE_URL'] should be set by Heroku
	# Configuration settings should be directly set on Heroku
end

configure do
	require 'sequel'
	DB = Sequel.connect(ENV['DATABASE_URL'])

	require 'hirb'
	Hirb.enable
end