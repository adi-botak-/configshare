require 'json'
require 'base64'
require 'sequel'
require 'rbnacl/libsodium'

# Holds a full configuration file's information
class Configuration < Sequel::Model
	many_to_one :projects
	set_allowed_columns :filename, :relative_path, :description

	def key
		@key ||= Base64.strict_decode64(ENV['DB_KEY'])
	end

	def document=(plaintext)
		if plaintext
			secret_box = RbNaCl::SecretBox.new(key)
			new_nonce = RbNaCl::Random.random_bytes(secret_box.nonce_bytes)
			ciphertext = secret_box.encrypt(new_nonce, plaintext)
			self.nonce = Base64.strict_encode64(new_nonce)
			self.document_encrypted = Base64.strict_encode64(ciphertext)
		end
	end

	def document
		@document ||=
			if document_encrypted
				secret_box = RbNaCl::SecretBox.new(key)
				old_nonce = Base64.strict_decode64(nonce)
				ciphertext = Base64.strict_decode64(document_encrypted)
				secret_box.decrypt(old_nonce, ciphertext)
			end
	end

	def to_json(options = {})
		doc = document ? Base64.strict_encode64(document) : nil
		JSON({ type: 'configuration',
			         id: id,
			         data: {
			         	  name: filename,
			         	  description: description,
			         	  document_base64: doc
			         }
			},
			options)
	end
end