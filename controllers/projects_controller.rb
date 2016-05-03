class ShareConfigurationsAPI < Sinatra::Base
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

	post '/api/v1/projects/:project_id/collaborator/:username' do
		begin
			result = AddCollaboratorForProject.call(
				account: Account.where(username: params[:username]).first,
				project: Project.where(id: params[:project_id]).first)
			status result ? 201 : 403
		rescue => e 
			logger.info "FAILED to add collaborator to project: #{e.inspect}"
			halt 400
		end
	end
end