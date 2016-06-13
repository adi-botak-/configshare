require 'json'
require 'base64'
require 'sequel'

# Holds a full configuration file's information
class Configuration < Sequel::Model
	plugin :uuid, field: :id 
	many_to_one :project
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

	def to_full_json(options = {})
	  JSON({
	  	type: 'configuration',
	  	id: id,
	  	attributes: {
	  		filename: filename,
	  		relative_path: relative_path,
	  		description: description,
	  		document: (document ? Base64.strict_encode64(document) : nil)
	  	},
	  	relationships: { project: project }
	  	},
	  	options)
	end

	def to_json(options = {})
		JSON({ type: 'configuration',
			         id: id,
			         attributes: {
			         	  filename: filename,
			         	  relative_path: relative_path,
			         	  description: description
			         }
			},
			options)
	end
end