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
	end
end