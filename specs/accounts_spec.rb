require_relative './spec_helper'

describe 'Testing Project resource route' do 
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
			post '/api/v1/projects/', req_body, req_header
			post '/api/v1/projects/', req_body, req_header
			_(last_response.status).must_equal 400
			_(last_response.location).must_be_nil
		end

		it 'HAPPY: should hash the password' do
			original_password = 'mypassword'

			account = Account.new(username: 'test.name', email: 'test@email.com')
			account.password = original_password
			account.save

			_(Account[account.id].password_hash).wont_equal original_password
		end

		it 'HAPPY: should re-salt the password' do
			original_password = 'mypassword'

			account = Account.new(username: 'test.name', email: 'test@email.com')
			account.password = original_password
			account.save
			hashed = account.password_hash
			account.password = original_password
			account.save
			_(Account[account.id].password_hash).wont_equal hashed
		end
	end

	describe 'Finding existing accounts' do
		it 'HAPPY: should find an existing account' do
			new_account = Account.new(username: 'test.name', email: 'test@email.com')
			new_account.password = 'mypassword'
			new_account.save
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
end