# FInd all projects (owned and contributed to) by an account
class FindAllAccountProjects
	def self.call(id: )
		base_account = BaseAccount.first(id: id)
		base_account.projects + base_account.owned_projects
	end
end