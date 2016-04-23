require 'json'
require 'sequel'

# Holds a Project's information
class Project < Sequel::Model
	set_allowed_columns :name, :repo_url
	
	one_to_many :configurations
	plugin :association_dependencies, :configurations => :delete

	def to_json(options = {})
		JSON({ type: 'project',
			         id: id,
			         attributes: {
			         	  name: name,
			         	  repo_url: repo_url
			         }
			},
			options)
	end
end