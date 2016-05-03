require_relative './spec_helper'

describe 'Project resource calls' do
	before do
		Configuration.dataset.destroy
		Project.dataset.destroy
		Account.dataset.destroy
	end

	describe 'Finding existing projects' do
		it 'HAPPY: should find an existing project' do
			new_project = Project.create(name: 'demo project')
			new_configs = (1..3).map do |i|
				new_project.add_configuration(filename: "config_file#{i}.rb")
			end

			get "/api/v1/projects/#{new_project.id}"
			_(last_response.status).must_equal 200

			results = JSON.parse(last_response.body)
			_(results['data']['id']).must_equal new_project.id
			3.times do |i|
				_(results['relationships'][i]['id']).must_equal new_configs[i].id
			end
		end

		it 'SAD: should not find non-existent projects' do
			get "/api/v1/projects/#{invalid_id(Project)}"
			_(last_response.status).must_equal 404
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
			result = post "/api/v1/projects/#{@project.id}/collaborator/#{@collaborator.username}"
			_(result.status).must_equal 201
			_(@collaborator.projects.map(&:id)).must_include @project.id
		end

		it 'SAD: should not be able to add project owner as collaborator' do
			result = post "/api/v1/projects/#{@project.id}/collaborator/#{@owner.username}"
			_(result.status).must_equal 403
			_(@owner.projects.map(&:id)).wont_include @project.id
		end
	end
end