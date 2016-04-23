require 'base64'
require 'rbnacl/libsodium'

# Makes a model EncryptableModel
# Required: model must have nonce attribute
module EncryptableModel
	def key
		@key ||= Base64.strict_decode64(ENV['DB_KEY'])
	end

	def encrypt(plaintext, field)
		if plaintext
			secret_box = RbNaCl::SecretBox.new(key)
			new_nonce = field_nonce(field)
			ciphertext = secret_box.encrypt(new_nonce, plaintext)
			self.nonce = Base64.strict_encode64(new_nonce)
			Base64.strict_encode64(ciphertext)
		end
	end

	def decrypt(encrypted)
		if document_encrypted
			secret_box = RbNaCl::SecretBox.new(key)
			old_nonce = Base64.strict_decode64(nonce)
			ciphertext = Base64.strict_decode64(encrypted)
			secret_box.decrypt(old_nonce, ciphertext)
		end
	end

	def field_nonce(field)
		nonce = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.nonce_bytes)
		xor_nonce(field, nonce) + nonce[field.length..nonce.length]
	end

	private

	def xor_nonce(field, nonce)
		len = field.length
		nonce.bytes[0..len - 1].map.with_index do |nb, i|
			(nb ^ field[i].ord).chr
		end.join
	end
end