require_relative './spec_helper'

describe 'Project resource calls' do
	before do
		Project.dataset.delete
		Configuration.dataset.delete
		Account.dataset.delete
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

	describe 'Getting an index of existing projects' do
		it 'HAPPY: should find list of existing projects' do
			(1..5).each { |i| Project.create(name: "Project #{i}") }
			result = get '/api/v1/projects'
			projs = JSON.parse(result.body)
			_(projs['data'].count).must_equal 5
		end
	end
end