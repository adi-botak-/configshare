class ShareConfigurationsAPI < Sinatra::Base
	get '/api/v1/accounts/:id' do
		content_type 'application/json'

		id = params[:id]
		halt 401 unless authorized_account?(env, id)
		account = Account.where(id: id).first

		if account
			projects = account.owned_projects
			JSON.pretty_generate(data: account, relationships: projects)
		else
			halt 404, "USER NOT FOUND: #{id}"
		end
	end

	post '/api/v1/accounts/?' do 
		begin
			data = JSON.parse(request.body.read)
			new_account = CreateAccount.call(
				username: data['username'],
				email: data['email'],
				password: data['password'])
		rescue => e 
			logger.info "FAILED to create new account: #{e.inspect}"
			halt 400
		end

		new_location = URI.join(@request_url.to_s + '/', new_account.username).to_s

		status 201
		headers('Location' => new_location)
	end
end