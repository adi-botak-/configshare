require  'sinatra'
require 'json'
require 'base64'
require_relative 'models/configuration'

# Configuration Sharing Web Service
class ShareConfigurationsApp < Sinatra::Base 
	before do
		Configuration.setup
	end

	get '/?' do 
		'ConfigShare web service is up and running at /api/v1'
	end

	get '/api/v1/?' do
		#TODO: show all routes as json with links
	end

	get '/api/v1/configurations/?' do
		content_type 'application/json'
		id_list = Configuration.all

		{ configuration_id: id_list }.to_json
	end

	get '/api/v1/configurations/:id/document' do
		content_type 'text/plain'

		begin
			Base64.strict_decode64 Configuration.find(params[:id]).document
		rescue => e 
			status 404
			e.inspect
		end
	end

	get '/api/v1/configurations/:id.json' do
		content_type 'application/json'

		begin
			{ configuration: Configuration.find(params[:id]) }.to_json
		rescue => e
			status 404
			e.inspect
		end
	end

	post '/api/v1/configurations/?' do
		content_type 'application/json'

		begin
			new_data = JSON.parse(request.body.read)
			new_config = Configuration.new(new_data)
			new_config.save
			loggir.info "NEW CONFIGURATION STORED: #{new_config.id}"

			redirect '/api/v1/configurations/' + new_config.id + '.txt'
		rescue => e
			status 400
			puts e.inspect
		end
	end
end