require 'json'
require 'sequel'

class Account < Sequel::Model
	include EncryptableModel

	set_allowed_columns :username
	one_to_many :projects, key: :owner_id

	plugin :uuid, field: :id 
	plugin :association_dependencies, :projects => :delete

	def repo_url
		@repo_url ||= decrypt_field(repo_url_encrypted, :repo_url)
	end

	def repo_url=(repo_url_plaintext)
		@repo_url = repo_url_plaintext
		self.repo_url_encrypted = encrypt_field(@repo_url, :repo_url) if @repo_url
	end

	def to_json(options = {})
		JSON({ type: 'account',
			         id: id,
			         attributes: {
			         	  username: username
			         }
			},
			options)
	end
end