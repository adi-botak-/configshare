require_relative './spec_helper'

describe 'Testing Account resource route' do 
	before do
		Configuration.dataset.destroy
		Project.dataset.destroy
		Account.dataset.destroy
	end

	describe 'Creating new account' do
		it 'HAPPY: should create a new unique account' do
			req_header = { 'CONTENT_TYPE' => 'application/json' }
			req_body = { username: 'test.name', password: 'mypass', email: 'test@email.com' }.to_json
			post '/api/v1/accounts/', req_body, req_header
			_(last_response.status).must_equal 201
			_(last_response.location).must_match(%r{http://})
		end

		it 'SAD: should not create accounts with duplicate usernames' do
			req_header = { 'CONTENT_TYPE' => 'application/json' }
			req_body = { username: 'test.name', password: 'mypass', email: 'test@email.com' }.to_json
			post '/api/v1/accounts/', req_body, req_header
			post '/api/v1/accounts/', req_body, req_header
			_(last_response.status).must_equal 400
			_(last_response.location).must_be_nil
		end
	end

	describe 'Testing unit level properties of accounts' do
		before do
			@original_password = 'mypassword'
			@account = CreateAccount.call(
				username: 'adi-botak-',
				email: 'adityautamawijaya@gmail.com',
				password: @original_password)
		end

		it 'HAPPY: should hash the password' do
			_(@account.password_hash).wont_equal @original_password
		end

		it 'HAPPY: should re-salt the password' do
			hashed = @account.password_hash
			@account.password = @original_password
			@account.save
			_(@account.password_hash).wont_equal hashed
		end
	end

	describe 'Finding an existing account' do
		before do
		  	@new_account = CreateAccount.call(
				username: 'test.name',
				email: 'test@email.com',
				password: 'mypassword')
			@new_projects = (1..3).map do |i|
				@new_account.add_owned_project(name: "Project #{i}")
			end

			_, auth_token = AuthenticateAccount.call(
				username: 'test.name',
				password: 'mypassword')
		end

		it 'HAPPY: should find an existing account' do
			get "/api/v1/accounts/#{@new_account.id}", nil, { "HTTP_AUTHORIZATION" => "Bearer #{auth_token}" }
			_(last_response.status).must_equal 200

			results = JSON.parse(last_response.body)
			_(results['data']['id']).must_equal @new_account.id
			3.times do |i|
				_(results['relationships'][i]['id']).must_equal @new_projects[i].id
			end
		end

		it 'SAD: should not return wrong account' do
			get "/api/v1/accounts/#{random_str(10)}", nil, { "HTTP_AUTHORIZATION" => "Bearer #{auth_token}" }
			_(last_response.status).must_equal 401
		end

		it 'SAD: should not return account without authorization' do
			get "/api/v1/accounts/#{@new_account.id}"
			_(last_response.status).must_equal 401
		end
	end

	describe 'Authenticating an account' do
		def login_with(username:, password:)
		  req_header = { 'CONTENT_TYPE' => 'application/json' }
		  req_body = { username: username, password: password }.to_json
		  post '/api/v1/accounts/authenticate', req_body, req_header
		end

		before do
			@account = CreateAccount.call(
				username: 'adi-botak-',
				email: 'adityautamawijaya@gmail.com',
				password: 'mypassword')
		end

		it 'HAPPY: should be able to authenticate a real account' do
			login_with(username: 'adi-botak-', password: 'mypassword')
			_(last_response.status).must_equal 200
			response = JSON.parse(last_response.body)
			_(response['account']).wont_equal nil
			_(response['auth_token']).wont_equal nil
		end

		it 'SAD: should not authenticate an account with wrong password' do
			login_with(username: 'adi-botak-', password: 'notmypassword')
			_(last_response.status).must_equal 401
		end

		it 'SAD: should not authenticate an account with an invalid username' do
			login_with(username: 'randomuser', password: 'mypassword')
			_(last_response.status).must_equal 401
		end

		it 'BAD: should not authenticate an account without password' do
			login_with(username: 'adi-botak', password: '')
			_(last_response.status).must_equal 401
		end
	end
end