# Owned Projects Controllers
class ShareConfigurationsAPI < Sinatra::Base
	post '/api/v1/accounts/:owner_id/projects/?' do 
	  content_type 'application/json'

	  begin
	    halt 401 unless authorized_account?(env, params[:owner_id])

	    new_project_data = JSON.parse(request.body.read)
	    saved_project = CreateProjectForOwner.call(
	      owner_id: params[:owner_id],
	      name: new_project_data['name'],
	      repo_url: new_project_data['repo_url'])

	  rescue => e 
	    logger.info "FAILED to create new project: #{e.inspect}"
	    halt 400
	  end

	  status 201
	  saved_project.to_json
	end
end