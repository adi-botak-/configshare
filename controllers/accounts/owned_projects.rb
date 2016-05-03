# Sinatra Application Controllers
class ShareConfigurationsAPI < Sinatra::Base
	post '/api/v1/accounts/:username/owned_projects/?' do 
		begin
			new_project_data = JSON.parse(request.body.read)
			account = Account.where(username: params[:username]).first
			saved_project = CreateProjectForOwner.call(
				account: account,
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

	get '/api/v1/accounts/:username/owned_projects/?' do
		content_type 'application/json'

		begin
			account = Account.where(username: params[:username]).first
			owned_projects = account.owned_projects
			JSON.pretty_generate(data: owned_projects)
		rescue => e
			logger.info "FAILED to findprojects for user #{params[:username]}: #{e}"
			halt 404
		end
	end
end