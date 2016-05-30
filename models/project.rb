require 'json'
require 'sequel'

# Holds a Project's information
class Project < Sequel::Model
	plugin :timestamps, update_on_create: true
	set_allowed_columns :name
	one_to_many :configurations
	many_to_one :owner, class: :Account
	many_to_many :contributors, class: :Account, join_table: :base_accounts_projects, left_key: :project_id, right_key: :contributor_id
	plugin :association_dependencies, configurations: :destroy

	def before_destroy
		DB[:base_accounts_projects].where(project_id: id).delete
		super
	end

	def repo_url
		SecureDB.decrypt(repo_url_encrypted)
	end

	def repo_url=(repo_url_plain)
		self.repo_url_encrypted = SecureDB.encrypt(repo_url_plain) if repo_url_plain
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