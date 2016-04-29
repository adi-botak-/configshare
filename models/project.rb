require 'json'
require 'sequel'

# Holds a Project's information
class Project < Sequel::Model
	include SecureModel

	plugin :timestamps, update_on_create: true
	set_allowed_columns :name
	one_to_many :configurations
	many_to_one :owner, class: :Account
	many_to_many :contributors, class: :Account, join_table: :accounts_projects, left_key: :project_id, right_key: :contributor_id
	plugin :association_dependencies, configurations: :destroy

	def before_destroy
		DB[:accounts_projects].where(project_id: id).delete
		super
	end

	def repo_url
		decrypt(repo_url_encrypted)
	end

	def repo_url=(repo_url_plaintext)
		self.repo_url_encrypted = encrypt(repo_url_plaintext) if repo_url_plaintext
	end

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