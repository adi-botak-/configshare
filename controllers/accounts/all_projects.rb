# Sinatra Application Controllers
class ShareConfigurationsAPI < Sinatra::Base
	get '/api/v1/accounts/:username/projects/?' do 
		content_type 'application/json'

		begin
			account = Account.where(username: params[:username]).first
			all_projects = FindAllAccountProjects.call(account)
			JSON.pretty_generate(data: all_projects)
		rescue => e 
			logger.info "FAILED to find projects for user #{params[:username]}: #{e}"
			halt 404
		end
	end
end