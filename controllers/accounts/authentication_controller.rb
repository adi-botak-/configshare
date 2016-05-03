class ShareConfigurationsAPI < Sinatra::Base
	get '/api/v1/accounts/:username/authenticate' do
		content_type 'application/json'

		username = params[:username]
		password = params[:password]

		account = FindAndAuthenticateAccount.call(
			username: username,
			password: password)

		if account
			account.to_json
		else
			halt 401, "Account #{username} could not be authenticated"
		end
	end
end