require_relative './spec_helper'

describe 'Project resource calls' do
	before do
		Configuration.dataset.destroy
		Project.dataset.destroy
		Account.dataset.destroy
	end

	describe 'Get index of all projects for an account' do
	  before do
	    @my_account = CreateAccount.call(
	    	username: 'adi-botak-',
	    	email: 'adi@nthu.edu.tw',
	    	password: 'adipassword')

	    @other_account = CreateAccount.call(
	    	username: 'lee123',
	    	email: 'lee@nthu.edu.tw',
	    	password: 'leepassword')

	    @my_projs = []
	    3.times do |i|
	    	@my_projs << @my_account.add_owned_project(
	    		name: "Project #{@my_account.id}-#{i}")
	    	@other_account.add_owned_project(
	    		name: "Project #{@other_account.id}-#{i}")
	    end

	    @other_account.owned_projects.each.with_index do |proj, i|
	      @my_projs << @my_account.add_project(proj) if i < 2
	    end
	  end

	  it 'HAPPY: should find all projects for an account' do
	    _, auth_token = AuthenticateAccount.call(
	    	username: 'adi-botak-',
	    	password: 'adipassword')

	    result = get "/api/v1/accounts/#{@my_account.id}/projects", nil, { "HTTP_AUTHORIZATION" => "Bearer #{auth_token}" }
	    _(result.status).must_equal 200
	    projs = JSON.parse(result.body)

	    valid_ids = @my_projs.map(&:id)
	    _(projs[:data].count).must_equal 5
	    projs['data'].each do |proj|
	      _(valid_ids).must_include proj['id']
	    end
	  end
	end

	describe 'Finding existing projects' do
		before do
	    @my_account = CreateAccount.call(
	    	username: 'adi-botak-',
	    	email: 'adi@nthu.edu.tw',
	    	password: 'adipassword')

	    @other_account = CreateAccount.call(
	    	username: 'lee123',
	    	email: 'lee@nthu.edu.tw',
	    	password: 'leepassword')

	    @my_projs = []
	    3.times do |i|
	    	@my_projs << @my_account.add_owned_project(
	    		name: "Project #{@my_account.id}-#{i}")
	    	@other_account.add_owned_project(
	    		name: "Project #{@other_account.id}-#{i}")
	    end

	    @other_account.owned_projects.each.with_index do |proj, i|
	      @my_projs << @my_account.add_project(proj) if i < 2
	    end
	  end

		it 'HAPPY: should find an existing project' do
			new_project = @my_projs.first
			new_configs = (1..3).map do |i|
				new_project.add_configuration(filename: "config_file#{i}.rb")
			end

			get "/api/v1/projects/#{new_project.id}"
			_, auth_token = AuthenticateAccount.call(
				username: 'adi-botak-',
				password: 'adipassword')
			get "api/v1/projects/#{new_project.id}", nil, { "HTTP_AUTHORIZATION" => "Bearer #{auth_token}" }
			_(last_response.status).must_equal 200

			results = JSON.parse(last_response.body)
			_(results['data']['id']).must_equal new_project.id
			3.times do |i|
				_(results['relationships'][i]['id']).must_equal new_configs[i].id
			end
		end

		it 'SAD: should not find non-existent projects' do
			get "/api/v1/projects/#{invalid_id(Project)}"
			_(last_response.status).must_equal 401
		end
	end

	describe 'Add a collaborator to a project' do
		before do
			@owner = CreateAccount.call(
				username: 'adi-botak-',
				email: 'adityautamawijaya@gmail.com',
				password: 'mypassword')
			@collaborator = CreateAccount.call(
				username: 'lee123',
				email: 'lee@nthu.edu.tw',
				password: 'leepassword')
			@project = @owner.add_owned_project(
				name: 'Collaborator needed')
		end

		it 'HAPPY: should add a collaborative project' do
			result = post "/api/v1/projects/#{@project.id}/collaborator/#{@collaborator.id}"
			_(result.status).must_equal 201
			_(@collaborator.projects.map(&:id)).must_include @project.id
		end

		it 'BAD: should not be able to add project owner as collaborator' do
			result = post "/api/v1/projects/#{@project.id}/collaborator/#{@owner.id}"
			_(result.status).must_equal 403
			_(@owner.projects.map(&:id)).wont_include @project.id
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
			post "/api/v1/accounts/#{@account.id}/owned_projects/", req_body, req_header
			_(last_response.status).must_equal 201
			_(last_response.location).must_match(%r{http://})
		end

		it 'SAD: should not create projects with duplicate names' do
			req_header = { 'CONTENT_TYPE' => 'application/json' }
			req_body = { name: 'Demo Project' }.to_json
			2.times do
				post "/api/v1/accounts/#{@account.id}/owned_projects/", req_body, req_header
			end
			_(last_response.status).must_equal 400
			_(last_response.location).must_be_nil
		end

		it 'HAPPY: should encrypt relevant data' do
			original_url = 'http://example.org/project/proj.git'

			proj = CreateProjectForOwner.call(
				owner_id: @account.id,
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
end