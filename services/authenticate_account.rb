# Find account and check password
class AuthenticateAccount
	def self.call(username:, password:)
		return nil unless username && password

		account = Account.first(username: username)
		if account && account.password?(password)
		  [account, JWE.encrypt(account)]
		else
		  nil
		end
	end
end