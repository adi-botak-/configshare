class ShareConfigurationsAPI < Sinatra::Base
	get '/api/v1/projects/?' do
		content_type 'application/json'

		JSON.pretty_generate(data: Project.all)
	end

	get '/api/v1/projects/:id' do
		content_type 'application/json'

		id = params[:id]
		project = Project[id]
		configurations = project ? Project[id].configurations : []

		if project
			JSON.pretty_generate(data: project, relationships: configurations)
		else
			halt 404, "PROJECT NOT FOUND: #{id}"
		end
	end

	post '/api/v1/projects/?' do
		begin
			new_data = JSON.parse(request.body.read)
			saved_project = Project.create(new_data)
		rescue => e 
			logger.info "FAILED to create new project: #{e.inspect}"
			halt 400
		end

		new_location = URI.join(@request_url.to_s + '/', saved_project.id.to_s).to_s

		status 201
		headers('Location' => new_location)
	end
end