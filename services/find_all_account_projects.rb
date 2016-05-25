# FInd all projects (owned and contributed to) by an account
class FindAllAccountProjects
	def self.call(id: )
		account = Account.where(id: id).first
		account.projects + account.owned_projects
	end
end