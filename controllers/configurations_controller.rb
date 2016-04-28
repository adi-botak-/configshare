class ShareConfigurationsAPI < Sinatra::Base 
	get '/api/v1/projects/:id/configurations/?' do
		content_type 'application/json'

		project = Project[params[:id]]

		JSON.pretty_generate(data: project.configurations)
	end

	get '/api/v1/projects/:project_id/configurations/:id/?' do
		content_type 'application/json'

		begin
			doc_url = URI.join(@request_url.to_s + '/', 'document')
			configuration = Configuration.where(project_id: params[:project_id], id: params[:id]).first
			halt(404, 'Configuration not found') unless configuration
			JSON.pretty_generate( data: {
				                                    configuration: configuration,
				                                    links: { document: doc_url }
				})
		rescue => e 
			status 400
			logger.info "FAILED to process GET configuration request: #{e.inspect}"
			e.inspect
		end
	end

	get '/api/v1/projects/:project_id/configurations/:id/document' do
		content_type 'text/plain'

		begin
			Configuration.where(project_id: params[:project_id], id: params[:id]).first.document
		rescue => e
			status 404
			e.inspect
		end
	end

	post '/api/v1/projects/:project_id/configurations/?' do
		begin
			new_data = JSON.parse(request.body.read)
			project = Project[params[:project_id]]
			saved_config = project.add_configuration(new_data)
		rescue => e
			logger.info "FAILED to create new config: #{e.inspect}"
			halt 400
		end

		status 201
		new_location = URI.join(@request_url.to_s + '/' + saved_config.id.to_s).to_s
		headers('Location' => new_location)
	end
end