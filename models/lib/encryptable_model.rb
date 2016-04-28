require 'base64'
require 'rbnacl/libsodium'

# Makes a model EncryptableModel
module EncryptableModel
	def key
		@key ||= Base64.strict_decode64(ENV['DB_KEY'])
	end

	def encrypt(plaintext)
		if plaintext
			simple_box = RbNaCl::SimpleBox.from_secret_key(key)
			ciphertext = simple_box.encrypt(plaintext)
			Base64.strict_encode64(ciphertext)
		end
	end

	def decrypt(ciphertext_64)
		if ciphertext_64
			simple_box = RbNaCl::SimpleBox.from_secret_key(key)
			ciphertext = Base64.strict_decode64(ciphertext_64)
			simple_box.decrypt(ciphertext)
		end
	end
end