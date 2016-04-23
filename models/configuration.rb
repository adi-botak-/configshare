require 'json'
require 'base64'
require 'sequel'

# Holds a full configuration file's information
class Configuration < Sequel::Model
	include EncryptableModel
	plugin :uuid, field: :id 

	many_to_one :projects
	set_allowed_columns :filename, :relative_path

	def encrypt_all
		crypts = encrypted_fields(document: @document, description: @description)
		self.document_encrypted = crypts[:document] if @document
		self.description_encrypted = crypts[:description] if @description
	end

	def document=(document_plaintext)
		@document = document_plaintext
		encrypt_all
	end

	def document
		@document ||= decrypt_field(document_encrypted, :document)
	end

	def description=(description_plaintext)
		@description = description_plaintext
		encrypt_all
	end

	def description
		@description ||= decrypt_field(description_encrypted, :description)
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