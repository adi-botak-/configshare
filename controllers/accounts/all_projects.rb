# Sinatra Application Controllers
class ShareConfigurationsAPI < Sinatra::Base
	get '/api/v1/accounts/:id/projects/?' do 
		content_type 'application/json'

		begin
			id = params[:id]
			halt 401 unless authorized_account?(env, id)
			all_projects = FindAllAccountProjects.call(id: id)
			JSON.pretty_generate(type: 'projects', data: all_projects)
		rescue => e 
			logger.info "FAILED to find projects for user: #{e}"
			halt 404
		end
	end
end