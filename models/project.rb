require 'json'
require 'sequel'

# Holds a Project's information
class Project < Sequel::Model
	include EncryptableModel

	set_allowed_columns :name
	one_to_many :configurations
	plugin :association_dependencies, :configurations => :delete

	def repo_url
		@repo_url ||= decrypt_field(repo_url_encrypted, :repo_url)
	end

	def repo_url=(repo_url_plaintext)
		@repo_url = repo_url_plaintext
		self.repo_url_encrypted = encrypt_field(@repo_url, :repo_url)
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