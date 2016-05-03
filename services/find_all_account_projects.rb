# FInd all projects (owned and contributed to) by an account
class FindAllAccountProjects
	def self.call(account)
		my_projects = Project.where(owner_id: account.id).all
		other_projects = Project.join(:accounts_projects, project_id: :id).where(contributor_id: account.id).all 
		my_projects + other_projects
	end
end