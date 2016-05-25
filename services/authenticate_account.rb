# Find account and check password
class AuthenticateAccount
	def self.call(username:, password:)
		return nil unless username && password

		account = Account.where(username: username).first
		if account && account.password?(password)
		  [account, JWE.encrypt(account)]
		else
		  false
		end
	end
end