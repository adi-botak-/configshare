require_relative './spec_helper'

describe 'Project resource calls' do
	before do
		begin
			Configuration.dataset.destroy
			Project.dataset.destroy
			Account.dataset.destroy
		rescue => e 
			puts "ERROR IN BEGIN: #{e}"
		end
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
end