require 'json'
require 'base64'
require 'sequel'

# Holds a full configuration file's information
class Configuration < Sequel::Model
	def to_json(options = {})
		JSON({ type: 'configuration',
			         id: id,
			         data: {
			         	  name: filename,
			         	  description: description,
			         	  base64_document: base64_document
			         }
			},
			options)
	end

	def document
		Base64.strict_decode64 base64_document
	end
end