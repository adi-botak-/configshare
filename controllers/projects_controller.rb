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
end