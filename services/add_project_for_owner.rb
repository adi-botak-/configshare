class AddProjectForOwner
	def self.call(account, name:, repo_url: nil)
		saved_project = account.add_owned_project(name: name)
		saved_project.repo_url = repo_url if repo_url
		saved_project.save
	end
end