require 'base64'
require 'rbnacl/libsodium'

# Makes a model EncryptableModel
# Required: model must have nonce attribute
module EncryptableModel
	def key
		@key ||= Base64.strict_decode64(ENV['DB_KEY'])
	end

	def encrypted_fields(fields_hash)
		refresh_nonce

		fields_hash.map do |field, value|
			encrypted_value = value ? encrypt_field(value, field.to_s) : nil
			[field, encrypted_value]
		end.to_h
	end

	def decrypt_field(encrypted, field)
		if encrypted
			secret_box = RbNaCl::SecretBox.new(key)
			ciphertext = Base64.strict_decode64(encrypted)
			secret_box.decrypt(field_nonce(field.to_s), ciphertext)
		end
	end

	private

	def row_nonce
		@row_nonce ||= Base64.strict_decode64(nonce_64 || refresh_nonce)
	end

	def encrypt_field(plaintext, field)
		if plaintext
			secret_box = RbNaCl::SecretBox.new(key)
			ciphertext = secret_box.encrypt(field_nonce(field), plaintext)
			Base64.strict_encode64(ciphertext)
		end
	end

	def refresh_nonce
		@row_nonce = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.nonce_bytes)
		self.nonce_64 = Base64.strict_encode64 row_nonce
	end

	def field_nonce(field)
		xor_field_nonce(field) + row_nonce[field.length..row_nonce.length]
	end

	def xor_field_nonce(field)
		len = field.length
		row_nonce.bytes[0..len - 1].map.with_index do |nb, i|
			(nb ^ field[i].ord).chr
		end.join
	end
end