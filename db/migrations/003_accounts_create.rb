require 'sequel'

Sequel.migration do 
	change do
		create_table(:accounts) do
			primary_key :id

			String :username, null: false, unique: true
			String :password_hash, text: true, null: false
			String :email, null: false
			String :salt, null: false
		end
	end
end