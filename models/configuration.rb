require 'json'
require 'base64'
require 'sequel'

# Holds a full configuration file's information
class Configuration < Sequel::Model
	include EncryptableModel
	plugin :uuid, field: :id 

	many_to_one :projects
	set_allowed_columns :filename, :relative_path, :description

	def document=(document_plaintext)
		@document = document_plaintext
		self.document_encrypted = encrypt(@document, 'document')
	end

	def document
		@document ||= decrypt(document_encrypted)
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