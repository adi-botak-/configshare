# Sinatra Application Controllers
class ShareConfigurationsAPI < Sinatra::Base
	post '/api/v1/accounts/:id/owned_projects/?' do 
		begin
			new_project_data = JSON.parse(request.body.read)
			saved_project = CreateProjectForOwner.call(
				owner_id: params[:id],
				name: new_project_data['name'],
				repo_url: new_project_data['repo_url'])
			new_location = URI.join(@request_url.to_s + '/', saved_project.id.to_s).to_s
		rescue => e 
			logger.info "FAILED to create new project: #{e.inspect}"
			halt 400
		end

		status 201
		headers('Location' => new_location)
	end

	get '/api/v1/accounts/:owner_id/owned_projects/?' do
		content_type 'application/json'

		begin
			owner = Account[params[:owner_id]]
			JSON.pretty_generate(data: owner.owned_projects)
		rescue => e
			logger.info "FAILED to findprojects for user #{params[:owner_id]}: #{e}"
			halt 404
		end
	end
end