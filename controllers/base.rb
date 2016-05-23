require 'sinatra'
require 'json'
require 'rack/ssl-enforcer'

class ShareConfigurationsAPI < Sinatra::Base
	enable :logging

	configure :production do
		use Rack::SslEnforcer
	end

	before do 
		host_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
		@request_url = URI.join(host_url, request.path.to_s)
	end

	get '/?' do
		'api-configshare web service is up and running at /api/v1'
	end

	get '/api/v1/?' do
		# TODO: show all routes as json with links
	end
end