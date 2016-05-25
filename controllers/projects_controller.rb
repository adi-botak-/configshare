class ShareConfigurationsAPI < Sinatra::Base
	def affiliated_project(env, project_id)
	  account = authenticated_account(env)
	  all_projects = FindAllAccountProjects.call(username: account['username'])
	  all_projects.select { |proj| proj.id == project_id }.first
	rescue
	  nil
	end

	get '/api/v1/projects/:id' do
		content_type 'application/json'

		project_id = params[:id].to_i
		project = affiliated_project(env, project_id)
		halt(401, 'Not authorized, or project might not exist') unless project
		JSON.pretty_generate(data: project, relationships: project.configurations)
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