# Add a collaborator to another owner's existing project
class AddCollaboratorForProject
	def self.call(account:, project:)
		if project.owner.id != account.id
			account.add_project(project)
			true
		else
			false
		end
	end
end