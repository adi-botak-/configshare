# Create new configuration for project
class CreateConfigurationForProject
	def self.call(project:, filename:, description: nil, document:)
		saved_config = project.add_configuration(filename: filename)
		saved_config.description = description if description
		saved_config.document = document
		saved_config.save
	end
end