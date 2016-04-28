class ShareConfigurationsAPI < Sinatra::Base
	get '/api/v1/accounts/:username' do
		content_type 'application/json'

		username = params[:username]
		account = Account.where(username: username).first

		if account
			projects = account.owned_projects
			JSON.pretty_generate(data: account, relationships: projects)
		else
			halt 404, "USER NOT FOUND: #{username}"
		end
	end

	post '/api/v1/accounts/?' do 
		begin
			data = JSON.parse(request.body.read)
			new_account = Account.new(username: data['username'], email: data['email'])
			new_account.password = data['password']
			new_account.save
		rescue => e 
			logger.info "FAILED to create new account: #{e.inspect}"
			puts "FAILED to create new account: #{e.inspect}"
			halt 400
		end

		new_location = URI.join(@request_url.to_s + '/', new_account.username).to_s

		status 201
		headers('Location' => new_location)
	end
end