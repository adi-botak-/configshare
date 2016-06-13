class ShareConfigurationsAPI < Sinatra::Base 
	def authorized_configuration(env, project_id, config_id)
	  project = authorized_affiliated_project(env, params[:project_id])
	  Configuration.first(project_id: project.id, id: params[:config_id])
	end

	get '/api/v1/projects/:project_id/configurations/:config_id/?' do
		content_type 'application/json'

		begin
		  configuration = authorized_configuration(env, params[:project_id], params[:config_id])
		  raise 'Configuration not found' unless configuration
		  configuration.to_full_json
		rescue => e 
		  status 401
		  logger.info "FAILED to process GET configuration request: #{e.inspect}"
		end
	end

	post '/api/v1/projects/:project_id/configurations/?' do
	  content_type 'application/json'
	  project = authorized_affiliated_project(env, params[:project_id])

	  begin
	    config_data = JSON.parse(request.body.read)
	    project = Project[params[:project_id]]
	    saved_config = CreateConfigurationForProject.call(
	      project: project,
	      filename: config_data['filename'],
	      description: config_data['description'],
	      document: config_data['document'])
	  rescue => e
	    logger.error "FAILED to create new config: #{e.inspect}"
	    halt(401, 'Not authorized, or problem with configuration')
	  end

	  status 201
	  saved_config.to_json
	end
end