class ShareConfigurationsAPI < Sinatra::Base
	def authorized_affiliated_project(env, project_id)
	  account = authenticated_account(env)
	  all_projects = FindAllAccountProjects.call(id: account['id'])
	  all_projects.select { |proj| proj.id == project_id.to_i }.first
	rescue
	  nil
	end

	get '/api/v1/projects/:id' do
		content_type 'application/json'

		project = authorized_affiliated_project(env, params[:id])
		halt(401, 'Not authorized, or project might not exist') unless project
		project.to_full_json
	end

	post '/api/v1/projects/:project_id/collaborator/:collaborator_id' do
	  project = authorized_affiliated_project(env, params[:project_id])
	  halt(401, 'Not authorized, or project might not exist') unless project
	  begin
	    result = AddCollaboratorForProject.call(
	      collaborator_id: params[:collaborator_id],
	      project_id: params[:project_id])
	    status result ? 201 : 403
	  rescue => e 
	    logger.info "FAILED to add collaborator to project: #{e.inspect}"
	    halt 400
	  end
	end
end