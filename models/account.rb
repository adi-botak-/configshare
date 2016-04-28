require 'sequel'
require 'rbnacl/libsodium'
require 'base64'
require 'json'

# Holds and persists an account's information
class Account < Sequel::Model
	include EncryptableModel

	plugin :timestamps, update_on_create: true
	set_allowed_columns :username, :email
	many_to_many :projects, join_table: :accounts_projects
	one_to_many :owned_projects, class: :Project, key: :owner_id

	plugin :association_dependencies, owned_projects: :destroy
	many_to_many :projects, join_table: :accounts_projects, left_key: :contributor_id, right_key: :project_id

	def password=(new_password)
		nacl = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
		digest = self.class.hash_password(nacl, new_password)
		self.salt = Base64.urlsafe_encode64(nacl)
		self.password_hash = Base64.urlsafe_encode64(digest)
	end

	def to_json(options = {})
		JSON({ type: 'account',
			         username: username
			},
			options)
	end
end