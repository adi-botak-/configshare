require 'json'
require 'base64'
require 'sequel'

# Holds a full configuration file's information
class Configuration < Sequel::Model
	plugin :uuid, field: :id 
	many_to_one :projects
	set_allowed_columns :filename, :relative_path
	plugin :timestamps, update_on_create: true

	def document=(doc_plain)
		self.document_encrypted = SecureDB.encrypt(doc_plain) if doc_plain
	end

	def document
		SecureDB.decrypt(document_encrypted)
	end

	def description=(desc_plain)
		self.description_encrypted = SecureDB.encrypt(desc_plain) if desc_plain
	end

	def description
		SecureDB.decrypt(description_encrypted)
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