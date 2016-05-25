# FInd all projects (owned and contributed to) by an account
class FindAllAccountProjects
	def self.call(username: )
		account = Account.where(username: username).first
		account.projects + account.owned_projects
	end
end