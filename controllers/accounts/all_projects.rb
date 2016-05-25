# Sinatra Application Controllers
class ShareConfigurationsAPI < Sinatra::Base
	get '/api/v1/accounts/:username/projects/?' do 
		content_type 'application/json'

		begin
			halt 401 unless authorized_account?(env, params[:username])
			all_projects = FindAllAccountProjects.call(username: params[:username])
			JSON.pretty_generate(data: all_projects)
		rescue => e 
			logger.info "FAILED to find projects for user: #{e}"
			halt 404
		end
	end
end