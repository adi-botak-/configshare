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
		it 'HAPPY: should find an existing account' do
			new_account = CreateAccount.call(
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

	describe 'Creating new owned project for account owner' do
		before do
			@account = CreateAccount.call(
				username: 'adi-botak-',
				email: 'adityautamawijaya@gmail.com',
				password: 'mypassword')
		end

		it 'HAPPY: should create a new owned project for account' do
			req_header = { 'CONTENT_TYPE' => 'application/json' }
			req_body = { name: 'Demo Project' }.to_json
			post "/api/v1/accounts/#{@account.username}/owned_projects/", req_body, req_header
			_(last_response.status).must_equal 201
			_(last_response.location).must_match(%r{http://})
		end

		it 'SAD: should not create projects with duplicate names' do
			req_header = { 'CONTENT_TYPE' => 'application/json' }
			req_body = { name: 'Demo Project' }.to_json
			2.times do
				post "/api/v1/accounts/#{@account.username}/owned_projects/", req_body, req_header
			end
			_(last_response.status).must_equal 400
			_(last_response.location).must_be_nil
		end

		it 'HAPPY: should encrypt relevant data' do
			original_url = 'http://example.org/project/proj.git'

			proj = CreateProjectForOwner.call(
				account: @account,
				name: 'Secret Project',
				repo_url: original_url)
			
			original_desc = 'Secret file with database key'
			original_doc = 'key: 123456789'
			conf = proj.add_configuration(filename: 'test_file.txt')
			conf.description = original_desc
			conf.document = original_doc
			conf.save

			_(Project[proj.id].repo_url).must_equal original_url
			_(Project[proj.id].repo_url_encrypted).wont_equal original_url

			_(Configuration[conf.id].description).must_equal original_desc
			_(Configuration[conf.id].description_encrypted).wont_equal original_desc

			_(Configuration[conf.id].document).must_equal original_doc
			_(Configuration[conf.id].document_encrypted).wont_equal original_doc
		end
	end

	describe 'Authenticating an account' do
		before do
			@account = CreateAccount.call(
				username: 'adi-botak-',
				email: 'adityautamawijaya@gmail.com',
				password: 'mypassword')
		end

		it 'HAPPY: should be able to authenticate a real account' do
			get '/api/v1/accounts/adi-botak-/authenticate?password=mypassword'
			_(last_response.status).must_equal 200
		end

		it 'SAD: should not authenticate an account with a bad password' do
			get '/api/v1/accounts/adi-botak-/authenticate?password=guesspassword'
			_(last_response.status).must_equal 401
		end

		it 'SAD: should not authenticate an account with an invalid username' do
			get '/api/v1/accounts/randomuser/authenticate?password=mypassword'
			_(last_response.status).must_equal 401
		end

		it 'SAD: should not authenticate an account with password' do
			get '/api/v1/accounts/adi-botak-/authenticate'
			_(last_response.status).must_equal 401
		end
	end

	describe 'Get index of all projects for an account' do
		it 'HAPPY: should find all projects for an account' do
			my_account = CreateAccount.call(
				username: 'adi-botak-',
				email: 'adityautamawijaya@gmail.com',
				password: 'mypassword')

			other_account = CreateAccount.call(
				username: 'lee123',
				email: 'lee@nthu.edu.tw',
				password: 'leepassword')

			my_projs = []
			3.times do |i|
				my_projs << my_account.add_owned_project(
					name: "Project #{my_account.id}-#{i}")
				other_account.add_owned_project(
					name: "Project #{other_account.id}-#{i}")
			end

			other_account.owned_projects.each.with_index do |proj, i|
				my_projs << my_account.add_project(proj) if i < 2
			end

			result = get "/api/v1/accounts/#{my_account.username}/projects"
			_(result.status).must_equal 200
			projs = JSON.parse(result.body)

			valid_ids = my_projs.map(&:id)
			_(projs['data'].count).must_equal 5
			projs['data'].each do |proj|
				_(valid_ids).must_include proj['id']
			end
		end
	end
end