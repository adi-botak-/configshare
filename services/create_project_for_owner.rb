# Create a new project for an owner
class CreateProjectForOwner
	def self.call(owner_id:, name:, repo_url: nil)
		owner = BaseAccount[owner_id]
		saved_project = owner.add_owned_project(name: name)
		saved_project.repo_url = repo_url if repo_url
		saved_project.save
	end
end