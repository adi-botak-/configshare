require_relative './spec_helper'

describe 'Testing Configuration resource routes' do 
	before do
		Project.dataset.destroy
		Configuration.dataset.destroy
		BaseAccount.dataset.destroy

		@wrong_account = CreateAccount.call(
			username: 'eve',
			email: 'eve@nthu.edu.tw',
			password: 'evepassword')
		_, @eve_token = AuthenticateAccount.call(
			username: 'eve',
			password: 'evepassword')

		@account = CreateAccount.call(
			username: 'adityautamawijaya',
			email: 'adi@nthu.edu.tw',
			password: 'adipassword')

		_, @auth_token = AuthenticateAccount.call(
			username: 'adityautamawijaya',
			password: 'adipassword')
		@project = CreateProjectForOwner.call(
			owner_id: @account.id,
			name: 'Demo Project',
			repo_url: nil)
		@config = CreateConfigurationForProject.call(
			project: @project,
			filename: 'demo_config.rb',
			description: 'Demo Configuration',
			document: 'test file')
		@req_body = {
			filename: 'Test Configuration',
			description: 'config file with variables',
			document: "configl = 'asdf'\nconfig2=asdfjkl"
		}.to_json
		@req_header = {
			'CONTENT_TYPE' => 'application/json',
			'HTTP_AUTHORIZATION' => "Bearer #{@auth_token}"
		}
	end

	describe 'Creating new configurations to projects' do
		it 'HAPPY: should add a new configuration for an existing project' do
			post "/api/v1/projects/#{@project.id}/configurations", @eq_body, @req_header
			_(last_response.status).must_equal 201
			_(JSON.parse(last_response.body)['id']).wont_be_nil
		end

		it 'HAPPY: should encrypt relevant data' do
			original_doc = "---\ntest: 'testing'\ndata: [1, 2, 3]"
			original_desc = 'test description text'

			config = Configuration.new(filename: 'Secret Project')
			config.document = original_doc
			config.description = original_desc
			config.save
			id = config.id 

			_(Configuration[id].document).must_equal original_doc
			_(Configuration[id].document_encrypted).wont_equal original_doc
			_(Configuration[id].description).must_equal original_desc
			_(Configuration[id].description_encrypted).wont_equal original_desc
		end

		it 'SAD: should not add a configuration for non-existent project' do
			post "/api/v1/projects/#{invalid_id(Project)}/configurations", @req_body, @req_header
			_(last_response.status).must_equal 401
			_(last_response.location).must_be_nil
		end

		it 'SAD: should catch duplicate config files within a project' do
			url = "/api/v1/projects/#{@project.id}/configurations"
			post url, @req_body, @req_header
			post url, @req_body, @req_header
			_(last_response.status).must_equal 401
			_(last_response.location).must_be_nil
		end
	end

	describe 'Getting configurations' do
		it 'HAPPY: should find existing configuration' do
			get "/api/v1/projects/#{@project.id}/configurations/#{@config.id}", nil, @req_header
			_(last_response.status).must_equal 200
			parsed_config = JSON.parse(last_response.body)
			_(parsed_config['type']).must_equal 'configuration'
		end

		it 'BAD: should not return configuration with wrong authorization' do
		  header = {
		  	'CONTENT_TYPE' => 'application/json',
		  	'HTTP_AUTHORIZATION' => "Bearer #{@eve_token}"
		  }
		  get "/api/v1/projects/#{@project.id}/configurations/#{@config.id}", nil, header
		  _(last_response.status).must_equal 401
		end

		it 'BAD: should not return configuration with no authorization' do
		  header = { 'CONTENT_TYPE' => 'application/json' }
		  get "/api/v1/projects/#{@project.id}/configurations/#{@config.id}", nil, header
		  _(last_response.status).must_equal 401
		end

		it 'SAD: should not find non-existent project and configuration' do
			proj_id = invalid_id(Project)
			config_id = invalid_id(Configuration)
			get "/api/v1/projects/#{proj_id}/configurations/#{config_id}", nil, @req_header
			_(last_response.status).must_equal 404
		end

		it 'SAD: should not find non-existent configuration for existing project' do
			config_id = invalid_id(Configuration)
			get "/api/v1/projects/#{@project.id}/configurations/#{config_id}", nil, @req_header
			_(last_response.status).must_equal 401
		end
	end
end