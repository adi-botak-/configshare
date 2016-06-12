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
	    new_location = URI.join(@request_url.to_s + '/', saved_project.id.to_s).to_s
	  rescue => e 
	    logger.info "FAILED to create new project: #{e.inspect}"
	    halt 400
	  end

	  status 201
	  { type: 'project', link: new_location, data: saved_project }.to_json
	end

	# get '/api/v1/accounts/:owner_id/owned_projects/?' do
	# 	content_type 'application/json'

	# 	begin
	# 		owner = Account[params[:owner_id]]
	# 		JSON.pretty_generate(data: owner.owned_projects)
	# 	rescue => e
	# 		logger.info "FAILED to findprojects for user #{params[:owner_id]}: #{e}"
	# 		halt 404
	# 	end
	# end
end