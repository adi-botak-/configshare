require 'sequel'

Sequel.migration do 
	change do
		create_table(:accounts) do
			String :id, type: :uuid, primary_key: true

			String :username, null: false, unique: true
			String :password_hashed, text: true
			String :nonce_64
		end
	end
end