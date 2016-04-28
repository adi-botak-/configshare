class ShareConfigurationsAPI < Sinatra::Base
	post '/api/v1/accounts/?' do 
		begin
			new_data = JSON.parse(request.body.read)
			new_account = Account.create(new_data)
		rescue => e 
			logger.info "FAILED to create new account: #{e.inspect}"
			halt 400
		end

		new_location = URI.join(@request_url.to_s + '/', new_account.username).to_s

		status 201
		headers('Location' => new_location)
	end
end