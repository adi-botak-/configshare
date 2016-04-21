require 'json'

# Holds a full configuration file's information
class Configuration < Sequel::Model
	def to_json(options = {})
		JSON({ type: 'configuration',
			         id: id,
			         data: {
			         	  name: filename,
			         	  description: description,
			         	  document: document
			         }
			},
			options)
	end
end