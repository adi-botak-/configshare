require_relative './spec_helper'

describe 'Testing Account resource route' do 
	before do
		Configuration.dataset.delete
		Project.dataset.delete
		Account.dataset.delete
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
			@account = CreateNewAccount.call(
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

	describe 'Finding existing accounts' do
		it 'HAPPY: should find an existing account' do
			new_account = CreateNewAccount.call(
				username: 'test.name',
				email: 'test@email.com',
				password: 'mypassword')
			new_projects = (1..3).map do |i|
				new_account.add_owned_project(name: "Project #{i}")
			end

			get "/api/v1/accounts/#{new_account.username}"
			_(last_response.status).must_equal 200

			results = JSON.parse(last_response.body)
			_(results['data']['username']).must_equal new_account.username
			3.times do |i|
				_(results['relationships'][i]['id']).must_equal new_projects[i].id
			end
		end

		it 'SAD: should not find non-existent accounts' do
			get "/api/v1/accounts/#{random_str(10)}"
			_(last_response.status).must_equal 404
		end
	end

	describe 'Creating new project for account owner' do
		before do
			@account = CreateNewAccount.call(
				username: 'adi-botak-',
				email: 'adityautamawijaya@gmail.com',
				password: 'mypassword')
		end

		it 'HAPPY: should create a new unique project for account' do
			req_header = { 'CONTENT_TYPE' => 'application/json' }
			req_body = { name: 'Demo Project' }.to_json
			post "/api/v1/accounts/#{@account.username}/projects/", req_body, req_header
			_(last_response.status).must_equal 201
			_(last_response.location).must_match(%r{http://})
		end

		it 'SAD: should not create projects with duplicate names' do
			req_header = { 'CONTENT_TYPE' => 'application/json' }
			req_body = { name: 'Demo Project' }.to_json
			2.times do
				post "/api/v1/accounts/#{@account.username}/projects/", req_body, req_header
			end
			_(last_response.status).must_equal 400
			_(last_response.location).must_be_nil
		end

		it 'HAPPY: should encrypt relevant data' do
			original_url = 'http://example.org/project/proj.git'

			proj = @account.add_owned_project(name: 'Secret Project')
			proj.repo_url = original_url
			proj.save
			id = proj.id

			_(Project[id].repo_url).must_equal original_url
			_(Project[id].repo_url_encrypted).wont_equal original_url
		end
	end
end