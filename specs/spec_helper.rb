ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

include Rack::Test::Methods

def app
	ShareConfigurationsAPI
end

def invalid_id(resource)
	case [resource]
	when [Project]
		(resource.max(:id) || 0) + 1
	when [Configuration]
		SecureRandom.uuid
	else
		raise "INVALID_ID: unknown primary key for #{resource}"
	end
end